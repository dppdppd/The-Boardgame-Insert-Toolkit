import { writable } from "svelte/store";

/** A single line in the SCAD file. */
export interface Line {
  /** The original raw text of this line. */
  raw: string;
  /**
   * What we recognised this line as:
   *  - "raw"     : unrecognised → editable text input
   *  - "include" : BIT lib include → badge (regenerated as v4)
   *  - "global"  : recognized global → inline control
   *  - "marker"  : // BGSD → badge (regenerated)
   *  - "makeall" : MakeAll(); → badge (regenerated)
   *  - "kv"      : recognized [ KEY, VALUE ] → native control
   *  - "open"    : structural opening bracket
   *  - "close"   : structural closing bracket
   */
  kind: string;
  /** Bracket nesting depth (0 = top level). */
  depth: number;
  /** For "open"/"close": structural role (data, object, params, label, lid, feature_list, feature, etc.) */
  role?: string;
  /** For "open"/"close": display label */
  label?: string;
  /** For "global" lines */
  globalKey?: string;
  globalValue?: any;
  /** True when global came from v4 inline [ G_*, value ] inside data[] */
  inlineGlobal?: boolean;
  /** For "kv" lines: recognized BIT key-value pair */
  kvKey?: string;
  kvValue?: any;
  /** Trailing comment (without the //) */
  comment?: string;
  /** For "open": true when this line opens two bracket levels (e.g. `[ "name", [`) */
  mergedOpen?: boolean;
  /** For "close": true when this line closes two bracket levels (e.g. `]],`) */
  mergedClose?: boolean;
  /** For data open/close and makeall lines: the scene variable name (e.g. "data", "scene_1") */
  varName?: string;
}

export interface Project {
  version: number;
  lines: Line[];
  hasMarker?: boolean;
  /** Detected library profile ID (e.g. "bit") */
  libraryProfile?: string;
  /** The include filename detected from the file (e.g. "boardgame_insert_toolkit_lib.4.scad") */
  libraryInclude?: string;
}

const emptyProject: Project = {
  version: 1,
  lines: [],
};

export const project = writable<Project>(emptyProject);

// --- Line operations ---

export function updateLineRaw(index: number, raw: string) {
  project.update((p) => {
    p.lines[index] = { ...p.lines[index], raw };
    return { ...p };
  });
}

/** Replace a line entirely (e.g. after re-classification). */
export function replaceLine(index: number, line: Line) {
  project.update((p) => {
    const existing = p.lines[index];
    // Cannot replace a structural bracket with a non-bracket.
    if ((existing?.kind === "open" || existing?.kind === "close") &&
        line.kind !== "open" && line.kind !== "close") return p;
    p.lines[index] = line;
    return { ...p };
  });
}

export function deleteLine(index: number) {
  project.update((p) => {
    const line = p.lines[index];
    // Structural brackets cannot be deleted individually.
    if (line?.kind === "open" || line?.kind === "close") return p;
    p.lines = p.lines.filter((_, i) => i !== index);
    return { ...p };
  });
}

/**
 * Delete a matched block: from the open bracket at `index` through its matching close.
 * The last remaining data block cannot be deleted.
 */
export function deleteBlock(index: number) {
  project.update((p) => {
    const line = p.lines[index];
    if (line?.kind !== "open") return p;
    if (line.role === "data") {
      // Don't delete the last scene
      const sceneCount = p.lines.filter(l => l.kind === "open" && l.role === "data").length;
      if (sceneCount <= 1) return p;
    }

    // Find matching close by tracking depth (merged brackets count as 2)
    let depth = 0;
    let closeIdx = -1;
    for (let i = index; i < p.lines.length; i++) {
      if (p.lines[i].kind === "open") depth += p.lines[i].mergedOpen ? 2 : 1;
      if (p.lines[i].kind === "close") {
        depth -= p.lines[i].mergedClose ? 2 : 1;
        if (depth <= 0) { closeIdx = i; break; }
      }
    }
    if (closeIdx < 0) return p; // unmatched — shouldn't happen

    // Also remove associated makeall line immediately after the close
    let endIdx = closeIdx + 1;
    if (line.role === "data" && endIdx < p.lines.length &&
        p.lines[endIdx].kind === "makeall" && p.lines[endIdx].varName === line.varName) {
      endIdx++;
    }

    p.lines.splice(index, endIdx - index);
    return { ...p };
  });
}

export function insertLine(index: number, line: Line) {
  project.update((p) => {
    p.lines.splice(index, 0, line);
    return { ...p };
  });
}

/** Update a global line's value. */
export function updateGlobal(index: number, value: any) {
  project.update((p) => {
    const line = p.lines[index];
    if (line?.kind !== "global" || !line.globalKey) return p;
    line.globalValue = value;
    line.raw = formatGlobalRaw(line.globalKey, value, line.inlineGlobal, line.raw);
    return { ...p };
  });
}

/** Update a global line's value, or delete if it matches the schema default. */
export function updateGlobalWithDefault(index: number, value: any, schemaDefault: any) {
  project.update((p) => {
    const line = p.lines[index];
    if (line?.kind !== "global" || !line.globalKey) return p;
    if (schemaDefault !== undefined && JSON.stringify(value) === JSON.stringify(schemaDefault)) {
      p.lines.splice(index, 1);
      return { ...p };
    }
    line.globalValue = value;
    line.raw = formatGlobalRaw(line.globalKey, value, line.inlineGlobal, line.raw);
    return { ...p };
  });
}

/** Materialize a virtual global: insert a kind:"global" line before `beforeIndex`. */
export function materializeGlobal(beforeIndex: number, key: string, value: any) {
  project.update((p) => {
    const raw = formatInlineGlobalRaw(key, value);
    p.lines.splice(beforeIndex, 0, { raw, kind: "global", depth: 1, globalKey: key, globalValue: value, inlineGlobal: true });
    return { ...p };
  });
}

function formatGlobalRaw(key: string, value: any, inline?: boolean, existingRaw?: string): string {
  if (inline) {
    const indent = (existingRaw ?? "").match(/^(\s*)/)?.[1] ?? "    ";
    return formatInlineGlobalRawWithIndent(key, value, indent);
  }
  if (typeof value === "boolean") return `${key} = ${value ? "true" : "false"};`;
  if (typeof value === "number") return `${key} = ${value};`;
  return `${key} = "${value}";`;
}

function formatInlineGlobalRaw(key: string, value: any): string {
  return formatInlineGlobalRawWithIndent(key, value, "    ");
}

function formatInlineGlobalRawWithIndent(key: string, value: any, indent: string): string {
  if (typeof value === "boolean") return `${indent}[ ${key}, ${value} ],`;
  if (typeof value === "number") return `${indent}[ ${key}, ${value} ],`;
  return `${indent}[ ${key}, "${value ?? ""}" ],`;
}

/** Update a kv line's value. If the new value equals the schema default, delete the line. */
export function updateKv(index: number, value: any, schemaDefault?: any) {
  project.update((p) => {
    const line = p.lines[index];
    if (line?.kind !== "kv" || !line.kvKey) return p;

    // If value matches default, dematerialize (delete the line)
    if (schemaDefault !== undefined && JSON.stringify(value) === JSON.stringify(schemaDefault)) {
      p.lines.splice(index, 1);
      return { ...p };
    }

    line.kvValue = value;
    const indent = line.raw.match(/^(\s*)/)?.[1] || "";
    line.raw = `${indent}[ ${line.kvKey}, ${formatKvValue(value)} ],`;
    return { ...p };
  });
}

/**
 * Materialize a virtual default row: insert a real kv line before `beforeIndex`
 * at the given depth.
 */
export function materializeKv(beforeIndex: number, key: string, value: any, depth: number) {
  project.update((p) => {
    const indent = "    ".repeat(depth);
    const raw = `${indent}[ ${key}, ${formatKvValue(value)} ],`;
    p.lines.splice(beforeIndex, 0, { raw, kind: "kv", depth, kvKey: key, kvValue: value });
    return { ...p };
  });
}

/**
 * Replace a contiguous run of lines [startIndex..startIndex+count) with new lines.
 */
export function spliceLines(startIndex: number, count: number, newLines: Line[]) {
  project.update((p) => {
    p.lines.splice(startIndex, count, ...newLines);
    return { ...p };
  });
}

/** Update a line's trailing comment. */
export function updateComment(index: number, comment: string) {
  project.update((p) => {
    const line = p.lines[index];
    if (!line) return p;
    line.comment = comment || undefined;
    // Rebuild raw: strip old comment, append new one
    const stripped = line.raw.replace(/\s*\/\/.*$/, "");
    line.raw = comment ? `${stripped} // ${comment}` : stripped;
    return { ...p };
  });
}

/** Rename a scene: updates open line, matching close line, and any makeall lines referencing the old name. */
export function updateSceneName(openIndex: number, newName: string) {
  project.update((p) => {
    const openLine = p.lines[openIndex];
    if (!openLine || openLine.kind !== "open" || openLine.role !== "data") return p;
    const oldName = openLine.varName || "data";
    if (newName === oldName) return p;

    // Update the open line
    openLine.varName = newName;
    openLine.label = newName;
    openLine.raw = openLine.raw.replace(/^\s*\S+\s*=/, `${newName} =`);

    // Find and update the matching close line
    let depth = 0;
    for (let i = openIndex; i < p.lines.length; i++) {
      if (p.lines[i].kind === "open") depth += p.lines[i].mergedOpen ? 2 : 1;
      if (p.lines[i].kind === "close") {
        depth -= p.lines[i].mergedClose ? 2 : 1;
        if (depth <= 0) {
          p.lines[i].varName = newName;
          p.lines[i].label = newName;
          break;
        }
      }
    }

    // Update any makeall lines that referenced the old name
    for (const line of p.lines) {
      if (line.kind === "makeall" && line.varName === oldName) {
        line.varName = newName;
        line.raw = `Make(${newName});`;
      }
    }

    return { ...p };
  });
}

/** Insert a new empty scene (open + close + makeall) after the given line index. */
export function addScene(afterIndex: number, sceneName: string) {
  project.update((p) => {
    const lines: Line[] = [
      { raw: `${sceneName} = [`, kind: "open", depth: 0, role: "data", label: sceneName, varName: sceneName },
      { raw: "];", kind: "close", depth: 0, role: "data", label: sceneName, varName: sceneName },
      { raw: `Make(${sceneName});`, kind: "makeall", depth: 0, varName: sceneName },
    ];
    p.lines.splice(afterIndex + 1, 0, ...lines);
    return { ...p };
  });
}

function formatKvValue(value: any): string {
  if (value === true) return "true";
  if (value === false) return "false";
  if (typeof value === "number") return String(value);
  if (typeof value === "string") {
    // Check for known constants
    const CONSTANTS = new Set([
      "BOX","DIVIDERS","SPACER","SQUARE","HEX","HEX2","OCT","OCT2",
      "ROUND","FILLET","INTERIOR","EXTERIOR","BOTH","FRONT","BACK",
      "LEFT","RIGHT","FRONT_WALL","BACK_WALL","LEFT_WALL","RIGHT_WALL",
      "CENTER","BOTTOM","AUTO","MAX",
    ]);
    if (CONSTANTS.has(value) || /^[A-Z][A-Z0-9_]*$/.test(value)) return value;
    return `"${value}"`;
  }
  if (Array.isArray(value)) {
    return `[${value.map(formatKvValue).join(", ")}]`;
  }
  return String(value);
}
