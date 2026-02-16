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

// --- Load-time formatter ---
// Normalizes the `data = [ ... ];` table so the line-based editor can
// reliably classify entries (KV on one line, structural openers/closers
// on their own lines, and commas fixed).

const FORMAT_STRUCTURAL_KEYS = new Set(["BOX_COMPONENT", "BOX_LID", "LABEL"]);

function formatScadOnLoad(scadText) {
  const text = String(scadText ?? "").replace(/\r\n/g, "\n");
  const span = findDataAssignmentSpan(text);
  if (!span) return { text, changed: false };

  const { stmtStart, stmtEnd, baseIndent, headerComment, footerComment, arrayText } = span;

  let root;
  try {
    const toks = tokenizeScad(arrayText);
    const parser = makeParser(toks);
    root = parser.parseArray();
  } catch {
    // If anything about parsing fails, don't risk rewriting the file.
    return { text, changed: false };
  }

  // Best-effort v2 -> v4 normalization inside data[]:
  // - BOX_COMPONENTS => multiple BOX_COMPONENT entries
  // - BOX_LID_* keys => BOX_LID block with LID_* keys
  try { transformV2ToV4(root); } catch { /* non-fatal */ }

  const out = [];
  const headerLine = `${baseIndent}data = [` + (headerComment ? ` //${headerComment}` : "");
  out.push(headerLine);

  // Root array elements (boxes/dividers)
  for (const el of root.elements) {
    if (el.type === "comment") {
      out.push(`${baseIndent}${" ".repeat(4)}//${el.text}`);
      continue;
    }
    renderEntryLines(el, baseIndent + " ".repeat(4), true, out);
  }

  out.push(`${baseIndent}];` + (footerComment ? ` //${footerComment}` : ""));

  const formattedStmt = out.join("\n");

  // Preserve a line break between the data statement and whatever follows.
  // (Without this, files that had `];\nMakeAll();` could become `];MakeAll();`)
  const suffix = text.slice(stmtEnd);
  const needsSep = suffix.length > 0 && !formattedStmt.endsWith("\n") && !suffix.startsWith("\n");
  const newText = text.slice(0, stmtStart) + formattedStmt + (needsSep ? "\n" : "") + suffix;
  return { text: newText, changed: newText !== text };
}

function transformV2ToV4(node) {
  if (!node) return;
  if (node.type === "array") transformArrayNode(node);
}

function transformArrayNode(arr) {
  // First recurse into children so we normalize deepest blocks too.
  for (const el of arr.elements) {
    if (el && el.type === "array") transformArrayNode(el);
  }

  // 1) BOX_COMPONENTS => flatten to BOX_COMPONENT entries
  const flattened = [];
  for (const el of arr.elements) {
    if (isPairArray(el, "BOX_COMPONENTS")) {
      const [, v] = getPairValues(el);
      if (v && v.type === "array") {
        for (const compEl of v.elements) {
          if (compEl?.type === "comment") {
            // Preserve comments at same level as components
            flattened.push(compEl);
            continue;
          }
          const compPair = parseComponentV2Entry(compEl);
          if (!compPair) {
            flattened.push(compEl);
            continue;
          }
          flattened.push(makeArray([makeAtom("BOX_COMPONENT"), compPair.paramsArray]));
        }
        continue; // drop the BOX_COMPONENTS wrapper
      }
    }
    flattened.push(el);
  }
  arr.elements = flattened;

  // 2) BOX_LID_* => BOX_LID with LID_* keys (only if BOX_LID not already present)
  const lidMap = {
    BOX_LID_SOLID_B: "LID_SOLID_B",
    BOX_LID_FIT_UNDER_B: "LID_FIT_UNDER_B",
    BOX_LID_HEIGHT: "LID_HEIGHT",
    BOX_LID_INSET_B: "LID_INSET_B",
  };

  const hasBoxLid = arr.elements.some((e) => isPairArray(e, "BOX_LID"));
  if (!hasBoxLid) {
    let firstIdx = -1;
    const lidItems = [];
    const kept = [];

    for (let i = 0; i < arr.elements.length; i++) {
      const el = arr.elements[i];
      const key = pairKey(el);
      if (key && lidMap[key]) {
        if (firstIdx < 0) firstIdx = kept.length;
        const [, v] = getPairValues(el);
        lidItems.push(makeArray([makeAtom(lidMap[key]), cloneNode(v)]));
        continue; // drop old BOX_LID_* entry
      }
      kept.push(el);
    }

    if (lidItems.length > 0) {
      const lidBlock = makeArray([
        makeAtom("BOX_LID"),
        makeArray(lidItems),
      ]);
      kept.splice(firstIdx < 0 ? kept.length : firstIdx, 0, lidBlock);
      arr.elements = kept;
    }
  }
}

function parseComponentV2Entry(node) {
  // v2: [ "name", [ <params...> ] ]
  if (!node || node.type !== "array") return null;
  const vals = node.elements.filter(e => e.type !== "comment");
  if (vals.length !== 2) return null;
  const name = vals[0];
  const params = vals[1];
  if (!name || name.type !== "atom") return null;
  if (!String(name.text || "").trim().startsWith('"')) return null;
  if (!params || params.type !== "array") return null;
  return { nameAtom: name, paramsArray: params };
}

function pairKey(node) {
  if (!node || node.type !== "array") return null;
  const vals = node.elements.filter(e => e.type !== "comment");
  if (vals.length !== 2) return null;
  const k = vals[0];
  if (!k || k.type !== "atom") return null;
  const t = String(k.text || "").trim();
  if (!t || t.startsWith('"')) return null;
  return t;
}

function isPairArray(node, key) {
  return pairKey(node) === key;
}

function getPairValues(node) {
  const vals = node.elements.filter(e => e.type !== "comment");
  return [vals[0], vals[1]];
}

function makeAtom(text) {
  return { type: "atom", text: String(text ?? "") };
}

function makeArray(elements) {
  return { type: "array", elements: Array.isArray(elements) ? elements : [] };
}

function cloneNode(node) {
  if (!node) return makeAtom("");
  if (node.type === "atom") return makeAtom(node.text);
  if (node.type === "comment") return { type: "comment", text: node.text };
  if (node.type === "array") return makeArray(node.elements.map(cloneNode));
  return makeAtom(node.text || "");
}

function nonCommentElements(arrNode) {
  const out = [];
  for (let i = 0; i < arrNode.elements.length; i++) {
    const el = arrNode.elements[i];
    el._idx = i; // used only for comma logic at render time
    if (el.type !== "comment") out.push(el);
  }
  return out;
}

function findDataAssignmentSpan(fullText) {
  // Find: data = [ ... ];  (outside strings/comments)
  let inStr = false;
  let inLine = false;
  const isIdentChar = (c) => /[A-Za-z0-9_]/.test(c);

  for (let i = 0; i < fullText.length; i++) {
    const ch = fullText[i];
    const next = fullText[i + 1];
    if (inLine) {
      if (ch === "\n") inLine = false;
      continue;
    }
    if (!inStr && ch === "/" && next === "/") { inLine = true; i++; continue; }
    if (ch === '"') { inStr = !inStr; continue; }
    if (inStr) continue;

    // identifier "data"
    if (ch === "d" && fullText.slice(i, i + 4) === "data") {
      const before = i > 0 ? fullText[i - 1] : "";
      const after = fullText[i + 4] || "";
      if ((before && isIdentChar(before)) || (after && isIdentChar(after))) continue;

      let j = i + 4;
      while (j < fullText.length && /\s/.test(fullText[j])) j++;
      if (fullText[j] !== "=") continue;
      j++;
      while (j < fullText.length && /\s/.test(fullText[j])) j++;
      if (fullText[j] !== "[") continue;

      const arrayStart = j;
      const arrayEnd = findMatchingBracket(fullText, arrayStart);
      if (arrayEnd < 0) return null;

      // Expand replacement to cover the whole statement lines.
      const stmtLineStart = fullText.lastIndexOf("\n", i) + 1;
      const stmtLineEnd = (() => {
        // include optional semicolon and any trailing comment until end-of-line
        let k = arrayEnd + 1;
        while (k < fullText.length && /\s/.test(fullText[k]) && fullText[k] !== "\n") k++;
        if (fullText[k] === ";") k++;
        // include trailing comment
        while (k < fullText.length && fullText[k] !== "\n") k++;
        if (k < fullText.length) k++; // include newline
        return k;
      })();

      const baseIndent = (fullText.slice(stmtLineStart, i).match(/^\s*/) || [""])[0];

      const headerComment = (() => {
        // data = [ // comment
        const line = fullText.slice(stmtLineStart, fullText.indexOf("\n", stmtLineStart) >= 0 ? fullText.indexOf("\n", stmtLineStart) : stmtLineEnd);
        const idx = line.indexOf("//");
        if (idx < 0) return "";
        // keep everything after // exactly (including leading space)
        return line.slice(idx + 2);
      })();

      const footerComment = (() => {
        const stmt = fullText.slice(arrayEnd + 1, stmtLineEnd);
        const idx = stmt.indexOf("//");
        if (idx < 0) return "";
        return stmt.slice(idx + 2).replace(/\n/g, "");
      })();

      const arrayText = fullText.slice(arrayStart, arrayEnd + 1);

      return {
        stmtStart: stmtLineStart,
        stmtEnd: stmtLineEnd,
        baseIndent,
        headerComment,
        footerComment,
        arrayText,
      };
    }
  }

  return null;
}

function findMatchingBracket(s, openIdx) {
  let depth = 0;
  let inStr = false;
  let inLine = false;
  for (let i = openIdx; i < s.length; i++) {
    const ch = s[i];
    const next = s[i + 1];
    if (inLine) {
      if (ch === "\n") inLine = false;
      continue;
    }
    if (!inStr && ch === "/" && next === "/") { inLine = true; i++; continue; }
    if (ch === '"') { inStr = !inStr; continue; }
    if (inStr) continue;
    if (ch === "[") depth++;
    if (ch === "]") {
      depth--;
      if (depth === 0) return i;
    }
  }
  return -1;
}

function tokenizeScad(s) {
  const toks = [];
  let i = 0;
  while (i < s.length) {
    const ch = s[i];
    const next = s[i + 1];
    if (ch === "\n") { toks.push({ type: "newline" }); i++; continue; }
    if (/\s/.test(ch)) { i++; continue; }

    if (ch === "/" && next === "/") {
      const start = i + 2;
      let j = start;
      while (j < s.length && s[j] !== "\n") j++;
      toks.push({ type: "comment", value: s.slice(start, j) });
      i = j;
      continue;
    }

    if (ch === '"') {
      let j = i + 1;
      while (j < s.length) {
        const c = s[j];
        if (c === "\\") { j += 2; continue; }
        if (c === '"') { j++; break; }
        j++;
      }
      toks.push({ type: "string", value: s.slice(i, j) });
      i = j;
      continue;
    }

    if ("[](),;={}".includes(ch)) {
      toks.push({ type: "punct", value: ch });
      i++;
      continue;
    }

    // number
    if (/[0-9]/.test(ch) || (ch === "-" && /[0-9]/.test(next))) {
      let j = i + 1;
      while (j < s.length && /[0-9.]/.test(s[j])) j++;
      toks.push({ type: "number", value: s.slice(i, j) });
      i = j;
      continue;
    }

    // identifier
    if (/[A-Za-z_]/.test(ch)) {
      let j = i + 1;
      while (j < s.length && /[A-Za-z0-9_]/.test(s[j])) j++;
      toks.push({ type: "ident", value: s.slice(i, j) });
      i = j;
      continue;
    }

    // operator / other single char
    toks.push({ type: "other", value: ch });
    i++;
  }
  return toks;
}

function makeParser(tokens) {
  let idx = 0;

  function peek() { return tokens[idx]; }
  function next() { return tokens[idx++]; }
  function eof() { return idx >= tokens.length; }

  function skipNewlines() {
    while (!eof() && peek().type === "newline") next();
  }

  function parseArray() {
    const t = next();
    if (!t || t.type !== "punct" || t.value !== "[") throw new Error("expected [");
    const elements = [];
    const arrNode = { type: "array", elements };
    let justConsumedComma = false;

    while (!eof()) {
      skipNewlines();
      const p = peek();
      if (!p) break;
      if (p.type === "comment") {
        // If this comment appears right after the comma between the first and
        // second item of a pair ([ KEY, // comment\n [ ... ] ]), treat it as
        // a comment on the opener line.
        const nonCommentsSoFar = elements.filter(e => e.type !== "comment").length;
        if (justConsumedComma && nonCommentsSoFar === 1 && !arrNode.commentAfterFirst) {
          arrNode.commentAfterFirst = p.value;
          next();
          justConsumedComma = false;
          continue;
        }
        elements.push({ type: "comment", text: p.value });
        next();
        continue;
      }
      if (p.type === "punct" && p.value === "]") { next(); break; }
      if (p.type === "punct" && p.value === ",") { next(); continue; }

      const value = parseValue();
      justConsumedComma = false;
      skipNewlines();
      if (!eof() && peek().type === "comment") {
        value.trailingComment = peek().value;
        next();
      }
      elements.push(value);

      skipNewlines();
      if (!eof() && peek().type === "punct" && peek().value === ",") {
        next();
        justConsumedComma = true;
        continue;
      }
    }

    return arrNode;
  }

  function parseValue() {
    skipNewlines();
    const p = peek();
    if (!p) return { type: "atom", text: "" };
    if (p.type === "punct" && p.value === "[") return parseArray();

    // Collect tokens until comma/close at this array nesting, while keeping
    // nested parens/braces balanced.
    let paren = 0;
    let brace = 0;
    const parts = [];
    while (!eof()) {
      const t = peek();
      if (!t) break;
      if (t.type === "newline") { next(); continue; }
      if (t.type === "comment") break;
      if (paren === 0 && brace === 0 && t.type === "punct" && (t.value === "," || t.value === "]")) break;

      if (t.type === "punct" && t.value === "[") {
        const a = parseArray();
        parts.push(a);
        continue;
      }

      if (t.type === "punct" && t.value === "(") paren++;
      else if (t.type === "punct" && t.value === ")") paren = Math.max(0, paren - 1);
      else if (t.type === "punct" && t.value === "{") brace++;
      else if (t.type === "punct" && t.value === "}") brace = Math.max(0, brace - 1);

      parts.push({ type: "tok", text: t.value });
      next();
    }

    return { type: "atom", text: tokensToInline(parts) };
  }

  return { parseArray };
}

function tokensToInline(parts) {
  // parts are {type:"tok",text} and/or nested array nodes.
  const out = [];
  let prev = "";

  function pushToken(t) {
    const cur = t;
    const noSpaceBefore = [",", "]", ")", "}", ";", "(", "[", "{"].includes(cur);
    const noSpaceAfterPrev = ["[", "(", "{", "="].includes(prev);
    const needsSpace = out.length > 0 && !noSpaceBefore && !noSpaceAfterPrev;
    if (needsSpace) out.push(" ");
    out.push(cur);
    prev = cur;
  }

  for (const p of parts) {
    if (p.type === "tok") pushToken(p.text);
    else if (p.type === "array") pushToken(inlineArray(p));
  }

  return out.join("").trim();
}

function canInlineArray(arr) {
  for (const el of arr.elements) {
    if (el.type === "comment") return false;
    if (el.type === "array") return false;
  }
  return true;
}

function inlineArray(arr) {
  if (!canInlineArray(arr)) return "[ ... ]";
  const parts = [];
  for (const el of arr.elements) {
    if (el.type === "comment") continue;
    parts.push(String(el.text ?? "").trim());
  }
  return `[${parts.join(", ")}]`;
}

function renderEntryLines(node, indent, needsComma, outLines) {
  if (node.type === "atom") {
    // Rare inside data tables, but keep it stable.
    outLines.push(indent + node.text + (needsComma ? "," : "") + (node.trailingComment ? ` //${node.trailingComment}` : ""));
    return;
  }
  if (node.type !== "array") return;

  const vals = node.elements.filter(e => e.type !== "comment");
  const commentLines = node.elements.filter(e => e.type === "comment");
  for (const c of commentLines) {
    outLines.push(`${indent}//${c.text}`);
  }

  if (vals.length === 2) {
    const a = vals[0];
    const b = vals[1];

    // [ KEY, VALUE ]  => KV line
    if (a.type === "atom" && b.type !== "array") {
      const line = `${indent}[ ${a.text.trim()}, ${b.text.trim()} ]` + (needsComma ? "," : "") + (node.trailingComment ? ` //${node.trailingComment}` : "");
      outLines.push(line);
      return;
    }

    // [ "name", [ ... ] ]  => element entry
    if (a.type === "atom" && a.text.trim().startsWith('"') && b.type === "array") {
      outLines.push(`${indent}[ ${a.text.trim()},` + (node.commentAfterFirst ? ` //${node.commentAfterFirst}` : ""));
      renderArrayBlock(b, indent + " ".repeat(4), outLines);
      outLines.push(`${indent}]` + (needsComma ? "," : "") + (node.trailingComment ? ` //${node.trailingComment}` : ""));
      return;
    }

    // [ KEY, [a,b,c] ] => KV with array value (inline when safe)
    if (a.type === "atom" && b.type === "array") {
      const key = a.text.trim();
      if (!FORMAT_STRUCTURAL_KEYS.has(key) && canInlineArray(b)) {
        const line = `${indent}[ ${key}, ${inlineArray(b)} ]` + (needsComma ? "," : "") + (node.trailingComment ? ` //${node.trailingComment}` : "");
        outLines.push(line);
        return;
      }

      // Structural-ish block (BOX_COMPONENT, BOX_LID, LABEL, and unknown pair blocks)
      outLines.push(`${indent}[ ${key},` + (node.commentAfterFirst ? ` //${node.commentAfterFirst}` : ""));
      renderArrayBlock(b, indent + " ".repeat(4), outLines);
      outLines.push(`${indent}]` + (needsComma ? "," : "") + (node.trailingComment ? ` //${node.trailingComment}` : ""));
      return;
    }
  }

  // Fallback: keep as a multi-line array block
  renderArrayBlock(node, indent, outLines, needsComma);
}

function renderArrayBlock(arr, indent, outLines, needsCommaForClose = false) {
  outLines.push(`${indent}[`);

  for (const el of arr.elements) {
    if (el.type === "comment") {
      outLines.push(`${indent}${" ".repeat(4)}//${el.text}`);
      continue;
    }
    renderEntryLines(el, indent + " ".repeat(4), true, outLines);
  }

  outLines.push(`${indent}]` + (needsCommaForClose ? "," : ""));
}

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
  const formatted = formatScadOnLoad(scadText);
  scadText = formatted.text;
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

module.exports = { importScad, reimportBlock, formatScadOnLoad };
