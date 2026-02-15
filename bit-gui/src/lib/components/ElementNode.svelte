<script>
  import { createEventDispatcher } from "svelte";
  import KVRow from "./KVRow.svelte";
  import { mergeWithDefaults, getAddableNodes } from "../schema";
  import { updateParam, addComponent, addSubNode, moveElement, duplicateElement } from "../stores/project";

  export let element;
  export let index;

  const dispatch = createEventDispatcher();

  let expanded = true;
  let editingName = false;
  let nameInput = element.name;

  $: context = element.type === "DIVIDERS" ? "divider" : "element";
  $: fullParams = mergeWithDefaults(element.params, context, element.type);
  $: addable = getAddableNodes(element.params, context, element.type);

  function handleParamChange(e, paramKey) {
    updateParam(index, [paramKey], e.detail.value);
  }

  function commitName() {
    editingName = false;
    if (nameInput.trim() && nameInput !== element.name) {
      dispatch("rename", nameInput.trim());
    } else {
      nameInput = element.name;
    }
  }
</script>

{#if element.__expr}
<div class="element-node expr-node" data-testid="element-{index}">
  <div class="element-header" data-testid="element-{index}-header">
    <span class="expr-text">{element.__expr}</span>
    <button class="delete-btn" data-testid="element-{index}-delete" on:click={() => dispatch("delete")}>✕</button>
  </div>
</div>
{:else}
<div class="element-node" data-testid="element-{index}">
  <div class="element-header" data-testid="element-{index}-header">
    <button
      class="toggle"
      data-testid="element-{index}-expand"
      on:click={() => (expanded = !expanded)}
    >
      {expanded ? "▼" : "▶"}
    </button>

    {#if editingName}
      <input
        class="name-input"
        type="text"
        bind:value={nameInput}
        on:blur={commitName}
        on:keydown={(e) => { if (e.key === "Enter") commitName(); if (e.key === "Escape") { editingName = false; nameInput = element.name; } }}
        data-testid="element-{index}-name-input"
      />
    {:else}
      <span
        class="element-name"
        data-testid="element-{index}-name"
        on:dblclick={() => { editingName = true; nameInput = element.name; }}
      >
        "{element.name}"
      </span>
    {/if}

    <span class="element-type">({element.type})</span>
    <span class="element-actions">
      <button class="action-btn" title="Move up" on:click={() => moveElement(index, -1)}>▲</button>
      <button class="action-btn" title="Move down" on:click={() => moveElement(index, 1)}>▼</button>
      <button class="action-btn" title="Duplicate" on:click={() => duplicateElement(index)}>⧉</button>
      <button class="delete-btn" data-testid="element-{index}-delete" on:click={() => dispatch("delete")}>✕</button>
    </span>
  </div>

  {#if expanded}
    <div class="element-body">
      {#each fullParams as param (param.key)}
        <KVRow
          {param}
          {context}
          depth={1}
          elementIndex={index}
          on:change={(e) => handleParamChange(e, param.key)}
        />
      {/each}

      {#if addable.length > 0 || element.type === "BOX"}
        <div class="add-nodes" style="padding-left: 16px">
          {#each addable as { key, def }}
            <button
              class="add-node-btn"
              data-testid="element-{index}-add-{key}"
              on:click={() => addSubNode(index, key, def.child_context || context)}
            >
              + {key.replace("BOX_", "")}
            </button>
          {/each}
        </div>
      {/if}
    </div>
  {/if}
</div>
{/if}

<style>
  .element-node {
    background: white;
    border: 1px solid #ddd;
    border-radius: 3px;
    margin-bottom: 4px;
  }
  .expr-node {
    background: #fef9e7;
    border-color: #f0c040;
  }
  .expr-text {
    font-family: "Courier New", monospace;
    font-size: 12px;
    color: #e67e22;
    font-style: italic;
  }
  .element-header {
    display: flex;
    align-items: center;
    padding: 3px 6px;
    gap: 4px;
    background: #f8f9fa;
    border-bottom: 1px solid #eee;
    border-radius: 3px 3px 0 0;
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
    font-size: 12px;
    cursor: pointer;
  }
  .element-name:hover { text-decoration: underline; }
  .name-input {
    font-weight: 600;
    font-size: 12px;
    border: 1px solid #3498db;
    border-radius: 2px;
    padding: 0px 3px;
    width: 120px;
    height: 18px;
  }
  .element-type {
    color: #7f8c8d;
    font-size: 10px;
  }
  .element-actions {
    margin-left: auto;
    display: flex;
    gap: 2px;
  }
  .action-btn {
    background: none;
    border: none;
    color: #999;
    cursor: pointer;
    font-size: 11px;
    padding: 0 3px;
  }
  .action-btn:hover { color: #3498db; }
  .delete-btn {
    background: none;
    border: none;
    color: #ccc;
    cursor: pointer;
    font-size: 14px;
    padding: 0 4px;
  }
  .delete-btn:hover { color: #e74c3c; }
  .element-body {
    padding: 2px 0;
  }
  .add-nodes {
    display: flex;
    gap: 4px;
    padding: 2px 0 4px;
  }
  .add-node-btn {
    background: none;
    border: 1px dashed #ccc;
    color: #999;
    padding: 1px 8px;
    border-radius: 2px;
    cursor: pointer;
    font-size: 10px;
  }
  .add-node-btn:hover {
    border-color: #3498db;
    color: #3498db;
  }
</style>
