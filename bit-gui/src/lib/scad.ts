import { getContextKeys, type KeyDef } from "./schema";
import type { Project, Element, KVParam } from "./stores/project";

/** Map GUI enum constants to OpenSCAD constant names */
const ENUM_MAP: Record<string, string> = {
  BOX: "BOX",
  DIVIDERS: "DIVIDERS",
  SPACER: "SPACER",
  SQUARE: "SQUARE",
  HEX: "HEX",
  HEX2: "HEX2",
  OCT: "OCT",
  OCT2: "OCT2",
  ROUND: "ROUND",
  FILLET: "FILLET",
  INTERIOR: "INTERIOR",
  EXTERIOR: "EXTERIOR",
  BOTH: "BOTH",
  FRONT: "FRONT",
  BACK: "BACK",
  LEFT: "LEFT",
  RIGHT: "RIGHT",
  FRONT_WALL: "FRONT_WALL",
  BACK_WALL: "BACK_WALL",
  LEFT_WALL: "LEFT_WALL",
  RIGHT_WALL: "RIGHT_WALL",
  CENTER: "CENTER",
  BOTTOM: "BOTTOM",
  AUTO: "AUTO",
  MAX: "MAX",
};

function isDefault(key: string, value: any, context: string): boolean {
  if (isExpr(value)) return false; // Expressions are never default
  const keys = getContextKeys(context);
  const def = (keys as any)[key] as KeyDef | undefined;
  if (!def || def.default === undefined) return false;
  return JSON.stringify(value) === JSON.stringify(def.default);
}

function isExpr(value: any): boolean {
  return value && typeof value === "object" && "__expr" in value;
}

function formatValue(value: any, keyType?: string): string {
  // Raw OpenSCAD expression — emit verbatim
  if (isExpr(value)) return value.__expr;

  if (value === true) return "true";
  if (value === false) return "false";
  if (typeof value === "number") return String(value);
  if (typeof value === "string") {
    // Check if it's an enum constant
    if (ENUM_MAP[value]) return ENUM_MAP[value];
    // Schema type "string" means it's a real string — quote it
    // Otherwise treat as raw expression
    if (keyType === "string" || keyType === "string_list") return `"${value}"`;
    // If it looks like a known constant, don't quote
    if (ENUM_MAP[value]) return ENUM_MAP[value];
    // Default: quote it (safe for most values)
    return `"${value}"`;
  }
  if (Array.isArray(value)) {
    if (value.length > 0 && typeof value[0] === "object" && !isExpr(value[0])) {
      // Nested table — shouldn't reach here
      return "[]";
    }
    const items = value.map((v) => {
      if (isExpr(v)) return v.__expr;
      if (typeof v === "string" && ENUM_MAP[v]) return ENUM_MAP[v];
      if (typeof v === "string") return `"${v}"`;
      if (typeof v === "boolean") return v ? "true" : "false";
      return String(v);
    });
    return `[${items.join(", ")}]`;
  }
  return String(value);
}

function indent(level: number): string {
  return "    ".repeat(level);
}

function emitParams(
  params: KVParam[],
  context: string,
  level: number,
  elementType?: string,
): string[] {
  const lines: string[] = [];
  const keys = getContextKeys(context);

  for (const param of params) {
    const def = (keys as any)[param.key] as KeyDef | undefined;
    if (!def) continue;

    // Skip if value matches default
    if (isDefault(param.key, param.value, context)) continue;

    // Filter by element type context
    if (def.contexts && elementType && !def.contexts.includes(elementType)) {
      continue;
    }

    if (def.type === "table_list") {
      // BOX_COMPONENT — list of component tables
      const childContext = def.child_context || context;
      for (const componentParams of param.value) {
        const childLines = emitParams(componentParams, childContext, level + 2);
        if (childLines.length > 0) {
          lines.push(`${indent(level)}[ ${param.key},`);
          lines.push(`${indent(level + 1)}[`);
          lines.push(...childLines);
          lines.push(`${indent(level + 1)}]`);
          lines.push(`${indent(level)}],`);
        } else {
          // Component with all defaults — still emit it (it defines a compartment)
          lines.push(`${indent(level)}[ ${param.key}, [] ],`);
        }
      }
    } else if (def.type === "table") {
      // BOX_LID, LABEL — single nested table
      const childContext = def.child_context || context;
      const childLines = emitParams(param.value, childContext, level + 2);
      lines.push(`${indent(level)}[ ${param.key},`);
      lines.push(`${indent(level + 1)}[`);
      lines.push(...childLines);
      lines.push(`${indent(level + 1)}]`);
      lines.push(`${indent(level)}],`);
    } else {
      // Scalar key-value
      lines.push(
        `${indent(level)}[ ${param.key}, ${formatValue(param.value, def.type)} ],`,
      );
    }
  }

  return lines;
}

function emitElement(element: Element, level: number): string[] {
  const lines: string[] = [];
  const context = element.type === "DIVIDERS" ? "divider" : "element";

  lines.push(`${indent(level)}[ "${element.name}",`);
  lines.push(`${indent(level + 1)}[`);

  // Always emit TYPE
  lines.push(
    `${indent(level + 2)}[ TYPE, ${ENUM_MAP[element.type] || element.type} ],`,
  );

  // Emit non-default params
  const paramLines = emitParams(element.params, context, level + 2, element.type);
  lines.push(...paramLines);

  lines.push(`${indent(level + 1)}]`);
  lines.push(`${indent(level)}],`);

  return lines;
}

const DEFAULT_PREAMBLE = `include <lib/boardgame_insert_toolkit_lib.4.scad>;
include <lib/bit_functions_lib.4.scad>;
`;

const DEFAULT_POSTAMBLE = `MakeAll();
`;

export function generateScad(project: Project): string {
  const out: string[] = [];
  const preamble = project.preamble || DEFAULT_PREAMBLE;
  const postamble = project.postamble || DEFAULT_POSTAMBLE;

  out.push("// BITGUI");
  out.push("");
  out.push(preamble.trimEnd());
  out.push("");

  // Globals
  out.push(
    `g_b_print_lid = ${project.globals.g_b_print_lid ? "true" : "false"};`,
  );
  out.push(
    `g_b_print_box = ${project.globals.g_b_print_box ? "true" : "false"};`,
  );
  out.push(
    `g_isolated_print_box = "${project.globals.g_isolated_print_box || ""}";`,
  );
  out.push("");

  // Data array
  out.push("data = [");
  for (const element of project.data) {
    if ((element as any).__expr) {
      // Expression element — emit verbatim
      out.push(`${indent(1)}${(element as any).__expr},`);
    } else {
      out.push(...emitElement(element, 1));
    }
  }
  out.push("];");
  out.push("");
  out.push(postamble.trimEnd());
  out.push("");

  return out.join("\n");
}
