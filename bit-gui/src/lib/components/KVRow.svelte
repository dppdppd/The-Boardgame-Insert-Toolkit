<script lang="ts">
  import { getContextKeys, mergeWithDefaults, isOptionalNode } from "../schema";

  export let param: { key: string; value: any };
  export let context: string;
  export let depth: number = 0;
  export let parentType: string = "";

  let expanded = true;

  $: keyDefs = getContextKeys(context);
  $: keySchema = (keyDefs as any)[param.key] || null;
  $: keyType = keySchema?.type || "unknown";
  $: isNested = keyType === "table" || keyType === "table_list";
  $: childContext = keySchema?.child_context || context;
  $: defaultVal = keySchema?.default;
  $: isDefault = !isNested && JSON.stringify(param.value) === JSON.stringify(defaultVal);

  function formatValue(val: any): string {
    if (val === null || val === undefined) return "—";
    if (typeof val === "boolean") return val ? "true" : "false";
    if (Array.isArray(val)) {
      if (val.length > 0 && typeof val[0] === "object") return `(${val.length} items)`;
      return `[${val.join(", ")}]`;
    }
    return String(val);
  }
</script>

{#if isNested}
  <div class="kv-row nested" style="padding-left: {depth * 16}px" data-testid="kv-{param.key}">
    <button class="toggle" data-testid="kv-{param.key}-toggle" on:click={() => (expanded = !expanded)}>
      {expanded ? "▼" : "▶"}
    </button>
    <span class="key nested-key">{param.key}</span>
    {#if keyType === "table_list"}
      <span class="badge">{param.value?.length || 0}</span>
      <button class="add-btn" data-testid="kv-{param.key}-add">+</button>
    {/if}
  </div>
  {#if expanded}
    {#if keyType === "table_list"}
      {#each param.value as childParams, i}
        {@const merged = mergeWithDefaults(childParams, childContext)}
        <div class="child-group" style="padding-left: {(depth + 1) * 16}px">
          <div class="child-header">
            <span>Component {i + 1}</span>
            <button class="delete-btn" data-testid="kv-{param.key}-{i}-delete">✕</button>
          </div>
          {#each merged as childParam (childParam.key)}
            <svelte:self param={childParam} context={childContext} depth={depth + 2} />
          {/each}
        </div>
      {/each}
    {:else}
      {@const merged = mergeWithDefaults(param.value, childContext)}
      {#each merged as childParam (childParam.key)}
        <svelte:self param={childParam} context={childContext} depth={depth + 1} />
      {/each}
    {/if}
  {/if}
{:else}
  <div
    class="kv-row"
    class:muted={isDefault}
    style="padding-left: {depth * 16}px"
    data-testid="kv-{param.key}"
  >
    <span class="key" class:muted={isDefault}>{param.key}</span>
    <span class="value type-{keyType}" data-testid="kv-{param.key}-editor">
      {#if keyType === "bool"}
        <input type="checkbox" checked={param.value} disabled />
      {:else if keyType === "enum"}
        <select disabled>
          {#each keySchema?.values || [] as v}
            <option selected={v === param.value}>{v}</option>
          {/each}
        </select>
      {:else}
        {formatValue(param.value)}
      {/if}
    </span>
    {#if !isDefault}
      <button class="revert-btn" data-testid="kv-{param.key}-delete" title="Revert to default">✕</button>
    {/if}
  </div>
{/if}

<style>
  .kv-row {
    display: flex;
    align-items: center;
    padding: 3px 8px;
    gap: 8px;
    font-size: 13px;
    border-bottom: 1px solid #f0f0f0;
  }
  .kv-row:hover {
    background: #f8f9fa;
  }
  .kv-row.muted {
    opacity: 0.45;
  }
  .kv-row.muted:hover {
    opacity: 0.7;
  }
  .key {
    color: #2c3e50;
    font-weight: 500;
    min-width: 180px;
    font-family: "Courier New", monospace;
    font-size: 12px;
  }
  .key.muted {
    font-weight: 400;
  }
  .nested-key {
    color: #8e44ad;
    font-weight: 600;
  }
  .value {
    color: #333;
    font-family: "Courier New", monospace;
    font-size: 12px;
  }
  .toggle {
    background: none;
    border: none;
    cursor: pointer;
    padding: 0 4px;
    font-size: 10px;
    color: #666;
  }
  .badge {
    background: #3498db;
    color: white;
    border-radius: 8px;
    padding: 0 6px;
    font-size: 11px;
  }
  .add-btn {
    background: none;
    border: 1px dashed #bbb;
    color: #7f8c8d;
    padding: 0 6px;
    border-radius: 3px;
    cursor: pointer;
    font-size: 12px;
    line-height: 1.4;
  }
  .add-btn:hover {
    border-color: #3498db;
    color: #3498db;
  }
  .child-group {
    border-left: 2px solid #e0e0e0;
    margin: 2px 0;
  }
  .child-header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    font-size: 12px;
    color: #7f8c8d;
    font-weight: 600;
    padding: 3px 8px;
  }
  .delete-btn {
    background: none;
    border: none;
    color: #e74c3c;
    cursor: pointer;
    font-size: 12px;
    padding: 0 4px;
  }
  .revert-btn {
    background: none;
    border: none;
    color: #bbb;
    cursor: pointer;
    font-size: 11px;
    padding: 0 4px;
    margin-left: auto;
  }
  .revert-btn:hover {
    color: #e74c3c;
  }
  select {
    font-family: "Courier New", monospace;
    font-size: 12px;
    padding: 1px 4px;
  }
  input[type="checkbox"] {
    margin: 0;
  }
</style>
