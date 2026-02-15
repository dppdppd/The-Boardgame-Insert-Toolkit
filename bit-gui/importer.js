// SCAD file importer — parses BIT-style data[] arrays into project JSON
//
// Preserves all code outside the data[] block and recognized globals.
// Unrecognized code is kept verbatim in preamble/postamble fields.

const KNOWN_CONSTANTS = {
  BOX: "BOX", DIVIDERS: "DIVIDERS", SPACER: "SPACER",
  SQUARE: "SQUARE", HEX: "HEX", HEX2: "HEX2",
  OCT: "OCT", OCT2: "OCT2", ROUND: "ROUND", FILLET: "FILLET",
  INTERIOR: "INTERIOR", EXTERIOR: "EXTERIOR", BOTH: "BOTH",
  FRONT: "FRONT", BACK: "BACK", LEFT: "LEFT", RIGHT: "RIGHT",
  FRONT_WALL: "FRONT_WALL", BACK_WALL: "BACK_WALL",
  LEFT_WALL: "LEFT_WALL", RIGHT_WALL: "RIGHT_WALL",
  CENTER: "CENTER", BOTTOM: "BOTTOM",
  AUTO: "AUTO", MAX: "MAX",
  true: true, false: false, t: true, f: false,
};

const KEY_CONSTANTS = new Set([
  "TYPE", "BOX_SIZE_XYZ", "BOX_COMPONENT", "BOX_LID", "BOX_VISUALIZATION",
  "BOX_NO_LID_B", "BOX_STACKABLE_B", "BOX_WALL_THICKNESS",
  "ENABLED_B", "LABEL", "ROTATION", "POSITION_XY",
  "CMP_COMPARTMENT_SIZE_XYZ", "CMP_NUM_COMPARTMENTS_XY", "CMP_SHAPE",
  "CMP_SHAPE_ROTATED_B", "CMP_SHAPE_VERTICAL_B", "CMP_PADDING_XY",
  "CMP_PADDING_HEIGHT_ADJUST_XY", "CMP_MARGIN_FBLR",
  "CMP_CUTOUT_SIDES_4B", "CMP_CUTOUT_CORNERS_4B",
  "CMP_CUTOUT_HEIGHT_PCT", "CMP_CUTOUT_DEPTH_PCT", "CMP_CUTOUT_WIDTH_PCT",
  "CMP_CUTOUT_BOTTOM_B", "CMP_CUTOUT_BOTTOM_PCT",
  "CMP_CUTOUT_TYPE", "CMP_CUTOUT_DEPTH_MAX",
  "CMP_SHEAR", "CMP_FILLET_RADIUS", "CMP_PEDESTAL_BASE_B",
  "LID_FIT_UNDER_B", "LID_SOLID_B", "LID_HEIGHT", "LID_INSET_B",
  "LID_CUTOUT_SIDES_4B", "LID_TABS_4B", "LID_LABELS_INVERT_B",
  "LID_SOLID_LABELS_DEPTH", "LID_LABELS_BG_THICKNESS",
  "LID_LABELS_BORDER_THICKNESS", "LID_STRIPE_WIDTH", "LID_STRIPE_SPACE",
  "LID_PATTERN_RADIUS", "LID_PATTERN_N1", "LID_PATTERN_N2",
  "LID_PATTERN_ANGLE", "LID_PATTERN_ROW_OFFSET", "LID_PATTERN_COL_OFFSET",
  "LID_PATTERN_THICKNESS",
  "LBL_TEXT", "LBL_IMAGE", "LBL_SIZE", "LBL_PLACEMENT", "LBL_FONT",
  "LBL_DEPTH", "LBL_SPACING", "LBL_AUTO_SCALE_FACTOR",
  "DIV_THICKNESS", "DIV_TAB_SIZE_XY", "DIV_TAB_RADIUS",
  "DIV_TAB_CYCLE", "DIV_TAB_CYCLE_START", "DIV_TAB_TEXT",
  "DIV_TAB_TEXT_SIZE", "DIV_TAB_TEXT_FONT", "DIV_TAB_TEXT_SPACING",
  "DIV_TAB_TEXT_CHAR_THRESHOLD", "DIV_TAB_TEXT_EMBOSSED_B",
  "DIV_FRAME_SIZE_XY", "DIV_FRAME_TOP", "DIV_FRAME_BOTTOM",
  "DIV_FRAME_COLUMN", "DIV_FRAME_RADIUS", "DIV_FRAME_NUM_COLUMNS",
]);

// Globals we extract (everything else stays in preamble/postamble)
const GLOBAL_PATTERNS = [
  { re: /^(g_b_print_lid)\s*=\s*(true|false|t|f)\s*;/m, key: "g_b_print_lid", convert: v => v === "true" || v === "t" },
  { re: /^(g_b_print_box)\s*=\s*(true|false|t|f)\s*;/m, key: "g_b_print_box", convert: v => v === "true" || v === "t" },
  { re: /^(g_isolated_print_box)\s*=\s*"([^"]*)"\s*;/m, key: "g_isolated_print_box", convert: v => v },
];

class Parser {
  constructor(src) {
    this.src = src;
    this.pos = 0;
  }

  skipWS() {
    while (this.pos < this.src.length) {
      const ch = this.src[this.pos];
      if (ch === " " || ch === "\t" || ch === "\n" || ch === "\r") {
        this.pos++;
      } else if (this.src.slice(this.pos, this.pos + 2) === "//") {
        while (this.pos < this.src.length && this.src[this.pos] !== "\n") this.pos++;
      } else if (this.src.slice(this.pos, this.pos + 2) === "/*") {
        this.pos += 2;
        while (this.pos < this.src.length - 1 && this.src.slice(this.pos, this.pos + 2) !== "*/") this.pos++;
        this.pos += 2;
      } else {
        break;
      }
    }
  }

  peek() { this.skipWS(); return this.src[this.pos]; }

  expect(ch) {
    this.skipWS();
    if (this.src[this.pos] !== ch) throw new Error(`Expected '${ch}' at pos ${this.pos}, got '${this.src[this.pos]}'`);
    this.pos++;
  }

  parseValue() {
    this.skipWS();
    const ch = this.src[this.pos];
    if (ch === "[") return this.parseArray();
    if (ch === '"') return this.parseString();
    if (ch === "-" || (ch >= "0" && ch <= "9")) {
      const num = this.parseNumber();
      this.skipWS();
      if (this.pos < this.src.length && /[+\-*/%]/.test(this.src[this.pos])) {
        return this.skipExpression(num);
      }
      return num;
    }
    if (/[a-zA-Z_]/.test(ch)) return this.parseIdentifier();
    return this.skipExpression(null);
  }

  parseString() {
    this.expect('"');
    let s = "";
    while (this.pos < this.src.length && this.src[this.pos] !== '"') {
      if (this.src[this.pos] === "\\") { this.pos++; s += this.src[this.pos]; }
      else s += this.src[this.pos];
      this.pos++;
    }
    this.expect('"');
    return s;
  }

  parseNumber() {
    this.skipWS();
    let s = "";
    if (this.src[this.pos] === "-") { s += "-"; this.pos++; }
    while (this.pos < this.src.length && /[0-9.]/.test(this.src[this.pos])) {
      s += this.src[this.pos++];
    }
    return parseFloat(s);
  }

  parseIdentifier() {
    this.skipWS();
    let s = "";
    while (this.pos < this.src.length && /[a-zA-Z0-9_]/.test(this.src[this.pos])) {
      s += this.src[this.pos++];
    }
    this.skipWS();
    if (this.pos < this.src.length && this.src[this.pos] === "(") {
      return this.skipFunctionCall(s);
    }
    if (this.pos < this.src.length && /[+\-*/%]/.test(this.src[this.pos])) {
      return this.skipExpression(s);
    }
    if (s in KNOWN_CONSTANTS) return KNOWN_CONSTANTS[s];
    if (KEY_CONSTANTS.has(s)) return { __key: s };
    return s;
  }

  skipFunctionCall(name) {
    const start = this.pos;
    let depth = 0;
    while (this.pos < this.src.length) {
      const ch = this.src[this.pos];
      if (ch === "(") depth++;
      else if (ch === ")") { depth--; if (depth <= 0) { this.pos++; break; } }
      this.pos++;
    }
    const callText = name + this.src.slice(start, this.pos);
    this.skipWS();
    if (this.pos < this.src.length && /[+\-*/%]/.test(this.src[this.pos])) {
      return this.skipExpression(callText);
    }
    return { __expr: callText };
  }

  skipExpression(partial) {
    const start = this.pos;
    let depth = 0;
    while (this.pos < this.src.length) {
      const ch = this.src[this.pos];
      if (ch === "[" || ch === "(") depth++;
      else if (ch === "]" || ch === ")") { if (depth <= 0) break; depth--; }
      else if (ch === "," && depth <= 0) break;
      this.pos++;
    }
    const rest = this.src.slice(start, this.pos).trim();
    const expr = partial != null ? String(partial) + rest : rest;
    return { __expr: expr };
  }

  parseArray() {
    this.expect("[");
    const items = [];
    let safety = 0;
    while (this.peek() !== "]" && this.pos < this.src.length) {
      if (++safety > 100000) throw new Error(`Array parse safety limit at pos ${this.pos}`);
      items.push(this.parseValue());
      this.skipWS();
      if (this.src[this.pos] === ",") this.pos++;
    }
    this.expect("]");
    return items;
  }
}

function isKVPair(arr) {
  return Array.isArray(arr) && arr.length === 2 && arr[0] && typeof arr[0] === "object" && arr[0].__key;
}

function isKVTable(arr) {
  return Array.isArray(arr) && arr.length > 0 && arr.every(item => isKVPair(item));
}

function resolveValue(val) {
  if (val && typeof val === "object" && val.__key) return val.__key;
  if (val && typeof val === "object" && val.__expr) return val;
  if (Array.isArray(val)) {
    const resolved = val.map(resolveValue);
    if (resolved.some(v => v && typeof v === "object" && v.__expr)) {
      return { __expr: "[" + resolved.map(v => v && v.__expr ? v.__expr : JSON.stringify(v)).join(", ") + "]" };
    }
    return resolved;
  }
  return val;
}

function convertParams(kvPairs) {
  const params = [];
  for (const pair of kvPairs) {
    if (!isKVPair(pair)) continue;
    const key = pair[0].__key;
    let value = pair[1];

    if (key === "BOX_COMPONENT") {
      const existing = params.find(p => p.key === "BOX_COMPONENT");
      const componentParams = isKVTable(value) ? convertParams(value) : [];
      if (existing) {
        existing.value.push(componentParams);
      } else {
        params.push({ key: "BOX_COMPONENT", value: [componentParams] });
      }
    } else if (key === "BOX_LID" || key === "LABEL") {
      const childParams = isKVTable(value) ? convertParams(value) : [];
      params.push({ key, value: childParams });
    } else {
      params.push({ key, value: resolveValue(value) });
    }
  }
  return params;
}

/**
 * Parse a BIT SCAD file.
 * Returns { version, globals, data, preamble, postamble, hasMarker }
 *
 * preamble: all text before "data = [" (minus extracted globals)
 * postamble: all text after the data array's closing "];"
 * hasMarker: true if file contains "// BITGUI" marker
 */
function importScad(scadText) {
  const hasMarker = /\/\/\s*BITGUI\b/.test(scadText);

  // Find data array boundaries
  const dataMatch = scadText.match(/data\s*=\s*\[/);
  if (!dataMatch) throw new Error("Could not find 'data = [' in the SCAD file");

  const dataStart = dataMatch.index;

  // Parse the data array to find where it ends
  const parser = new Parser(scadText);
  parser.pos = dataStart + dataMatch[0].length - 1;
  const dataArray = parser.parseArray();

  // Skip trailing semicolon
  parser.skipWS();
  if (parser.pos < scadText.length && scadText[parser.pos] === ";") parser.pos++;

  const dataEnd = parser.pos;

  // Extract preamble: everything before data=, minus globals we recognize
  let preamble = scadText.slice(0, dataStart);

  // Extract globals from preamble
  const globals = {};
  for (const { re, key, convert } of GLOBAL_PATTERNS) {
    const m = preamble.match(re);
    if (m) {
      globals[key] = convert(m[2] || m[1]);
      // Remove the global line from preamble (we'll regenerate it)
      preamble = preamble.replace(re, "").replace(/\n\n\n+/g, "\n\n");
    }
  }
  if (!("g_b_print_lid" in globals)) globals.g_b_print_lid = true;
  if (!("g_b_print_box" in globals)) globals.g_b_print_box = true;
  if (!("g_isolated_print_box" in globals)) globals.g_isolated_print_box = "";

  // Clean up preamble — remove BITGUI marker (we'll add it back)
  preamble = preamble.replace(/\/\/\s*BITGUI\b[^\n]*/g, "").replace(/^\n+/, "").replace(/\n\n\n+/g, "\n\n");

  // Postamble: everything after data array
  let postamble = scadText.slice(dataEnd).replace(/^\n+/, "");

  // Convert elements
  const elements = [];
  for (const elem of dataArray) {
    if (!Array.isArray(elem) || elem.length < 2) continue;
    const name = typeof elem[0] === "string" ? elem[0] : String(elem[0]);
    const kvTable = elem[1];
    if (!Array.isArray(kvTable)) continue;

    const params = convertParams(kvTable);
    const typeParam = params.find(p => p.key === "TYPE");
    const type = typeParam ? String(typeParam.value) : "BOX";
    const filteredParams = params.filter(p => p.key !== "TYPE");

    elements.push({ name, type, params: filteredParams });
  }

  return {
    version: 1,
    globals,
    data: elements,
    preamble: preamble.trimEnd() + "\n",
    postamble: postamble.trimStart(),
    hasMarker,
  };
}

module.exports = { importScad };
