import type { Project, Line } from "./stores/project";

/**
 * Generate SCAD output from line-based project.
 *
 * Recognized lines (include, marker, makeall, global, kv) are regenerated.
 * Structural lines (open, close) and raw lines are emitted verbatim.
 */
export function generateScad(project: Project): string {
  const out: string[] = [];

  // Always start with marker + v4 includes
  out.push("// BITGUI");
  out.push("include <boardgame_insert_toolkit_lib.4.scad>;");

  for (const line of project.lines) {
    switch (line.kind) {
      case "include":
      case "marker":
        // Skip — regenerated above.
        break;
      case "makeall":
        // Skip — regenerated at end.
        break;
      case "global":
        if (line.globalKey && typeof line.globalValue === "boolean") {
          out.push(`${line.globalKey} = ${line.globalValue ? "true" : "false"};`);
        } else if (line.globalKey && typeof line.globalValue === "number") {
          out.push(`${line.globalKey} = ${line.globalValue};`);
        } else if (line.globalKey) {
          out.push(`${line.globalKey} = "${line.globalValue ?? ""}";`);
        }
        break;
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

  out.push("MakeAll();");
  return out.join("\n");
}
