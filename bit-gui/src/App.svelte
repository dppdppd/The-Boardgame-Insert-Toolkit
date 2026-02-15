<script lang="ts">
  let intentText = "";
</script>

<main data-testid="app-root">
  <header data-testid="app-header">
    <h1>BIT GUI</h1>
    <div class="header-actions">
      <button data-testid="options-open">Options</button>
    </div>
  </header>

  <section class="content" data-testid="content-area">
    <div class="toolbar">
      <button data-testid="add-element">+ Add Element</button>
    </div>
    <div class="tree-view" data-testid="tree-view">
      <p class="empty-state">No elements yet. Click "+ Add Element" to start.</p>
    </div>
  </section>

  <footer class="status-bar" data-testid="status-bar">
    <span data-testid="save-status">No project open</span>
    <span>Libs: —</span>
  </footer>

  <div class="intent-pane" data-testid="intent-pane">
    <input
      data-testid="intent-text"
      type="text"
      bind:value={intentText}
      placeholder="Describe what you expect to happen..."
    />
  </div>
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
    padding: 12px 16px;
    background: #2c3e50;
    color: white;
    min-height: 48px;
  }

  header h1 {
    margin: 0;
    font-size: 24px;
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
    padding: 12px 16px;
  }

  .toolbar {
    margin-bottom: 12px;
  }

  .toolbar button {
    background: #3498db;
    color: white;
    border: none;
    padding: 6px 16px;
    border-radius: 4px;
    cursor: pointer;
    font-size: 13px;
  }

  .tree-view {
    background: white;
    border: 1px solid #ddd;
    border-radius: 4px;
    min-height: 200px;
    padding: 16px;
  }

  .empty-state {
    color: #999;
    text-align: center;
    margin-top: 60px;
  }

  .status-bar {
    display: flex;
    justify-content: space-between;
    padding: 4px 16px;
    background: #ecf0f1;
    border-top: 1px solid #ddd;
    font-size: 12px;
    color: #666;
  }

  .intent-pane {
    background: #1a1a2e;
    padding: 6px 16px;
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
