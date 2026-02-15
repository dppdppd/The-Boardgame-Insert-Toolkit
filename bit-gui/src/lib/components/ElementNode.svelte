<script lang="ts">
  import KVRow from "./KVRow.svelte";
  import { mergeWithDefaults, getAddableNodes, createDefaultNode } from "../schema";
  import type { Element } from "../stores/project";

  export let element: Element;
  export let index: number;

  let expanded = true;

  $: context = element.type === "DIVIDERS" ? "divider" : "element";
  $: fullParams = mergeWithDefaults(element.params, context, element.type);
  $: addable = getAddableNodes(element.params, context, element.type);
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
      {#each fullParams as param (param.key)}
        <KVRow {param} {context} depth={1} />
      {/each}

      {#if addable.length > 0}
        <div class="add-nodes" style="padding-left: 16px">
          {#each addable as { key, def }}
            <button class="add-node-btn" data-testid="element-{index}-add-{key}">
              + {key.replace("BOX_", "").replace("_", " ")}
            </button>
          {/each}
        </div>
      {/if}
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
  .add-nodes {
    display: flex;
    gap: 6px;
    padding: 4px 0 6px;
  }
  .add-node-btn {
    background: none;
    border: 1px dashed #bbb;
    color: #7f8c8d;
    padding: 3px 10px;
    border-radius: 3px;
    cursor: pointer;
    font-size: 12px;
  }
  .add-node-btn:hover {
    border-color: #3498db;
    color: #3498db;
  }
</style>
