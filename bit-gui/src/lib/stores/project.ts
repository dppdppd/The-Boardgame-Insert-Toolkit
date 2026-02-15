import { writable } from "svelte/store";
import schema from "../../../schema/bit.schema.json";
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
export const schemaData = schema;
