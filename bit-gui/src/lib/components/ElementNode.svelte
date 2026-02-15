<script lang="ts">
  import { createEventDispatcher } from "svelte";
  import KVRow from "./KVRow.svelte";
  import { mergeWithDefaults, getAddableNodes } from "../schema";
  import { updateParam, addComponent, addSubNode } from "../stores/project";
  import type { Element } from "../stores/project";

  export let element: Element;
  export let index: number;

  const dispatch = createEventDispatcher();

  let expanded = true;
  let editingName = false;
  let nameInput = element.name;

  $: context = element.type === "DIVIDERS" ? "divider" : "element";
  $: fullParams = mergeWithDefaults(element.params, context, element.type);
  $: addable = getAddableNodes(element.params, context, element.type);

  function handleParamChange(e: CustomEvent, paramKey: string) {
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
    <button
      class="delete-btn"
      data-testid="element-{index}-delete"
      on:click={() => dispatch("delete")}
    >✕</button>
  </div>

  {#if expanded}
    <div class="element-body">
      {#each fullParams as param (param.key)}
        <KVRow
          {param}
          {context}
          depth={1}
          elementIndex={index}
          paramPath={[]}
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
    cursor: pointer;
  }
  .element-name:hover { text-decoration: underline; }
  .name-input {
    font-weight: 600;
    font-size: 14px;
    border: 1px solid #3498db;
    border-radius: 2px;
    padding: 1px 4px;
    width: 140px;
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
