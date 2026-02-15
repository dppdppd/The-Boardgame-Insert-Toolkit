import { writable, get } from "svelte/store";
import { createDefaultNode } from "../schema";

export interface KVParam {
  key: string;
  value: any;
}

export interface Element {
  name: string;
  type: string;
  params: KVParam[];
  __expr?: string; // Raw expression element (not editable)
}

export interface Project {
  version: number;
  globals: Record<string, any>;
  data: Element[];
  preamble?: string;
  postamble?: string;
  hasMarker?: boolean;
}

const emptyProject: Project = {
  version: 1,
  globals: { g_b_print_lid: true, g_b_print_box: true, g_isolated_print_box: "" },
  data: [],
};

export const project = writable<Project>(emptyProject);

/** Update a param value at a path within the project.
 *  path is [elementIndex, ...nested keys/indices] */
export function updateParam(
  elementIndex: number,
  paramPath: (string | number)[],
  value: any,
) {
  project.update((p) => {
    let params = p.data[elementIndex].params;

    // Walk the path to find the target param
    for (let i = 0; i < paramPath.length - 1; i++) {
      const seg = paramPath[i];
      if (typeof seg === "string") {
        const found = params.find((p) => p.key === seg);
        if (!found) return p;
        if (Array.isArray(found.value) && typeof paramPath[i + 1] === "number") {
          // table_list: next segment is an index into the list
          params = found.value[paramPath[i + 1] as number];
          i++; // skip the index segment
        } else {
          params = found.value;
        }
      }
    }

    const lastKey = paramPath[paramPath.length - 1];
    if (typeof lastKey === "string") {
      const target = params.find((p) => p.key === lastKey);
      if (target) {
        target.value = value;
      } else {
        params.push({ key: lastKey, value });
      }
    }

    return { ...p };
  });
}

/** Add an element */
export function addElement(type: string = "BOX") {
  project.update((p) => {
    const name = `box ${p.data.length + 1}`;
    const params: KVParam[] = [];
    p.data = [...p.data, { name, type, params }];
    return { ...p };
  });
}

/** Delete an element */
export function deleteElement(index: number) {
  project.update((p) => {
    p.data = p.data.filter((_, i) => i !== index);
    return { ...p };
  });
}

/** Rename an element */
export function renameElement(index: number, name: string) {
  project.update((p) => {
    p.data[index].name = name;
    return { ...p };
  });
}

/** Add an optional sub-node (BOX_LID, LABEL, etc.) to an element */
export function addSubNode(
  elementIndex: number,
  key: string,
  childContext: string,
  paramPath?: (string | number)[],
) {
  project.update((p) => {
    let params = p.data[elementIndex].params;

    // Navigate to the parent if paramPath is given
    if (paramPath) {
      for (let i = 0; i < paramPath.length; i++) {
        const seg = paramPath[i];
        if (typeof seg === "string") {
          const found = params.find((p) => p.key === seg);
          if (!found) return p;
          if (Array.isArray(found.value) && typeof paramPath[i + 1] === "number") {
            params = found.value[paramPath[i + 1] as number];
            i++;
          } else {
            params = found.value;
          }
        }
      }
    }

    const defaults = createDefaultNode(childContext);
    params.push({ key, value: defaults });
    return { ...p };
  });
}

/** Add a new component to a BOX_COMPONENT table_list */
export function addComponent(elementIndex: number) {
  project.update((p) => {
    const params = p.data[elementIndex].params;
    let comp = params.find((p) => p.key === "BOX_COMPONENT");
    if (!comp) {
      comp = { key: "BOX_COMPONENT", value: [] };
      params.push(comp);
    }
    const defaults = createDefaultNode("component");
    comp.value = [...comp.value, defaults];
    return { ...p };
  });
}

/** Delete a component from BOX_COMPONENT */
export function deleteComponent(elementIndex: number, componentIndex: number) {
  project.update((p) => {
    const comp = p.data[elementIndex].params.find(
      (p) => p.key === "BOX_COMPONENT",
    );
    if (comp) {
      comp.value = comp.value.filter((_: any, i: number) => i !== componentIndex);
    }
    return { ...p };
  });
}

/** Move an element up or down */
export function moveElement(index: number, direction: -1 | 1) {
  project.update((p) => {
    const target = index + direction;
    if (target < 0 || target >= p.data.length) return p;
    const tmp = p.data[index];
    p.data[index] = p.data[target];
    p.data[target] = tmp;
    return { ...p };
  });
}

/** Move a component up or down within BOX_COMPONENT */
export function moveComponent(elementIndex: number, componentIndex: number, direction: -1 | 1) {
  project.update((p) => {
    const comp = p.data[elementIndex].params.find((p) => p.key === "BOX_COMPONENT");
    if (!comp) return p;
    const target = componentIndex + direction;
    if (target < 0 || target >= comp.value.length) return p;
    const tmp = comp.value[componentIndex];
    comp.value[componentIndex] = comp.value[target];
    comp.value[target] = tmp;
    return { ...p };
  });
}

/** Duplicate an element */
export function duplicateElement(index: number) {
  project.update((p) => {
    const copy = structuredClone(p.data[index]);
    if (!copy.__expr) copy.name = copy.name + " copy";
    p.data.splice(index + 1, 0, copy);
    return { ...p };
  });
}

/** Duplicate a component within BOX_COMPONENT */
export function duplicateComponent(elementIndex: number, componentIndex: number) {
  project.update((p) => {
    const comp = p.data[elementIndex].params.find((p) => p.key === "BOX_COMPONENT");
    if (!comp) return p;
    const copy = structuredClone(comp.value[componentIndex]);
    comp.value.splice(componentIndex + 1, 0, copy);
    return { ...p };
  });
}

/** Remove an optional sub-node (BOX_LID, LABEL) from params */
export function removeSubNode(
  elementIndex: number,
  key: string,
  paramPath?: (string | number)[],
) {
  project.update((p) => {
    let params = p.data[elementIndex].params;

    if (paramPath) {
      for (let i = 0; i < paramPath.length; i++) {
        const seg = paramPath[i];
        if (typeof seg === "string") {
          const found = params.find((p) => p.key === seg);
          if (!found) return p;
          if (Array.isArray(found.value) && typeof paramPath[i + 1] === "number") {
            params = found.value[paramPath[i + 1] as number];
            i++;
          } else {
            params = found.value;
          }
        }
      }
    }

    const idx = params.findIndex((p) => p.key === key);
    if (idx >= 0) params.splice(idx, 1);
    return { ...p };
  });
}
