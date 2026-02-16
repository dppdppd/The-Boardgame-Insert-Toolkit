// SCAD file importer — line-based model with structural bracket tracking.
//
// Every non-blank line becomes a Line object with { raw, kind, depth, ... }
// Brackets are matched and labelled with their structural role.

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

// Derive ALL_KEYS from the actual schema — only keys that exist in a schema
// context get native controls. Everything else stays raw.
const schemaJson = require("./schema/bit.schema.json");
const ALL_KEYS = new Set();
for (const ctx of Object.values(schemaJson.contexts)) {
  for (const k of Object.keys(ctx.keys)) ALL_KEYS.add(k);
}

const GLOBAL_BOOL_RE = /^\s*(g_b_print_lid|g_b_print_box)\s*=\s*(true|false|t|f|0|1)\s*;\s*(?:\/\/.*)?$/i;
const GLOBAL_STR_RE = /^\s*(g_isolated_print_box)\s*=\s*"([^"]*)"\s*;\s*(?:\/\/.*)?$/i;
const INCLUDE_RE = /^\s*include\s*<\s*(?:lib\/)?(?:boardgame_insert_toolkit_lib\.|bit_functions_lib\.)\d+\.scad\s*>\s*;?\s*(?:\/\/.*)?$/i;
const MARKER_RE = /^\s*\/\/\s*BITGUI\b/i;
const MAKEALL_RE = /^\s*MakeAll\s*\(\s*\)\s*;\s*(?:\/\/.*)?$/;
const KV_LINE_RE = /^\s*\[\s*([A-Z][A-Z0-9_]*)\s*,\s*(.*?)\s*\]\s*,?\s*(?:\/\/.*)?$/;

// Structural patterns — all allow optional trailing // comments
const DATA_ASSIGN_RE = /^\s*data\s*=\s*\[\s*(?:\/\/.*)?$/;           // data = [
const DATA_ASSIGN_INLINE_RE = /^\s*data\s*=\s*(?:\/\/.*)?$/;          // data =
const ELEMENT_OPEN_RE = /^\s*\[\s*"([^"]+)"\s*,\s*(?:\/\/.*)?$/;      // [ "name",
const KEY_OPEN_RE = /^\s*\[\s*([A-Z][A-Z0-9_]*)\s*,\s*(?:\/\/.*)?$/;  // [ KEY,
const BARE_OPEN_RE = /^\s*\[\s*(?:\/\/.*)?$/;                          // [
const CLOSE_RE = /^\s*\]\s*,?\s*(?:\/\/.*)?$/;                         // ] or ],
const CLOSE_SEMI_RE = /^\s*\]\s*;\s*(?:\/\/.*)?$/;                     // ];

function parseSimpleValue(text) {
  const t = text.trim();
  if (t === "true" || t === "t") return { value: true, ok: true };
  if (t === "false" || t === "f") return { value: false, ok: true };
  if (t in KNOWN_CONSTANTS) return { value: KNOWN_CONSTANTS[t], ok: true };
  const strMatch = t.match(/^"([^"]*)"$/);
  if (strMatch) return { value: strMatch[1], ok: true };
  if (/^-?\d+(\.\d+)?$/.test(t)) return { value: parseFloat(t), ok: true };
  const arrMatch = t.match(/^\[(.+)\]$/);
  if (arrMatch) {
    const inner = arrMatch[1];
    if (inner.includes("[")) return { ok: false };
    const parts = inner.split(",").map(s => s.trim());
    const vals = [];
    let hasExpr = false;
    for (const part of parts) {
      const sub = parseSimpleValue(part);
      if (!sub.ok) { vals.push(part); hasExpr = true; }
      else { vals.push(hasExpr ? String(sub.value) : sub.value); }
    }
    if (hasExpr) return { value: vals.map(String), ok: true, hasExpr: true };
    return { value: vals, ok: true };
  }
  return { ok: false };
}

/**
 * Extract trailing // comment from a line.
 * Returns { code, comment } where comment is the text after // (without //).
 * Handles strings correctly — // inside "..." is not a comment.
 */
function extractComment(raw) {
  let inStr = false;
  for (let i = 0; i < raw.length; i++) {
    const ch = raw[i];
    if (ch === '"') { inStr = !inStr; continue; }
    if (inStr) continue;
    if (ch === '/' && raw[i + 1] === '/') {
      const code = raw.slice(0, i).trimEnd();
      const comment = raw.slice(i + 2).trim();
      return { code, comment: comment || "" };
    }
  }
  return { code: raw, comment: undefined };
}

function importScad(scadText) {
  const hasMarker = MARKER_RE.test(scadText);
  const rawLines = scadText.replace(/\r\n/g, "\n").split("\n");
  const lines = [];

  // Stack tracks what each bracket level means.
  const stack = [];
  let depth = 0;

  // When we're inside an unrecognized block, rawDepth > 0.
  // Everything is forced to raw until brackets balance out.
  let rawDepth = 0;

  // Count net bracket delta on a line (outside strings/comments)
  function bracketDelta(line) {
    let delta = 0, inStr = false, inLine = false;
    for (let i = 0; i < line.length; i++) {
      const ch = line[i], next = line[i + 1];
      if (inLine) continue;
      if (!inStr && ch === "/" && next === "/") { inLine = true; continue; }
      if (ch === '"') { inStr = !inStr; continue; }
      if (inStr) continue;
      if (ch === "[") delta++;
      if (ch === "]") delta--;
    }
    return delta;
  }

  for (const raw of rawLines) {
    if (!raw.trim()) continue;

    // --- If inside an unrecognized block, everything is raw ---
    if (rawDepth > 0) {
      rawDepth += bracketDelta(raw);
      lines.push({ raw, kind: "raw", depth });
      continue;
    }

    // --- Non-structural lines ---

    const boolMatch = raw.match(GLOBAL_BOOL_RE);
    if (boolMatch) {
      const v = boolMatch[2].toLowerCase();
      lines.push({ raw, kind: "global", depth, globalKey: boolMatch[1], globalValue: v === "true" || v === "t" || v === "1" });
      continue;
    }
    const strMatch = raw.match(GLOBAL_STR_RE);
    if (strMatch) {
      lines.push({ raw, kind: "global", depth, globalKey: strMatch[1], globalValue: strMatch[2] });
      continue;
    }
    if (INCLUDE_RE.test(raw)) { lines.push({ raw, kind: "include", depth }); continue; }
    if (MARKER_RE.test(raw)) { lines.push({ raw, kind: "marker", depth }); continue; }
    if (MAKEALL_RE.test(raw)) { lines.push({ raw, kind: "makeall", depth }); continue; }

    // KV line (self-contained: [ KEY, value ])
    const kvMatch = raw.match(KV_LINE_RE);
    if (kvMatch && ALL_KEYS.has(kvMatch[1])) {
      const parsed = parseSimpleValue(kvMatch[2]);
      if (parsed.ok) {
        lines.push({ raw, kind: "kv", depth, kvKey: kvMatch[1], kvValue: parsed.value });
        continue;
      }
    }

    // --- Structural: opening brackets ---

    // data = [
    if (DATA_ASSIGN_RE.test(raw)) {
      lines.push({ raw, kind: "open", depth, role: "data", label: "data" });
      stack.push({ role: "data" });
      depth++;
      continue;
    }
    if (DATA_ASSIGN_INLINE_RE.test(raw)) {
      lines.push({ raw, kind: "raw", depth });
      continue;
    }

    // [ "name",  — element opener
    const elemMatch = raw.match(ELEMENT_OPEN_RE);
    if (elemMatch) {
      lines.push({ raw, kind: "open", depth, role: "element", label: elemMatch[1] });
      stack.push({ role: "element", label: elemMatch[1] });
      depth++;
      continue;
    }

    // [ KEY,  — only for recognized structural schema keys
    const keyOpenMatch = raw.match(KEY_OPEN_RE);
    if (keyOpenMatch) {
      const key = keyOpenMatch[1];
      let role = null;
      if (key === "BOX_COMPONENT") role = "component_list";
      else if (key === "BOX_LID") role = "lid";
      else if (key === "LABEL") role = "label";

      if (role) {
        lines.push({ raw, kind: "open", depth, role, label: key });
        stack.push({ role, label: key });
        depth++;
        continue;
      }
      // Unknown key — this line is raw, and everything inside its brackets is raw too
      const delta = bracketDelta(raw);
      if (delta > 0) rawDepth = delta; // opened brackets that need closing
      lines.push({ raw, kind: "raw", depth });
      continue;
    }

    // bare [
    if (BARE_OPEN_RE.test(raw)) {
      const parent = stack.length > 0 ? stack[stack.length - 1] : null;
      let role = "list";
      let label = "[";
      if (parent?.role === "element") { role = "params"; label = "element params"; }
      else if (parent?.role === "component_list") { role = "component"; label = "component list"; }
      else if (parent?.role === "lid") { role = "lid_params"; label = "lid params"; }
      else if (parent?.role === "label") { role = "label_params"; label = "label params"; }
      else if (parent?.role === "data") { role = "data_list"; label = "data list"; }

      lines.push({ raw, kind: "open", depth, role, label });
      stack.push({ role, label });
      depth++;
      continue;
    }

    // --- Structural: closing brackets ---

    if (CLOSE_SEMI_RE.test(raw)) {
      depth = Math.max(0, depth - 1);
      const popped = stack.pop();
      lines.push({ raw, kind: "close", depth, role: popped?.role || "unknown", label: popped?.label || "" });
      continue;
    }

    if (CLOSE_RE.test(raw)) {
      depth = Math.max(0, depth - 1);
      const popped = stack.pop();
      lines.push({ raw, kind: "close", depth, role: popped?.role || "unknown", label: popped?.label || "" });
      continue;
    }

    // --- Everything else: raw ---
    lines.push({ raw, kind: "raw", depth });
  }

  // Post-process: extract trailing comments from all non-raw lines.
  // (Raw lines keep their comments as part of the raw text.)
  for (const line of lines) {
    if (line.kind === "raw") continue;
    const { comment } = extractComment(line.raw);
    if (comment !== undefined) {
      line.comment = comment;
    }
  }

  return { version: 4, lines, hasMarker };
}

/**
 * Re-import a block of raw text lines using the full structural parser.
 * Used when the user edits a raw group textarea and we need to re-evaluate
 * whether the text now contains recognizable structure.
 *
 * @param {string} text - The raw text block (may be multi-line)
 * @param {number} baseDepth - The depth at which these lines sit in the tree
 * @returns {Line[]} - Classified lines
 */
function reimportBlock(text, baseDepth) {
  // Wrap in a minimal SCAD that places the text at the right bracket depth.
  // We just run the text through the same import logic but adjust depths.
  const rawLines = text.replace(/\r\n/g, "\n").split("\n");
  const lines = [];

  const stack = [];
  let depth = baseDepth;
  let rawDepth = 0;

  function bracketDeltaLocal(line) {
    let delta = 0, inStr = false, inLine = false;
    for (let i = 0; i < line.length; i++) {
      const ch = line[i], next = line[i + 1];
      if (inLine) continue;
      if (!inStr && ch === "/" && next === "/") { inLine = true; continue; }
      if (ch === '"') { inStr = !inStr; continue; }
      if (inStr) continue;
      if (ch === "[") delta++;
      if (ch === "]") delta--;
    }
    return delta;
  }

  for (const raw of rawLines) {
    if (!raw.trim()) continue;

    if (rawDepth > 0) {
      rawDepth += bracketDeltaLocal(raw);
      lines.push({ raw, kind: "raw", depth });
      continue;
    }

    // Globals
    const boolMatch = raw.match(GLOBAL_BOOL_RE);
    if (boolMatch) {
      const v = boolMatch[2].toLowerCase();
      lines.push({ raw, kind: "global", depth, globalKey: boolMatch[1], globalValue: v === "true" || v === "t" || v === "1" });
      continue;
    }
    const strMatch = raw.match(GLOBAL_STR_RE);
    if (strMatch) {
      lines.push({ raw, kind: "global", depth, globalKey: strMatch[1], globalValue: strMatch[2] });
      continue;
    }
    if (INCLUDE_RE.test(raw)) { lines.push({ raw, kind: "include", depth }); continue; }
    if (MARKER_RE.test(raw)) { lines.push({ raw, kind: "marker", depth }); continue; }
    if (MAKEALL_RE.test(raw)) { lines.push({ raw, kind: "makeall", depth }); continue; }

    // KV
    const kvMatch = raw.match(KV_LINE_RE);
    if (kvMatch && ALL_KEYS.has(kvMatch[1])) {
      const parsed = parseSimpleValue(kvMatch[2]);
      if (parsed.ok) {
        lines.push({ raw, kind: "kv", depth, kvKey: kvMatch[1], kvValue: parsed.value });
        continue;
      }
    }

    // data = [
    if (DATA_ASSIGN_RE.test(raw)) {
      lines.push({ raw, kind: "open", depth, role: "data", label: "data" });
      stack.push({ role: "data" });
      depth++;
      continue;
    }

    // [ "name",
    const elemMatch = raw.match(ELEMENT_OPEN_RE);
    if (elemMatch) {
      lines.push({ raw, kind: "open", depth, role: "element", label: elemMatch[1] });
      stack.push({ role: "element", label: elemMatch[1] });
      depth++;
      continue;
    }

    // [ KEY, (structural)
    const keyOpenMatch = raw.match(KEY_OPEN_RE);
    if (keyOpenMatch) {
      const key = keyOpenMatch[1];
      let role = null;
      if (key === "BOX_COMPONENT") role = "component_list";
      else if (key === "BOX_LID") role = "lid";
      else if (key === "LABEL") role = "label";
      if (role) {
        lines.push({ raw, kind: "open", depth, role, label: key });
        stack.push({ role, label: key });
        depth++;
        continue;
      }
      const delta = bracketDeltaLocal(raw);
      if (delta > 0) rawDepth = delta;
      lines.push({ raw, kind: "raw", depth });
      continue;
    }

    // bare [
    if (BARE_OPEN_RE.test(raw)) {
      const parent = stack.length > 0 ? stack[stack.length - 1] : null;
      let role = "list";
      let label = "[";
      if (parent?.role === "element") { role = "params"; label = "element params"; }
      else if (parent?.role === "component_list") { role = "component"; label = "component list"; }
      else if (parent?.role === "lid") { role = "lid_params"; label = "lid params"; }
      else if (parent?.role === "label") { role = "label_params"; label = "label params"; }
      else if (parent?.role === "data") { role = "data_list"; label = "data list"; }
      lines.push({ raw, kind: "open", depth, role, label });
      stack.push({ role, label });
      depth++;
      continue;
    }

    // ];
    if (CLOSE_SEMI_RE.test(raw)) {
      depth = Math.max(baseDepth, depth - 1);
      const popped = stack.pop();
      lines.push({ raw, kind: "close", depth, role: popped?.role || "unknown", label: popped?.label || "" });
      continue;
    }

    // ] or ],
    if (CLOSE_RE.test(raw)) {
      depth = Math.max(baseDepth, depth - 1);
      const popped = stack.pop();
      lines.push({ raw, kind: "close", depth, role: popped?.role || "unknown", label: popped?.label || "" });
      continue;
    }

    lines.push({ raw, kind: "raw", depth });
  }

  return lines;
}

module.exports = { importScad, reimportBlock };
