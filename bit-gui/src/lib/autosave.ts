import { get } from "svelte/store";
import { project } from "./stores/project";
import { generateScad } from "./scad";

let filePath: string | null = null;
let needsBackup = false;
let debounceTimer: ReturnType<typeof setTimeout> | null = null;
let saveStatus: (msg: string) => void = () => {};

const DEBOUNCE_MS = 300;

export function setFilePath(path: string) {
  filePath = path;
}

export function getFilePath(): string | null {
  return filePath;
}

export function setNeedsBackup(val: boolean) {
  needsBackup = val;
}

export function onSaveStatus(cb: (msg: string) => void) {
  saveStatus = cb;
}

async function doSave() {
  if (!filePath) return;
  const bitgui = (window as any).bitgui;
  if (!bitgui?.saveFile) return;

  const scadText = generateScad(get(project));
  saveStatus("Saving...");
  const result = await bitgui.saveFile(filePath, scadText, needsBackup);
  if (result.ok) {
    needsBackup = false; // Only backup once
    saveStatus(`Saved ${new Date().toLocaleTimeString()}`);
  } else {
    saveStatus(`Save failed: ${result.error}`);
  }
}

export function triggerSave() {
  if (debounceTimer) clearTimeout(debounceTimer);
  debounceTimer = setTimeout(doSave, DEBOUNCE_MS);
}

export function startAutosave() {
  let first = true;
  project.subscribe(() => {
    if (first) { first = false; return; }
    triggerSave();
  });
}
