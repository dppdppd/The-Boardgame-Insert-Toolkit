import { writable, get } from "svelte/store";
import { createDefaultNode } from "../schema";
import fixture from "../../../schema/fixture.json";

export interface KVParam {
  key: string;
  value: any;
}

export interface Element {
  name: string;
  type: string;
  params: KVParam[];
}

export interface Project {
  version: number;
  globals: Record<string, any>;
  data: Element[];
}

export const project = writable<Project>(fixture as Project);

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
