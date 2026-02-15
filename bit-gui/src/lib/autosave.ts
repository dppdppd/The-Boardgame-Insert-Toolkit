import { get } from "svelte/store";
import { project } from "./stores/project";
import { generateScad } from "./scad";

let projectDir: string | null = null;
let debounceTimer: ReturnType<typeof setTimeout> | null = null;
let saveStatus: (msg: string) => void = () => {};

const DEBOUNCE_MS = parseInt(
  (typeof window !== "undefined" && (window as any).__env?.BITGUI_AUTOSAVE_DEBOUNCE_MS) || "300",
  10,
);

export function setProjectDir(dir: string) {
  projectDir = dir;
}

export function getProjectDir(): string | null {
  return projectDir;
}

export function onSaveStatus(cb: (msg: string) => void) {
  saveStatus = cb;
}

async function doSave() {
  if (!projectDir) return;

  const bitgui = (window as any).bitgui;
  if (!bitgui?.saveProject) return;

  const p = get(project);
  const projectJson = JSON.stringify(p, null, 2);
  const scadText = generateScad(p);

  saveStatus("Saving...");
  const result = await bitgui.saveProject(projectDir, projectJson, scadText);
  if (result.ok) {
    const now = new Date().toLocaleTimeString();
    saveStatus(`Saved ${now}`);
  } else {
    saveStatus(`Save failed: ${result.error}`);
  }
}

export function triggerSave() {
  if (debounceTimer) clearTimeout(debounceTimer);
  debounceTimer = setTimeout(doSave, DEBOUNCE_MS);
}

/** Start watching the store for changes */
export function startAutosave() {
  let first = true;
  project.subscribe(() => {
    // Skip the initial subscription fire
    if (first) {
      first = false;
      return;
    }
    triggerSave();
  });
}
