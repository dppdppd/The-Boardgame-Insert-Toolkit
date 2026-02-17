<script lang="ts">
  import { onMount } from "svelte";
  import {
    project,
    updateLineRaw,
    replaceLine,
    deleteLine,
    deleteBlock,
    updateGlobal,
    updateKv,
    updateComment,
    materializeKv,
    insertLine,
    spliceLines,
    type Line,
  } from "./lib/stores/project";
  import { generateScad } from "./lib/scad";
  import { startAutosave, onSaveStatus, setFilePath, getFilePath, setNeedsBackup, saveNow, triggerSave } from "./lib/autosave";
  import { schema } from "./lib/schema";
  import tooltips from "./lib/tooltips/en.json";

  let intentText = $state("");
  let showIntent = $state(false);
  let statusMsg = $state("No file open");

  let scadOutput = $derived(generateScad($project));

  onSaveStatus((msg: string) => { statusMsg = msg; });

  function handleLoad(payload: any) {
    const { data, filePath } = payload;
    project.set(data);
    setFilePath(filePath);
    setNeedsBackup(!data.hasMarker);
    const name = filePath.replace(/.*[/\\]/, "");
    statusMsg = data.hasMarker ? name : `${name} (will backup .bak on first save)`;
  }

  onMount(async () => {
    showIntent = !!(window as any).bitgui?.harness;
    startAutosave();
    const bitgui = (window as any).bitgui;
    if (bitgui?.onMenuNew) bitgui.onMenuNew(newFile);
    if (bitgui?.onMenuOpen) bitgui.onMenuOpen(handleLoad);
    if (bitgui?.onMenuSaveAs) bitgui.onMenuSaveAs(saveFileAs);
    if (bitgui?.onMenuOpenInOpenScad) bitgui.onMenuOpenInOpenScad(openInOpenScad);

    // Check for pending auto-load
    let loaded = false;
    for (let i = 0; i < 50; i++) {
      const pending = await (window as any).bitgui?.getPendingLoad?.();
      if (pending) { handleLoad(pending); loaded = true; break; }
      await new Promise(r => setTimeout(r, 200));
    }
    // If nothing was auto-loaded, start with a new project
    if (!loaded) newFile();
  });

  function newFile() {
    project.set({ version: 1, lines: [
      { raw: "g_b_print_lid = true;", kind: "global", depth: 0, globalKey: "g_b_print_lid", globalValue: true },
      { raw: "g_b_print_box = true;", kind: "global", depth: 0, globalKey: "g_b_print_box", globalValue: true },
      { raw: 'g_isolated_print_box = "";', kind: "global", depth: 0, globalKey: "g_isolated_print_box", globalValue: "" },
      { raw: "data = [", kind: "open", depth: 0, role: "data", label: "data" },
      { raw: "];", kind: "close", depth: 0, role: "data", label: "data" },
    ], hasMarker: false });
    setFilePath(""); setNeedsBackup(false); statusMsg = "New file";
  }

  async function openFile() {
    const bitgui = (window as any).bitgui;
    if (!bitgui?.openFile) return;
    const res = await bitgui.openFile();
    if (!res.ok) { if (res.error) statusMsg = `Open failed: ${res.error}`; return; }
    project.set(res.data);
    setFilePath(res.filePath); setNeedsBackup(!res.data.hasMarker);
    const name = res.filePath.replace(/.*[/\\]/, "");
    statusMsg = res.data.hasMarker ? name : `${name} (will backup .bak on first save)`;
  }

  async function saveFileAs() {
    const bitgui = (window as any).bitgui;
    if (!bitgui?.saveFileAs) return;
    const res = await bitgui.saveFileAs(scadOutput);
    if (!res.ok) return;
    setFilePath(res.filePath);
    statusMsg = `Saved ${res.filePath.replace(/.*[/\\]/, "")}`;
  }

  async function openInOpenScad() {
    const bitgui = (window as any).bitgui;
    if (!bitgui?.openInOpenScad) return;

    let fp = getFilePath();
    if (!fp) {
      // No file yet — prompt save-as first
      await saveFileAs();
      fp = getFilePath();
      if (!fp) return;
    }

    const savedPath = await saveNow();
    const openPath = savedPath || fp;
    const res = await bitgui.openInOpenScad(openPath);
    if (!res.ok) statusMsg = `OpenSCAD: ${res.error}`;
  }

  // --- Schema lookup ---
  const ALL_KEYS: Set<string> = new Set();
  const KEY_TYPE_MAP: Record<string, string> = {};
  const KEY_SCHEMA_MAP: Record<string, any> = {};
  for (const ctx of Object.values((schema as any).contexts)) {
    for (const [k, def] of Object.entries((ctx as any).keys || {})) {
      ALL_KEYS.add(k); KEY_TYPE_MAP[k] = (def as any).type; KEY_SCHEMA_MAP[k] = def;
    }
  }

  const KNOWN_CONSTANTS: Record<string, any> = {
    BOX:"BOX",DIVIDERS:"DIVIDERS",SPACER:"SPACER",SQUARE:"SQUARE",
    HEX:"HEX",HEX2:"HEX2",OCT:"OCT",OCT2:"OCT2",ROUND:"ROUND",FILLET:"FILLET",
    INTERIOR:"INTERIOR",EXTERIOR:"EXTERIOR",BOTH:"BOTH",
    FRONT:"FRONT",BACK:"BACK",LEFT:"LEFT",RIGHT:"RIGHT",
    FRONT_WALL:"FRONT_WALL",BACK_WALL:"BACK_WALL",LEFT_WALL:"LEFT_WALL",RIGHT_WALL:"RIGHT_WALL",
    CENTER:"CENTER",BOTTOM:"BOTTOM",AUTO:"AUTO",MAX:"MAX",
    true:true,false:false,t:true,f:false,
  };

  function parseSimpleValue(text: string): { value: any; ok: boolean } {
    const t = text.trim();
    if (t === "true" || t === "t") return { value: true, ok: true };
    if (t === "false" || t === "f") return { value: false, ok: true };
    if (t in KNOWN_CONSTANTS) return { value: KNOWN_CONSTANTS[t], ok: true };
    const sm = t.match(/^"([^"]*)"$/);
    if (sm) return { value: sm[1], ok: true };
    if (/^-?\d+(\.\d+)?$/.test(t)) return { value: parseFloat(t), ok: true };
    const am = t.match(/^\[(.+)\]$/);
    if (am) {
      const inner = am[1];
      if (inner.includes("[")) return { ok: false, value: null };
      const parts = inner.split(",").map((s: string) => s.trim());
      const vals: any[] = []; let hasExpr = false;
      for (const part of parts) {
        const sub = parseSimpleValue(part);
        if (!sub.ok) { vals.push(part); hasExpr = true; }
        else { vals.push(hasExpr ? String(sub.value) : sub.value); }
      }
      if (hasExpr) return { value: vals.map(String), ok: true };
      return { value: vals, ok: true };
    }
    return { ok: false, value: null };
  }

  const KV_RE = /^\s*\[\s*([A-Z][A-Z0-9_]*)\s*,\s*(.*?)\s*\]\s*,?\s*(?:\/\/.*)?$/;

  function classifyLocal(raw: string, depth: number = 0): Line {
    const bm = raw.match(/^\s*(g_b_print_lid|g_b_print_box)\s*=\s*(true|false|t|f|0|1)\s*;\s*(?:\/\/.*)?$/i);
    if (bm) { const v = bm[2].toLowerCase(); return { raw, kind: "global", depth, globalKey: bm[1], globalValue: v === "true" || v === "t" || v === "1" }; }
    const sm = raw.match(/^\s*(g_isolated_print_box)\s*=\s*"([^"]*)"\s*;\s*(?:\/\/.*)?$/i);
    if (sm) return { raw, kind: "global", depth, globalKey: sm[1], globalValue: sm[2] };
    if (/^\s*include\s*<\s*(?:lib\/)?(?:boardgame_insert_toolkit_lib\.|bit_functions_lib\.)\d+\.scad\s*>\s*;?\s*(?:\/\/.*)?$/i.test(raw)) return { raw, kind: "include", depth };
    if (/^\s*\/\/\s*BITGUI\b/i.test(raw)) return { raw, kind: "marker", depth };
    if (/^\s*MakeAll\s*\(\s*\)\s*;\s*(?:\/\/.*)?$/.test(raw)) return { raw, kind: "makeall", depth };
    // KV line
    const kv = raw.match(KV_RE);
    if (kv && ALL_KEYS.has(kv[1])) { const p = parseSimpleValue(kv[2]); if (p.ok) return { raw, kind: "kv", depth, kvKey: kv[1], kvValue: p.value }; }
    // Brackets are never produced by classifyLocal — they only come from the importer's stack-based parsing.
    return { raw, kind: "raw", depth };
  }

  function handleLineEdit(i: number, newRaw: string) { replaceLine(i, classifyLocal(newRaw, $project.lines[i]?.depth ?? 0)); }
  function getKeyType(k: string) { return KEY_TYPE_MAP[k] || "unknown"; }
  function getKeySchema(k: string) { return KEY_SCHEMA_MAP[k] || null; }
  function parseNum(s: string) { const n = parseFloat(s); return isNaN(n) ? 0 : n; }
  function smartParseNum(s: string) { const t = s.trim(); return /^-?\d+(\.\d+)?$/.test(t) ? parseFloat(t) : t; }
  function updateKvIdx(li: number, arr: any[], j: number, val: any) { const c = [...arr]; c[j] = val; updateKv(li, c); }
  function canParse(raw: string) { return classifyLocal(raw).kind !== "raw"; }
  function tip(key: string): string { return (tooltips as Record<string, string>)[key] || ""; }
  function toRaw(i: number) {
    const l = $project.lines[i];
    if (!l || l.kind === "open" || l.kind === "close") return; // brackets are never raw
    replaceLine(i, { raw: l.raw, kind: "raw", depth: l.depth });
  }
  function toParsed(i: number) { const l = $project.lines[i]; if (!l) return; const c = classifyLocal(l.raw, l.depth); if (c.kind !== "raw") replaceLine(i, c); }

  /**
   * For each line index, rawGroupStart[i] is:
   *  - i itself if line i is "raw" and is the first in a contiguous run of raw lines
   *  - -1 if line i is "raw" but NOT the first in its group (skip rendering)
   *  - undefined if line i is not "raw"
   * rawGroupEnd[i] = last index (exclusive) of the raw group starting at i.
   */
  let rawGroups = $derived.by(() => {
    const lines = $project.lines;
    const startOf: Record<number, number> = {}; // startIndex → count
    let i = 0;
    while (i < lines.length) {
      if (lines[i].kind === "raw") {
        const start = i;
        while (i < lines.length && lines[i].kind === "raw") i++;
        startOf[start] = i - start;
      } else {
        i++;
      }
    }
    return startOf;
  });

  function isRawGroupStart(i: number): boolean {
    return i in rawGroups;
  }
  function isRawGroupMember(i: number): boolean {
    // Check if this index is inside a group but not the start
    const lines = $project.lines;
    return lines[i]?.kind === "raw" && !(i in rawGroups);
  }
  function rawGroupText(startIndex: number): string {
    const count = rawGroups[startIndex] || 1;
    return $project.lines.slice(startIndex, startIndex + count).map(l => l.raw).join("\n");
  }
  function rawGroupLineCount(startIndex: number): number {
    return rawGroups[startIndex] || 1;
  }

  /** When a raw group textarea is edited, re-split into raw lines (no re-classification). */
  function handleRawGroupEdit(startIndex: number, newText: string) {
    const oldCount = rawGroups[startIndex] || 1;
    const oldText = rawGroupText(startIndex);
    // If nothing changed, do nothing.
    if (newText === oldText) return;
    const depth = $project.lines[startIndex]?.depth ?? 0;
    const newRawLines = newText.split("\n");
    // Keep as raw — don't re-classify. The user can use the full reimport
    // (via the importer) if they want to convert to structured.
    const newLines: Line[] = newRawLines
      .filter(r => r.trim() !== "")
      .map(r => ({ raw: r, kind: "raw" as const, depth }));
    if (newLines.length === 0) {
      newLines.push({ raw: "    ".repeat(depth), kind: "raw", depth });
    }
    spliceLines(startIndex, oldCount, newLines);
  }

  const DEPTH_PX = 24;
  function pad(line: Line) { return `padding-left: ${8 + (line.depth ?? 0) * DEPTH_PX}px`; }
  function padDepth(d: number) { return `padding-left: ${8 + d * DEPTH_PX}px`; }

  // --- Collapse/expand ---
  let collapsed = $state(new Set<number>());

  function toggleCollapse(i: number) {
    const next = new Set(collapsed);
    if (next.has(i)) next.delete(i); else next.add(i);
    collapsed = next;
  }

  /** Find the matching close bracket index for an open at `openIdx`. */
  function findMatchingClose(openIdx: number): number {
    let depth = 0;
    for (let j = openIdx; j < $project.lines.length; j++) {
      if ($project.lines[j].kind === "open") depth += ($project.lines[j] as any).mergedOpen ? 2 : 1;
      if ($project.lines[j].kind === "close") {
        depth -= ($project.lines[j] as any).mergedClose ? 2 : 1;
        if (depth <= 0) return j;
      }
    }
    return -1;
  }

  /**
   * Check if line at index `i` should be hidden because a parent open bracket is collapsed.
   * We need to check all open brackets above this line.
   */
  let hiddenLines = $derived.by(() => {
    const hidden = new Set<number>();
    const lines = $project.lines;
    for (const openIdx of collapsed) {
      if (openIdx >= lines.length || lines[openIdx].kind !== "open") continue;
      const closeIdx = findMatchingClose(openIdx);
      if (closeIdx < 0) continue;
      // Hide everything between open and close (exclusive of both)
      // Also hide the close bracket itself — we'll show "]" inline on the open line
      for (let j = openIdx + 1; j <= closeIdx; j++) {
        hidden.add(j);
      }
    }
    return hidden;
  });

  // Map role → schema context for virtual defaults
  const ROLE_TO_CONTEXT: Record<string, string> = {
    params: "element",
    component: "component",
    label_params: "label",
    lid_params: "lid",
  };

  // For merged closes, map outer role → inner role
  const MERGED_INNER_ROLE: Record<string, string> = {
    element: "params",
    component_list: "component",
    label: "label_params",
    lid: "lid_params",
  };

  /** Get schema context for a close line, handling both normal and merged closes. */
  function getCloseContext(line: Line): string | undefined {
    const role = line.role || "";
    if (ROLE_TO_CONTEXT[role]) return ROLE_TO_CONTEXT[role];
    if (line.mergedClose) {
      const innerRole = MERGED_INNER_ROLE[role];
      if (innerRole) return ROLE_TO_CONTEXT[innerRole];
    }
    return undefined;
  }

  // Get all scalar schema keys for a context (skip table/table_list)
  function getScalarKeysForContext(ctx: string): { key: string; def: any }[] {
    const ctxDef = (schema as any).contexts?.[ctx];
    if (!ctxDef) return [];
    return Object.entries(ctxDef.keys || {})
      .filter(([_, d]: [string, any]) => d.type !== "table" && d.type !== "table_list")
      .map(([k, d]) => ({ key: k, def: d }));
  }

  /**
   * For a close bracket, compute a unified sorted list of all schema keys:
   * both real (existing kv lines) and virtual (missing, shown with defaults).
   * Returns { key, def, lineIndex?, value, isReal, depth }[] sorted alphabetically.
   */
  function getSortedSchemaRows(closeIndex: number): {
    key: string; def: any; lineIndex: number | null; value: any; isReal: boolean; depth: number;
  }[] {
    const closeLine = $project.lines[closeIndex];
    if (!closeLine || closeLine.kind !== "close") return [];
    const ctx = getCloseContext(closeLine);
    if (!ctx) return [];

    // Find matching open bracket (merged brackets count as 2)
    let bd = 0;
    let openIdx = -1;
    for (let i = closeIndex; i >= 0; i--) {
      if ($project.lines[i].kind === "close") bd += ($project.lines[i] as any).mergedClose ? 2 : 1;
      if ($project.lines[i].kind === "open") {
        bd -= ($project.lines[i] as any).mergedOpen ? 2 : 1;
        if (bd <= 0) { openIdx = i; break; }
      }
    }
    if (openIdx < 0) return [];

    const childDepth = (closeLine.depth ?? 0) + 1;

    // Collect existing kv lines
    const existingMap = new Map<string, { lineIndex: number; value: any }>();
    for (let i = openIdx + 1; i < closeIndex; i++) {
      const l = $project.lines[i];
      if (l.kind === "kv" && l.kvKey && l.depth === childDepth) {
        existingMap.set(l.kvKey, { lineIndex: i, value: l.kvValue });
      }
    }

    const scalars = getScalarKeysForContext(ctx);
    const rows = scalars.map(({ key, def }) => {
      const existing = existingMap.get(key);
      if (existing) {
        return { key, def, lineIndex: existing.lineIndex, value: existing.value, isReal: true, depth: childDepth };
      }
      return { key, def, lineIndex: null, value: def.default, isReal: false, depth: childDepth };
    });

    // Sort alphabetically
    rows.sort((a, b) => a.key.localeCompare(b.key));
    return rows;
  }

  /**
   * Set of line indices that are kv lines rendered inside a sorted schema block.
   * These should be skipped in the main line loop.
   */
  let kvRenderedInBlock = $derived.by(() => {
    const set = new Set<number>();
    const lines = $project.lines;
    for (let i = 0; i < lines.length; i++) {
      if (lines[i].kind !== "close") continue;
      if (!getCloseContext(lines[i])) continue;
      const rows = getSortedSchemaRows(i);
      for (const r of rows) {
        if (r.lineIndex !== null) set.add(r.lineIndex);
      }
    }
    return set;
  });

  /** When a virtual default is changed from its default value, materialize it. */
  function onVirtualChange(closeIndex: number, key: string, def: any, newValue: any) {
    if (JSON.stringify(newValue) === JSON.stringify(def.default)) return;
    const depth = (($project.lines[closeIndex]?.depth ?? 0)) + 1;
    materializeKv(closeIndex, key, newValue, depth);
  }

  /** Delete a real kv line (dematerialize back to virtual default). */
  function dematerializeKv(lineIndex: number) {
    deleteLine(lineIndex);
  }

  function isDefault(key: string, value: any): boolean {
    const def = KEY_SCHEMA_MAP[key];
    if (!def || def.default === undefined) return false;
    return JSON.stringify(value) === JSON.stringify(def.default);
  }

  function getSchemaDefault(key: string): any {
    return KEY_SCHEMA_MAP[key]?.default;
  }

  // Structural label for open/close brackets.
  // Returns { text, inferred } where inferred=true means the label is our interpretation, not from the file.
  function structLabel(line: Line): { text: string; inferred: boolean } {
    if (line.role === "data") return { text: "data", inferred: false };
    if (line.role === "data_list") return { text: "data list", inferred: true };
    if (line.role === "element") return { text: `element "${line.label}"`, inferred: false };
    if (line.role === "params") return { text: "element params", inferred: true };
    if (line.role === "component_list") return { text: line.label || "BOX_COMPONENT", inferred: false };
    if (line.role === "component") return { text: "component list", inferred: true };
    if (line.role === "label") return { text: line.label || "LABEL", inferred: false };
    if (line.role === "label_params") return { text: "label params", inferred: true };
    if (line.role === "lid") return { text: line.label || "BOX_LID", inferred: false };
    if (line.role === "lid_params") return { text: "lid params", inferred: true };
    if (line.role === "list") return { text: "list", inferred: true };
    return { text: line.label || "block", inferred: true };
  }

  // --- Comment editing ---
  let editingComment = $state<number | null>(null);

  function toggleCommentEdit(i: number) {
    editingComment = editingComment === i ? null : i;
  }

  function addRawLine(afterIndex: number, depth: number) {
    const indent = "    ".repeat(depth);
    insertLine(afterIndex + 1, { raw: indent, kind: "raw", depth });
  }

  /** Insert a full element skeleton before a close bracket at `closeIndex`. */
  function addElement(closeIndex: number, depth: number) {
    const d = depth + 1; // inside the data array
    const ind = (n: number) => "    ".repeat(n);
    const count = $project.lines.filter(l => l.kind === "open" && l.role === "element").length;
    const name = `box ${count + 1}`;
    const lines: Line[] = [
      { raw: `${ind(d)}[ "${name}", [`, kind: "open", depth: d, role: "element", label: name, mergedOpen: true },
      { raw: `${ind(d+1)}[ TYPE, BOX ],`, kind: "kv", depth: d + 1, kvKey: "TYPE", kvValue: "BOX" },
      { raw: `${ind(d+1)}[ BOX_SIZE_XYZ, [50, 50, 20] ],`, kind: "kv", depth: d + 1, kvKey: "BOX_SIZE_XYZ", kvValue: [50, 50, 20] },
      { raw: `${ind(d)}]],`, kind: "close", depth: d, role: "element", label: name, mergedClose: true },
    ];
    // Insert all lines before the close bracket
    project.update((p) => {
      p.lines.splice(closeIndex, 0, ...lines);
      return { ...p };
    });
  }

  /** Insert a component skeleton inside a component_list before `closeIndex`. */
  function addComponent(closeIndex: number, depth: number) {
    const d = depth + 1;
    const ind = (n: number) => "    ".repeat(n);
    const name = "comp";
    const lines: Line[] = [
      { raw: `${ind(d)}[ "${name}", [`, kind: "open", depth: d, role: "element", label: name, mergedOpen: true },
      { raw: `${ind(d+1)}[ CMP_COMPARTMENT_SIZE_XYZ, [40, 40, 15] ],`, kind: "kv", depth: d + 1, kvKey: "CMP_COMPARTMENT_SIZE_XYZ", kvValue: [40, 40, 15] },
      { raw: `${ind(d)}]],`, kind: "close", depth: d, role: "element", label: name, mergedClose: true },
    ];
    project.update((p) => {
      p.lines.splice(closeIndex, 0, ...lines);
      return { ...p };
    });
  }

  /** Insert a BOX_COMPONENT block before `closeIndex` (inside a params close). */
  function addComponentList(closeIndex: number, depth: number) {
    const d = depth;
    const ind = (n: number) => "    ".repeat(n);
    const lines: Line[] = [
      { raw: `${ind(d)}[ BOX_COMPONENT, [`, kind: "open", depth: d, role: "component_list", label: "BOX_COMPONENT", mergedOpen: true },
      { raw: `${ind(d+1)}[ "comp 1", [`, kind: "open", depth: d + 1, role: "element", label: "comp 1", mergedOpen: true },
      { raw: `${ind(d+2)}[ CMP_COMPARTMENT_SIZE_XYZ, [40, 40, 15] ],`, kind: "kv", depth: d + 2, kvKey: "CMP_COMPARTMENT_SIZE_XYZ", kvValue: [40, 40, 15] },
      { raw: `${ind(d+1)}]],`, kind: "close", depth: d + 1, role: "element", label: "comp 1", mergedClose: true },
      { raw: `${ind(d)}]],`, kind: "close", depth: d, role: "component_list", label: "BOX_COMPONENT", mergedClose: true },
    ];
    project.update((p) => {
      p.lines.splice(closeIndex, 0, ...lines);
      return { ...p };
    });
  }

  /** Insert a LABEL block before `closeIndex`. */
  function addLabel(closeIndex: number, depth: number) {
    const d = depth;
    const ind = (n: number) => "    ".repeat(n);
    const lines: Line[] = [
      { raw: `${ind(d)}[ LABEL, [`, kind: "open", depth: d, role: "label", label: "LABEL", mergedOpen: true },
      { raw: `${ind(d+1)}[ LBL_TEXT, "" ],`, kind: "kv", depth: d + 1, kvKey: "LBL_TEXT", kvValue: "" },
      { raw: `${ind(d)}]],`, kind: "close", depth: d, role: "label", label: "LABEL", mergedClose: true },
    ];
    project.update((p) => {
      p.lines.splice(closeIndex, 0, ...lines);
      return { ...p };
    });
  }
</script>

{#snippet commentBtn(line, i)}
  {#if line.comment || editingComment === i}
    <span class="comment-area">
      <span class="comment-slash">//</span>
      <input class="comment-input" type="text" value={line.comment ?? ""}
        onblur={(e) => { updateComment(i, e.currentTarget.value); editingComment = null; }}
        onkeydown={(e) => { if (e.key === "Enter") { e.currentTarget.blur(); } if (e.key === "Escape") { editingComment = null; } }}
      />
    </span>
  {:else}
    <button class="comment-btn" title="Add comment" onclick={() => toggleCommentEdit(i)}>//</button>
  {/if}
{/snippet}

<main data-testid="app-root">
  <section class="content" data-testid="content-area">
    {#each $project.lines as line, i (i)}

      {#if hiddenLines.has(i)}
        <!-- Hidden by collapsed parent -->

      {:else if kvRenderedInBlock.has(i)}
        <!-- This kv line is rendered in the sorted schema block before its close bracket -->

      {:else if line.kind === "open"}
        {@const collapsible = !["params", "label_params", "lid_params", "component"].includes(line.role || "")}
        {@const deletable = !["data", "data_list", "params", "label_params", "lid_params", "component"].includes(line.role || "")}
        <div class="line-row struct open" style={pad(line)} data-testid="line-{i}">
          {#if collapsible}
            <button class="collapse-btn" title={collapsed.has(i) ? "Expand" : "Collapse"}
              onclick={() => toggleCollapse(i)}>{collapsed.has(i) ? "▶" : "▼"}</button>
          {/if}
          <span class={structLabel(line).inferred ? "struct-label inferred" : "struct-label"}>{structLabel(line).text}</span>
          <span class="struct-bracket">{collapsed.has(i) ? "[ ... ]" : "["}</span>
          <span class="spacer"></span>
          {@render commentBtn(line, i)}
          {#if deletable}
            <button class="delete-btn" title="Delete block" onclick={() => deleteBlock(i)}>✕</button>
          {/if}
        </div>

      {:else if line.kind === "close"}
        <!-- Sorted schema rows (real + virtual) before close bracket -->
        {#each getSortedSchemaRows(i) as row (row.key)}
          {@const rkt = getKeyType(row.key)}
          {@const rks = getKeySchema(row.key)}
          {@const onChange = row.isReal
            ? (v) => updateKv(row.lineIndex, v, row.def.default)
            : (v) => onVirtualChange(i, row.key, row.def, v)}
          {@const val = row.value}
          <div class="line-row kv" class:virtual={!row.isReal} style={padDepth(row.depth)} data-testid={row.isReal ? `line-${row.lineIndex}` : `virtual-${row.key}`}>
            <span class="kv-key" class:virtual-key={!row.isReal} title={tip(row.key)}>{row.key}</span>
            <span class="kv-control">
              {#if rkt === "bool"}
                <input type="checkbox" checked={val === true} onchange={(e) => onChange(e.currentTarget.checked)} />
              {:else if rkt === "enum"}
                <select value={val} onchange={(e) => onChange(e.currentTarget.value)}>
                  {#each rks?.values || [] as v}<option value={v}>{v}</option>{/each}
                </select>
              {:else if rkt === "number"}
                <input class="kv-num" type="number" step="any" value={val} onchange={(e) => onChange(parseNum(e.currentTarget.value))} />
              {:else if rkt === "string"}
                <input class="kv-str" type="text" value={val ?? ""} onchange={(e) => onChange(e.currentTarget.value)} />
              {:else if rkt === "xyz" && Array.isArray(val)}
                {#each [0,1,2] as j}
                  <input class="kv-str sm" type="text" value={val[j] ?? 0}
                    onchange={(e) => { const c = [...val]; c[j] = smartParseNum(e.currentTarget.value); onChange(c); }} />
                {/each}
              {:else if rkt === "xy" && Array.isArray(val)}
                {#each [0,1] as j}
                  <input class="kv-str sm" type="text" value={val[j] ?? 0}
                    onchange={(e) => { const c = [...val]; c[j] = smartParseNum(e.currentTarget.value); onChange(c); }} />
                {/each}
              {:else if rkt === "position_xy" && Array.isArray(val)}
                {#each [0,1] as j}
                  <input class="kv-str sm" type="text" value={val[j] ?? ""}
                    onchange={(e) => { const c = [...val]; const r = e.currentTarget.value.trim(); c[j] = (r==="CENTER"||r==="MAX") ? r : smartParseNum(r); onChange(c); }} />
                {/each}
              {:else if rkt === "4bool" && Array.isArray(val)}
                {#each ["F","B","L","R"] as lb, j}
                  <label class="side-label"><span class="side-tag">{lb}</span>
                    <input type="checkbox" checked={val[j] ?? false}
                      onchange={(e) => { const c = [...val]; c[j] = e.currentTarget.checked; onChange(c); }} />
                  </label>
                {/each}
              {:else if rkt === "4num" && Array.isArray(val)}
                {#each ["F","B","L","R"] as lb, j}
                  <label class="side-label"><span class="side-tag">{lb}</span>
                    <input class="kv-num xs" type="number" step="any" value={val[j] ?? 0}
                      onchange={(e) => { const c = [...val]; c[j] = parseNum(e.currentTarget.value); onChange(c); }} />
                  </label>
                {/each}
              {:else}
                <span class="kv-fallback">{JSON.stringify(val)}</span>
              {/if}
            </span>
            <span class="spacer"></span>
            {#if row.isReal && row.lineIndex !== null}
              {@render commentBtn($project.lines[row.lineIndex], row.lineIndex)}
              <button class="delete-btn" title="Reset to default" onclick={() => dematerializeKv(row.lineIndex)}>✕</button>
            {/if}
          </div>
        {/each}
        <!-- Close bracket with context-aware add buttons -->
        <div class="line-row struct close" style={pad(line)} data-testid="line-{i}">
          <span class="struct-bracket">{line.raw.trim()}</span>
          {#if line.role === "data"}
            <button class="add-btn" title="Add element" onclick={() => addElement(i, line.depth ?? 0)}>+ Element</button>
          {:else if line.role === "params"}
            <button class="add-btn" title="Add line" onclick={() => addRawLine(i - 1, (line.depth ?? 0) + 1)}>+ Line</button>
            <button class="add-btn" title="Add LABEL block" onclick={() => addLabel(i, (line.depth ?? 0) + 1)}>+ Label</button>
            <button class="add-btn" title="Add BOX_COMPONENT block" onclick={() => addComponentList(i, (line.depth ?? 0) + 1)}>+ Component</button>
          {:else if line.role === "element" && line.mergedClose}
            {@const innerDepth = (line.depth ?? 0) + 1}
            <button class="add-btn" title="Add line" onclick={() => addRawLine(i - 1, innerDepth)}>+ Line</button>
            <button class="add-btn" title="Add LABEL block" onclick={() => addLabel(i, innerDepth)}>+ Label</button>
            <button class="add-btn" title="Add BOX_COMPONENT block" onclick={() => addComponentList(i, innerDepth)}>+ Component</button>
          {:else if line.role === "component" || line.role === "component_list" || line.role === "label" || line.role === "lid" || line.role === "label_params" || line.role === "lid_params" || line.role === "list" || line.role === "data_list"}
            <!-- No add buttons on these structural close brackets -->
          {:else}
            <button class="add-btn" title="Add line" onclick={() => addRawLine(i - 1, (line.depth ?? 0) + 1)}>+</button>
          {/if}
        </div>

      {:else if line.kind === "global" && (line.globalKey === "g_b_print_lid" || line.globalKey === "g_b_print_box")}
        <div class="line-row control" style={pad(line)} data-testid="line-{i}">
          <span class="control-label" title={tip(line.globalKey || "")}>{line.globalKey}</span>
          <input type="checkbox" checked={line.globalValue === true}
            onchange={(e) => updateGlobal(i, e.currentTarget.checked)} />
          <span class="spacer"></span>
          {@render commentBtn(line, i)}
          <button class="toggle-btn" title="Edit as raw text" onclick={() => toRaw(i)}>{"{}"}</button>
        </div>

      {:else if line.kind === "global"}
        <div class="line-row control" style={pad(line)} data-testid="line-{i}">
          <span class="control-label" title={tip(line.globalKey || "")}>{line.globalKey}</span>
          <input class="control-text" type="text" value={line.globalValue ?? ""}
            onchange={(e) => updateGlobal(i, e.currentTarget.value)} />
          <span class="spacer"></span>
          {@render commentBtn(line, i)}
          <button class="toggle-btn" title="Edit as raw text" onclick={() => toRaw(i)}>{"{}"}</button>
        </div>

      {:else if line.kind === "kv" && line.kvKey}
        {@const kt = getKeyType(line.kvKey)}
        {@const ks = getKeySchema(line.kvKey)}
        {@const sd = getSchemaDefault(line.kvKey)}
        <div class="line-row kv" class:is-default={isDefault(line.kvKey, line.kvValue)} style={pad(line)} data-testid="line-{i}">
          <span class="kv-key" title={tip(line.kvKey || "")}>{line.kvKey}</span>
          <span class="kv-control">
            {#if kt === "bool"}
              <input type="checkbox" checked={line.kvValue === true}
                onchange={(e) => updateKv(i, e.currentTarget.checked, sd)} />
            {:else if kt === "enum"}
              <select value={line.kvValue} onchange={(e) => updateKv(i, e.currentTarget.value, sd)}>
                {#each ks?.values || [] as v}<option value={v}>{v}</option>{/each}
              </select>
            {:else if kt === "number"}
              <input class="kv-num" type="number" step="any" value={line.kvValue}
                onchange={(e) => updateKv(i, parseNum(e.currentTarget.value), sd)} />
            {:else if kt === "string"}
              <input class="kv-str" type="text" value={line.kvValue ?? ""}
                onchange={(e) => updateKv(i, e.currentTarget.value, sd)} />
            {:else if kt === "xyz" && Array.isArray(line.kvValue)}
              {#each [0,1,2] as j}
                <input class="kv-str sm" type="text" value={line.kvValue[j] ?? 0}
                  onchange={(e) => updateKvIdx(i, line.kvValue, j, smartParseNum(e.currentTarget.value))} />
              {/each}
            {:else if kt === "xy" && Array.isArray(line.kvValue)}
              {#each [0,1] as j}
                <input class="kv-str sm" type="text" value={line.kvValue[j] ?? 0}
                  onchange={(e) => updateKvIdx(i, line.kvValue, j, smartParseNum(e.currentTarget.value))} />
              {/each}
            {:else if kt === "position_xy" && Array.isArray(line.kvValue)}
              {#each [0,1] as j}
                <input class="kv-str sm" type="text" value={line.kvValue[j] ?? ""}
                  onchange={(e) => { const r = e.currentTarget.value.trim(); updateKvIdx(i, line.kvValue, j, (r==="CENTER"||r==="MAX") ? r : smartParseNum(r)); }} />
              {/each}
            {:else if kt === "4bool" && Array.isArray(line.kvValue)}
              {#each ["F","B","L","R"] as lb, j}
                <label class="side-label"><span class="side-tag">{lb}</span>
                  <input type="checkbox" checked={line.kvValue[j] ?? false}
                    onchange={(e) => updateKvIdx(i, line.kvValue, j, e.currentTarget.checked)} />
                </label>
              {/each}
            {:else if kt === "4num" && Array.isArray(line.kvValue)}
              {#each ["F","B","L","R"] as lb, j}
                <label class="side-label"><span class="side-tag">{lb}</span>
                  <input class="kv-num xs" type="number" step="any" value={line.kvValue[j] ?? 0}
                    onchange={(e) => updateKvIdx(i, line.kvValue, j, parseNum(e.currentTarget.value))} />
                </label>
              {/each}
            {:else}
              <span class="kv-fallback">{JSON.stringify(line.kvValue)}</span>
            {/if}
          </span>
          <span class="spacer"></span>
          {@render commentBtn(line, i)}
          <button class="toggle-btn" title="Edit as raw text" onclick={() => toRaw(i)}>{"{}"}</button>
        </div>

      {:else if line.kind === "include" || line.kind === "marker" || line.kind === "makeall"}
        <div class="line-row muted" style={pad(line)} data-testid="line-{i}">
          <span class="line-text">{line.raw}</span>
          <span class="line-badge">{line.kind}</span>
        </div>

      {:else if line.kind === "raw" && isRawGroupStart(i)}
        <div class="raw-block" data-testid="line-{i}">
          <textarea class="raw-textarea"
            rows={rawGroupLineCount(i)}
            value={rawGroupText(i)}
            onblur={(e) => handleRawGroupEdit(i, e.currentTarget.value)}
          ></textarea>
          <button class="raw-delete" title="Delete raw block"
            onclick={() => spliceLines(i, rawGroupLineCount(i), [])}>✕</button>
        </div>

      {:else if line.kind === "raw" && isRawGroupMember(i)}
        <!-- Skip: this raw line is rendered as part of a group above -->

      {:else}
        <!-- Fallback for any other unhandled kind -->
        <div class="line-row raw" style={pad(line)} data-testid="line-{i}">
          <input class="raw-input" type="text" value={line.raw}
            onchange={(e) => handleLineEdit(i, e.currentTarget.value)} />
          <span class="spacer"></span>
          <button class="delete-btn" onclick={() => deleteLine(i)}>✕</button>
        </div>
      {/if}

    {/each}
  </section>

  <footer class="status-bar" data-testid="status-bar">
    <span data-testid="save-status">{statusMsg}</span>
  </footer>

  {#if showIntent}
    <div class="intent-pane" data-testid="intent-pane">
      <input data-testid="intent-text" type="text" bind:value={intentText}
        placeholder="Describe what you expect to happen..." />
    </div>
  {/if}
</main>

<style>
  :global(body) {
    margin: 0;
    font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
    font-size: 14px; color: #1a1a1a; background: #f5f5f5;
  }
  main { display: flex; flex-direction: column; height: 100vh; overflow: hidden; }
  .content { flex: 1; overflow-y: auto; padding: 4px 0; }

  .line-row {
    display: flex; align-items: center; gap: 6px;
    padding: 3px 8px; min-height: 28px;
    font-family: "Courier New", monospace; font-size: 15px; font-weight: 500;
    border-bottom: 1px solid #f0f0f0;
  }
  .line-row.muted { opacity: 0.35; font-style: italic; }
  .line-row.control { background: #e8f4e8; }
  .line-row.raw { background: white; }
  .line-row.kv { background: #e8f4e8; }
  .line-row.kv.virtual { background: #f0ecf5; font-style: italic; }
  .line-row.kv.virtual:hover { background: #e8e2f0; }
  .line-row.kv.virtual .kv-key { font-weight: 500; color: #7b6b8a; }
  .virtual-key { font-style: italic; }
  .line-row.struct { background: #f8f4ff; }
  .line-row.struct.open { border-left: 3px solid #8e44ad; }
  .line-row.struct.close { border-left: 3px solid #cbb4d8; opacity: 0.6; }

  .collapse-btn {
    background: none; border: none; cursor: pointer;
    padding: 0 2px; font-size: 12px; color: #888; flex-shrink: 0;
  }
  .collapse-btn:hover { color: #6c3483; }
  .struct-label { font-weight: 700; color: #6c3483; }
  .struct-label.inferred { font-style: italic; font-weight: 500; color: #9b7fb8; }
  .struct-bracket { color: #999; font-weight: 700; }
  .spacer { flex: 1; }

  .line-text { flex: 1; min-width: 0; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
  .line-badge { font-size: 11px; color: #999; background: #eee; padding: 1px 5px; border-radius: 2px; font-weight: 500; }

  .control-label { font-weight: 700; color: #2c3e50; min-width: 200px; font-size: 15px; }
  .control-text {
    flex: 1; max-width: 300px;
    font-family: "Courier New", monospace; font-size: 15px; font-weight: 500;
    padding: 3px 6px; border: 1px solid #ddd; border-radius: 2px;
  }

  .kv-key { font-weight: 700; color: #2c3e50; min-width: 220px; flex-shrink: 0; }
  .kv-control { display: flex; align-items: center; gap: 6px; flex: 1; min-width: 0; }
  .kv-num { font-family: "Courier New", monospace; font-size: 15px; font-weight: 500; padding: 3px 6px; border: 1px solid #ddd; border-radius: 2px; width: 80px; background: white; }
  .kv-num.sm { width: 60px; }
  .kv-num.xs { width: 48px; }
  .kv-str { font-family: "Courier New", monospace; font-size: 15px; font-weight: 500; padding: 3px 6px; border: 1px solid #ddd; border-radius: 2px; width: 180px; background: white; }
  .kv-str.sm { width: 80px; }
  .kv-control select { font-family: "Courier New", monospace; font-size: 15px; font-weight: 500; padding: 3px 4px; border: 1px solid #ddd; border-radius: 2px; }
  .kv-control input[type="checkbox"] { width: 18px; height: 18px; }
  .kv-fallback { color: #999; font-size: 13px; }
  .side-label { display: inline-flex; align-items: center; gap: 2px; font-size: 13px; }
  .side-tag { color: #999; font-size: 11px; font-weight: 600; width: 12px; text-align: center; }

  .raw-block {
    position: relative;
    width: 100%;
    border-bottom: 1px solid #f0f0f0;
    background: #fdf8ef;
  }
  .raw-textarea {
    display: block;
    width: 100%; box-sizing: border-box;
    resize: none; overflow: hidden;
    font-family: "Courier New", monospace; font-size: 15px; font-weight: 500;
    line-height: 28px;
    padding: 3px 28px 3px 8px;
    border: none; border-left: 3px solid transparent;
    background: transparent; color: #5a4a2a;
    outline: none;
  }
  .raw-textarea:focus { border-left-color: #e0c87a; background: #fef6e0; }
  .raw-delete {
    position: absolute; top: 4px; right: 6px;
    background: none; border: none; color: #ccc;
    cursor: pointer; font-size: 16px; padding: 0 4px;
  }
  .raw-delete:hover { color: #e74c3c; }
  .raw-input {
    flex: 1; min-width: 0;
    font-family: "Courier New", monospace; font-size: 15px; font-weight: 500;
    padding: 3px 6px; border: 1px solid #ddd; border-radius: 2px; background: white;
  }
  .toggle-btn {
    background: none; border: 1px solid #ccc; color: #888;
    cursor: pointer; font-size: 11px; font-weight: 700;
    padding: 1px 5px; border-radius: 3px; flex-shrink: 0;
    font-family: "Courier New", monospace;
  }
  .toggle-btn:hover:not(:disabled) { border-color: #3498db; color: #3498db; }
  .toggle-btn:disabled, .toggle-btn.disabled { opacity: 0.3; cursor: default; }
  .add-btn {
    background: none; border: 1px dashed #bbb; color: #7f8c8d;
    padding: 0 8px; border-radius: 3px; cursor: pointer;
    font-size: 14px; font-weight: 700; line-height: 1.4;
  }
  .add-btn:hover { border-color: #3498db; color: #3498db; }
  .comment-btn {
    background: none; border: none; color: #ccc; cursor: pointer;
    font-family: "Courier New", monospace; font-size: 13px; font-weight: 700;
    padding: 0 3px; flex-shrink: 0;
  }
  .comment-btn:hover { color: #27ae60; }
  .comment-area {
    display: inline-flex; align-items: center; gap: 2px; flex-shrink: 0;
  }
  .comment-slash {
    color: #27ae60; font-family: "Courier New", monospace; font-size: 13px; font-weight: 700;
  }
  .comment-input {
    font-family: "Courier New", monospace; font-size: 13px; font-weight: 400;
    color: #27ae60; font-style: italic;
    border: none; border-bottom: 1px solid #a3d9a5; background: transparent;
    padding: 0 4px; width: 180px; outline: none;
  }
  .comment-input:focus { border-bottom-color: #27ae60; }
  .delete-btn { background: none; border: none; color: #ccc; cursor: pointer; font-size: 16px; padding: 0 4px; }
  .delete-btn:hover { color: #e74c3c; }

  .status-bar { display: flex; justify-content: space-between; padding: 3px 12px; background: #ecf0f1; border-top: 1px solid #ddd; font-size: 13px; color: #666; }
  .intent-pane { background: #1a1a2e; padding: 6px 12px; border-top: 2px solid #e74c3c; }
  .intent-pane input { width: 100%; box-sizing: border-box; background: #16213e; border: 1px solid #444; color: #e0e0e0; padding: 4px 8px; font-family: "Courier New", monospace; font-size: 13px; border-radius: 2px; }
</style>
