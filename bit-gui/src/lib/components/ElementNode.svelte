<script lang="ts">
  import KVRow from "./KVRow.svelte";
  import type { Element } from "../stores/project";

  export let element: Element;
  export let index: number;

  let expanded = true;

  // Determine context based on element type
  $: context = element.type === "DIVIDERS" ? "divider" : "element";
</script>

<div class="element-node" data-testid="element-{index}">
  <div class="element-header" data-testid="element-{index}-header">
    <button
      class="toggle"
      data-testid="element-{index}-expand"
      on:click={() => (expanded = !expanded)}
    >
      {expanded ? "▼" : "▶"}
    </button>
    <span class="element-name" data-testid="element-{index}-name">
      "{element.name}"
    </span>
    <span class="element-type">({element.type})</span>
    <button class="delete-btn" data-testid="element-{index}-delete">✕</button>
  </div>

  {#if expanded}
    <div class="element-body">
      {#each element.params as param}
        <KVRow {param} {context} depth={1} />
      {/each}
      <div class="add-param" style="padding-left: 16px">
        <button data-testid="element-{index}-add-param">+ Add Parameter</button>
      </div>
    </div>
  {/if}
</div>

<style>
  .element-node {
    background: white;
    border: 1px solid #ddd;
    border-radius: 4px;
    margin-bottom: 8px;
  }
  .element-header {
    display: flex;
    align-items: center;
    padding: 6px 8px;
    gap: 6px;
    background: #f8f9fa;
    border-bottom: 1px solid #eee;
    border-radius: 4px 4px 0 0;
  }
  .toggle {
    background: none;
    border: none;
    cursor: pointer;
    padding: 0 4px;
    font-size: 10px;
    color: #666;
  }
  .element-name {
    font-weight: 600;
    color: #2c3e50;
    font-size: 14px;
  }
  .element-type {
    color: #7f8c8d;
    font-size: 12px;
  }
  .delete-btn {
    margin-left: auto;
    background: none;
    border: none;
    color: #e74c3c;
    cursor: pointer;
    font-size: 14px;
    padding: 0 4px;
  }
  .element-body {
    padding: 4px 0;
  }
  .add-param button {
    background: none;
    border: 1px dashed #bbb;
    color: #7f8c8d;
    padding: 3px 12px;
    border-radius: 3px;
    cursor: pointer;
    font-size: 12px;
    margin: 4px 0;
  }
  .add-param button:hover {
    border-color: #3498db;
    color: #3498db;
  }
</style>
