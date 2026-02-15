<script lang="ts">
  import { onMount } from "svelte";
  import ElementNode from "./lib/components/ElementNode.svelte";
  import { project, addElement, deleteElement, renameElement } from "./lib/stores/project";
  import { generateScad } from "./lib/scad";
  import { startAutosave, onSaveStatus, setProjectDir, getProjectDir, triggerSave } from "./lib/autosave";

  let intentText = "";
  let showIntent = false;
  let showScad = false;
  let statusMsg = "No project open";

  $: scadOutput = generateScad($project);

  onSaveStatus((msg) => { statusMsg = msg; });

  onMount(() => {
    showIntent = !!(window as any).bitgui?.harness;
    startAutosave();
  });

  async function newProject() {
    const bitgui = (window as any).bitgui;
    if (!bitgui?.showSaveDialog) return;
    const res = await bitgui.showSaveDialog();
    if (!res.ok) return;
    const created = await bitgui.newProject(res.dirPath);
    if (!created.ok) { statusMsg = `New project failed: ${created.error}`; return; }
    const emptyProject = {
      version: 1,
      lib_checksums: created.checksums,
      globals: { g_b_print_lid: true, g_b_print_box: true, g_isolated_print_box: "" },
      data: [],
    };
    project.set(emptyProject);
    setProjectDir(res.dirPath);
    statusMsg = `New project: ${res.dirPath}`;
    triggerSave();
  }

  async function openProject() {
    const bitgui = (window as any).bitgui;
    if (!bitgui?.showOpenDialog) return;
    const res = await bitgui.showOpenDialog();
    if (!res.ok) return;
    const loaded = await bitgui.loadProject(res.filePath);
    if (loaded.ok) {
      project.set(loaded.data);
      const dir = res.filePath.replace(/[/\\][^/\\]+$/, "");
      setProjectDir(dir);
      statusMsg = `Opened: ${dir}`;
      // Check lib staleness
      const stale = await bitgui.checkLibStaleness(dir);
      if (stale.ok && stale.stale.length > 0) {
        statusMsg += ` (libs outdated: ${stale.stale.join(", ")})`;
      }
    } else {
      statusMsg = `Open failed: ${loaded.error}`;
    }
  }

  async function importScadFile() {
    const bitgui = (window as any).bitgui;
    if (!bitgui?.showImportDialog) return;
    const res = await bitgui.showImportDialog();
    if (!res.ok) return;
    const imported = await bitgui.importScad(res.filePath);
    if (imported.ok) {
      project.set(imported.data);
      statusMsg = `Imported: ${res.filePath}`;
    } else {
      statusMsg = `Import failed: ${imported.error}`;
    }
  }

  async function openInOpenScad() {
    const bitgui = (window as any).bitgui;
    const dir = getProjectDir();
    if (!bitgui?.openInOpenScad || !dir) return;
    const res = await bitgui.openInOpenScad(dir);
    if (!res.ok) statusMsg = `OpenSCAD: ${res.error}`;
  }

  async function saveProjectAs() {
    const bitgui = (window as any).bitgui;
    if (!bitgui?.showSaveDialog) return;
    const res = await bitgui.showSaveDialog();
    if (!res.ok) return;
    setProjectDir(res.dirPath);
    statusMsg = `Project dir: ${res.dirPath}`;
    triggerSave();
  }
</script>

<main data-testid="app-root">
  <header data-testid="app-header">
    <h1>BIT GUI</h1>
    <div class="header-actions">
      <button data-testid="new-project" on:click={newProject}>New</button>
      <button data-testid="open-project" on:click={openProject}>Open</button>
      <button data-testid="import-scad" on:click={importScadFile}>Import</button>
      <button data-testid="save-as" on:click={saveProjectAs}>Save As</button>
      <button data-testid="show-scad" on:click={() => (showScad = !showScad)}>
        {showScad ? "Tree" : "SCAD"}
      </button>
      <button
        data-testid="open-openscad"
        disabled={!getProjectDir()}
        on:click={openInOpenScad}
      >OpenSCAD</button>
    </div>
  </header>

  <section class="content" data-testid="content-area">
    <div class="toolbar">
      <button data-testid="add-element" on:click={() => addElement()}>+ Add Element</button>
    </div>
    {#if showScad}
      <pre class="scad-preview" data-testid="scad-preview">{scadOutput}</pre>
    {:else}
      <div class="tree-view" data-testid="tree-view">
        {#if $project.data.length === 0}
          <p class="empty-state">No elements yet. Click "+ Add Element" to start.</p>
        {:else}
          {#each $project.data as element, i (i)}
            <ElementNode
              {element}
              index={i}
              on:delete={() => deleteElement(i)}
              on:rename={(e) => renameElement(i, e.detail)}
            />
          {/each}
        {/if}
      </div>
    {/if}
  </section>

  <footer class="status-bar" data-testid="status-bar">
    <span data-testid="save-status">{statusMsg}</span>
    <span>Libs: —</span>
  </footer>

  {#if showIntent}
    <div class="intent-pane" data-testid="intent-pane">
      <input
        data-testid="intent-text"
        type="text"
        bind:value={intentText}
        placeholder="Describe what you expect to happen..."
      />
    </div>
  {/if}
</main>

<style>
  :global(body) {
    margin: 0;
    font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
    font-size: 14px;
    color: #1a1a1a;
    background: #f5f5f5;
  }

  main {
    display: flex;
    flex-direction: column;
    height: 100vh;
    overflow: hidden;
  }

  header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 8px 16px;
    background: #2c3e50;
    color: white;
  }

  header h1 {
    margin: 0;
    font-size: 18px;
    font-weight: 700;
  }

  .header-actions button {
    background: rgba(255, 255, 255, 0.15);
    color: white;
    border: 1px solid rgba(255, 255, 255, 0.3);
    padding: 4px 12px;
    border-radius: 4px;
    cursor: pointer;
    font-size: 13px;
  }

  .content {
    flex: 1;
    overflow-y: auto;
    padding: 8px 12px;
  }

  .toolbar {
    margin-bottom: 8px;
  }

  .toolbar button {
    background: #3498db;
    color: white;
    border: none;
    padding: 5px 14px;
    border-radius: 4px;
    cursor: pointer;
    font-size: 13px;
  }

  .tree-view {
    min-height: 100px;
  }

  .scad-preview {
    background: #1e1e1e;
    color: #d4d4d4;
    font-family: "Courier New", monospace;
    font-size: 12px;
    padding: 12px;
    border-radius: 4px;
    overflow: auto;
    margin: 0;
    white-space: pre;
    line-height: 1.4;
  }

  .empty-state {
    color: #999;
    text-align: center;
    margin-top: 40px;
  }

  .status-bar {
    display: flex;
    justify-content: space-between;
    padding: 3px 12px;
    background: #ecf0f1;
    border-top: 1px solid #ddd;
    font-size: 11px;
    color: #666;
  }

  .intent-pane {
    background: #1a1a2e;
    padding: 6px 12px;
    border-top: 2px solid #e74c3c;
  }

  .intent-pane input {
    width: 100%;
    box-sizing: border-box;
    background: #16213e;
    border: 1px solid #444;
    color: #e0e0e0;
    padding: 4px 8px;
    font-family: "Courier New", monospace;
    font-size: 13px;
    border-radius: 2px;
  }
</style>
