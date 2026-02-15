// SCAD file importer — parses BIT-style data[] arrays into project JSON
//
// Handles the standard BIT format:
//   data = [ ["name", [ [KEY, value], ... ]], ... ];
//
// Strategy: use regex + recursive descent on the data array portion.
// This is NOT a full OpenSCAD parser — it handles the BIT subset only.

const KNOWN_CONSTANTS = {
  // Types
  BOX: "BOX", DIVIDERS: "DIVIDERS", SPACER: "SPACER",
  // Shapes
  SQUARE: "SQUARE", HEX: "HEX", HEX2: "HEX2",
  OCT: "OCT", OCT2: "OCT2", ROUND: "ROUND", FILLET: "FILLET",
  // Cutout types
  INTERIOR: "INTERIOR", EXTERIOR: "EXTERIOR", BOTH: "BOTH",
  // Placement
  FRONT: "FRONT", BACK: "BACK", LEFT: "LEFT", RIGHT: "RIGHT",
  FRONT_WALL: "FRONT_WALL", BACK_WALL: "BACK_WALL",
  LEFT_WALL: "LEFT_WALL", RIGHT_WALL: "RIGHT_WALL",
  CENTER: "CENTER", BOTTOM: "BOTTOM",
  // Special
  AUTO: "AUTO", MAX: "MAX",
  // Booleans
  true: true, false: false, t: true, f: false,
};

// All known BIT key constants
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
        // Line comment
        while (this.pos < this.src.length && this.src[this.pos] !== "\n") this.pos++;
      } else if (this.src.slice(this.pos, this.pos + 2) === "/*") {
        // Block comment
        this.pos += 2;
        while (this.pos < this.src.length - 1 && this.src.slice(this.pos, this.pos + 2) !== "*/") this.pos++;
        this.pos += 2;
      } else {
        break;
      }
    }
  }

  peek() {
    this.skipWS();
    return this.src[this.pos];
  }

  expect(ch) {
    this.skipWS();
    if (this.src[this.pos] !== ch) {
      throw new Error(`Expected '${ch}' at pos ${this.pos}, got '${this.src[this.pos]}'`);
    }
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
      // Check if this is part of an expression (e.g. 3*20 + 8*wall)
      if (this.pos < this.src.length && /[+\-*/%]/.test(this.src[this.pos])) {
        return this.skipExpression(num);
      }
      return num;
    }

    // Identifier (constant or boolean)
    if (/[a-zA-Z_]/.test(ch)) {
      return this.parseIdentifier();
    }

    // Unknown character — skip expression
    return this.skipExpression(null);
  }

  /** Capture an arithmetic expression as a raw string */
  skipExpression(partial) {
    const start = this.pos;
    let depth = 0;
    while (this.pos < this.src.length) {
      const ch = this.src[this.pos];
      if (ch === "[" || ch === "(") depth++;
      else if (ch === "]" || ch === ")") {
        if (depth <= 0) break;
        depth--;
      }
      else if (ch === "," && depth <= 0) break;
      this.pos++;
    }
    const rest = this.src.slice(start, this.pos).trim();
    const expr = partial != null ? String(partial) + rest : rest;
    return { __expr: expr };
  }

  parseString() {
    this.expect('"');
    let s = "";
    while (this.pos < this.src.length && this.src[this.pos] !== '"') {
      if (this.src[this.pos] === "\\") {
        this.pos++;
        s += this.src[this.pos];
      } else {
        s += this.src[this.pos];
      }
      this.pos++;
    }
    this.expect('"');
    return s;
  }

  parseNumber() {
    this.skipWS();
    let s = "";
    if (this.src[this.pos] === "-") { s += "-"; this.pos++; }
    while (this.pos < this.src.length && (this.src[this.pos] >= "0" && this.src[this.pos] <= "9" || this.src[this.pos] === ".")) {
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
    // Check for function call: identifier(...)
    if (this.pos < this.src.length && this.src[this.pos] === "(") {
      return this.skipFunctionCall(s);
    }
    // Check for expression: identifier * something
    if (this.pos < this.src.length && /[+\-*/%]/.test(this.src[this.pos])) {
      return this.skipExpression(s);
    }
    if (s in KNOWN_CONSTANTS) return KNOWN_CONSTANTS[s];
    if (KEY_CONSTANTS.has(s)) return { __key: s };
    return s; // Unknown identifier, return as string
  }

  skipFunctionCall(name) {
    // Capture the full function call text
    const start = this.pos;
    let depth = 0;
    while (this.pos < this.src.length) {
      const ch = this.src[this.pos];
      if (ch === "(") depth++;
      else if (ch === ")") { depth--; if (depth <= 0) { this.pos++; break; } }
      this.pos++;
    }
    const callText = name + this.src.slice(start, this.pos);
    // Check if followed by an operator
    this.skipWS();
    if (this.pos < this.src.length && /[+\-*/%]/.test(this.src[this.pos])) {
      return this.skipExpression(callText);
    }
    return { __expr: callText };
  }

  parseArray() {
    this.expect("[");
    const items = [];
    let safety = 0;
    while (this.peek() !== "]" && this.pos < this.src.length) {
      if (++safety > 100000) throw new Error(`Array parse safety limit at pos ${this.pos}: '${this.src.slice(this.pos, this.pos+50)}'`);
      items.push(this.parseValue());
      this.skipWS();
      if (this.src[this.pos] === ",") this.pos++;
    }
    this.expect("]");
    return items;
  }
}

/**
 * Determine if an array looks like a key-value pair: [KEY_CONSTANT, value]
 */
function isKVPair(arr) {
  return Array.isArray(arr) && arr.length === 2 &&
    arr[0] && typeof arr[0] === "object" && arr[0].__key;
}

/**
 * Determine if an array looks like a list of KV pairs (a table)
 */
function isKVTable(arr) {
  return Array.isArray(arr) && arr.length > 0 && arr.every(item => isKVPair(item));
}

/**
 * Convert a parsed KV table into project params format.
 * Handles nested tables (BOX_COMPONENT, BOX_LID, LABEL).
 */
function convertParams(kvPairs) {
  const params = [];
  for (const pair of kvPairs) {
    if (!isKVPair(pair)) continue;
    const key = pair[0].__key;
    let value = pair[1];

    if (key === "BOX_COMPONENT") {
      // BOX_COMPONENT value is a table of component params.
      // In SCAD, multiple BOX_COMPONENT entries = multiple components.
      // Each BOX_COMPONENT value is a KV table.
      const existing = params.find(p => p.key === "BOX_COMPONENT");
      const componentParams = isKVTable(value) ? convertParams(value) : [];
      if (existing) {
        existing.value.push(componentParams);
      } else {
        params.push({ key: "BOX_COMPONENT", value: [componentParams] });
      }
    } else if (key === "BOX_LID" || key === "LABEL") {
      // Single nested table
      const childParams = isKVTable(value) ? convertParams(value) : [];
      params.push({ key, value: childParams });
    } else {
      // Scalar value — resolve any remaining __key markers
      params.push({ key, value: resolveValue(value) });
    }
  }
  return params;
}

function resolveValue(val) {
  if (val && typeof val === "object" && val.__key) return val.__key;
  if (val && typeof val === "object" && val.__funcCall) return { __expr: val.__funcCall };
  if (val && typeof val === "object" && val.__expr) return val;
  if (Array.isArray(val)) {
    // If any element is an expression, return the whole thing as a raw expression
    const resolved = val.map(resolveValue);
    if (resolved.some(v => v && typeof v === "object" && v.__expr)) {
      return { __expr: "[" + resolved.map(v => v && v.__expr ? v.__expr : JSON.stringify(v)).join(", ") + "]" };
    }
    return resolved;
  }
  return val;
}

/**
 * Parse a BIT SCAD file and return a project JSON object.
 */
function importScad(scadText) {
  // Extract globals
  const globals = {};
  const globalPatterns = [
    [/g_b_print_lid\s*=\s*(true|false|t|f)\s*;/, "g_b_print_lid", v => v === "true" || v === "t"],
    [/g_b_print_box\s*=\s*(true|false|t|f)\s*;/, "g_b_print_box", v => v === "true" || v === "t"],
    [/g_isolated_print_box\s*=\s*"([^"]*)"\s*;/, "g_isolated_print_box", v => v],
  ];
  for (const [re, key, convert] of globalPatterns) {
    const m = scadText.match(re);
    if (m) globals[key] = convert(m[1]);
  }
  if (!("g_b_print_lid" in globals)) globals.g_b_print_lid = true;
  if (!("g_b_print_box" in globals)) globals.g_b_print_box = true;
  if (!("g_isolated_print_box" in globals)) globals.g_isolated_print_box = "";

  // Find the data = [...]; block
  const dataMatch = scadText.match(/data\s*=\s*\[/);
  if (!dataMatch) {
    throw new Error("Could not find 'data = [' in the SCAD file");
  }

  // Parse from the opening bracket
  const parser = new Parser(scadText);
  parser.pos = dataMatch.index + dataMatch[0].length - 1; // position at '['
  const dataArray = parser.parseArray();

  // Convert: each element is ["name", [ [KEY, val], ... ]]
  const elements = [];
  for (const elem of dataArray) {
    if (!Array.isArray(elem) || elem.length < 2) continue;
    const name = typeof elem[0] === "string" ? elem[0] : String(elem[0]);
    const kvTable = elem[1];
    if (!Array.isArray(kvTable)) continue;

    const params = convertParams(kvTable);

    // Extract TYPE from params
    const typeParam = params.find(p => p.key === "TYPE");
    const type = typeParam ? String(typeParam.value) : "BOX";
    // Remove TYPE from params (it's stored at element level)
    const filteredParams = params.filter(p => p.key !== "TYPE");

    elements.push({ name, type, params: filteredParams });
  }

  return {
    version: 1,
    globals,
    data: elements,
  };
}

module.exports = { importScad };
