import schemaJson from "../../schema/bit.schema.json";

export const schema = schemaJson;

export interface KeyDef {
  type: string;
  default?: any;
  values?: string[];
  help?: string;
  child_context?: string;
  contexts?: string[];
}

/** Get all key definitions for a context */
export function getContextKeys(context: string): Record<string, KeyDef> {
  return (schema.contexts as any)[context]?.keys || {};
}

/** Check if a key is a nested/optional type (table or table_list) */
export function isOptionalNode(keyDef: KeyDef): boolean {
  return keyDef.type === "table" || keyDef.type === "table_list";
}

/**
 * Given existing params and a context, return a full list of params
 * with all scalar keys filled from schema defaults. Optional sub-nodes
 * (table, table_list) are only included if already present in params.
 */
export function mergeWithDefaults(
  params: { key: string; value: any }[],
  context: string,
  elementType?: string,
): { key: string; value: any }[] {
  const keys = getContextKeys(context);
  const existingMap = new Map(params.map((p) => [p.key, p.value]));
  const result: { key: string; value: any }[] = [];

  for (const [key, def] of Object.entries(keys)) {
    // Filter by element type context if specified
    if (def.contexts && elementType && !def.contexts.includes(elementType)) {
      continue;
    }

    if (existingMap.has(key)) {
      result.push({ key, value: existingMap.get(key) });
    } else if (!isOptionalNode(def)) {
      // Add scalar keys with their defaults
      result.push({ key, value: def.default ?? null });
    }
    // Optional nodes (table, table_list) are omitted unless already present
  }

  return result;
}

/**
 * Get the list of optional sub-nodes that can be added to a context.
 * Returns keys that are table/table_list and not yet present.
 */
export function getAddableNodes(
  params: { key: string; value: any }[],
  context: string,
  elementType?: string,
): { key: string; def: KeyDef }[] {
  const keys = getContextKeys(context);
  const existingKeys = new Set(params.map((p) => p.key));
  const addable: { key: string; def: KeyDef }[] = [];

  for (const [key, def] of Object.entries(keys)) {
    if (def.contexts && elementType && !def.contexts.includes(elementType)) {
      continue;
    }
    // table_list can always have more items added (via the [+] on its header)
    // table can only be added once
    if (def.type === "table" && !existingKeys.has(key)) {
      addable.push({ key, def });
    }
  }

  return addable;
}

/**
 * Create a new sub-node with all defaults for a given child context.
 */
export function createDefaultNode(childContext: string): { key: string; value: any }[] {
  const keys = getContextKeys(childContext);
  const params: { key: string; value: any }[] = [];

  for (const [key, def] of Object.entries(keys)) {
    if (!isOptionalNode(def) && def.default !== undefined) {
      params.push({ key, value: structuredClone(def.default) });
    }
  }

  return params;
}
