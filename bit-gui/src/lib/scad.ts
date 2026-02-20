import type { Project, Line } from "./stores/project";

/**
 * Generate SCAD output from line-based project.
 *
 * Recognized lines (include, marker, makeall, global, kv) are regenerated.
 * Structural lines (open, close) and raw lines are emitted verbatim.
 */
export function generateScad(project: Project): string {
  const out: string[] = [];

  // Always start with marker + library include
  out.push("// BGSD");
  out.push(`include <${project.libraryInclude || "boardgame_insert_toolkit_lib.4.scad"}>;`);

  for (const line of project.lines) {
    switch (line.kind) {
      case "include":
      case "marker":
        // Skip — regenerated above.
        break;
      case "makeall":
        out.push(`Make(${line.varName || "data"});`);
        break;
      case "global": {
        // v4 format: emit as [ G_KEY, value ] inside data array
        const gk = line.globalKey ?? "";
        const indent = (line.raw ?? "").match(/^(\s*)/)?.[1] ?? "    ";
        if (typeof line.globalValue === "boolean") {
          out.push(`${indent}[ ${gk}, ${line.globalValue} ],`);
        } else if (typeof line.globalValue === "number") {
          out.push(`${indent}[ ${gk}, ${line.globalValue} ],`);
        } else if (gk) {
          out.push(`${indent}[ ${gk}, "${line.globalValue ?? ""}" ],`);
        }
        break;
      }
      case "kv":
      case "open":
      case "close":
      case "raw":
      default:
        // Emit verbatim — kv lines have their raw regenerated on edit via updateKv().
        out.push(line.raw);
        break;
    }
  }

  return out.join("\n");
}
