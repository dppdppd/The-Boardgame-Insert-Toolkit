<script lang="ts">
  import { schemaData } from "../stores/project";

  export let param: { key: string; value: any };
  export let context: string;
  export let depth: number = 0;

  let expanded = true;

  // Look up schema info for this key in the given context
  $: keySchema = schemaData.contexts[context]?.keys[param.key] || null;
  $: keyType = keySchema?.type || "unknown";
  $: isNested = keyType === "table" || keyType === "table_list";
  $: childContext = keySchema?.child_context || context;

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
    <button
      class="toggle"
      data-testid="kv-{param.key}-toggle"
      on:click={() => (expanded = !expanded)}
    >
      {expanded ? "▼" : "▶"}
    </button>
    <span class="key nested-key">{param.key}</span>
    {#if keyType === "table_list"}
      <span class="badge">{param.value?.length || 0}</span>
    {/if}
  </div>
  {#if expanded}
    {#if keyType === "table_list"}
      {#each param.value as childParams, i}
        <div class="child-group" style="padding-left: {(depth + 1) * 16}px">
          <div class="child-header">{param.key.replace("BOX_", "").replace("CMP_", "")} {i + 1}</div>
          {#each childParams as childParam}
            <svelte:self param={childParam} context={childContext} depth={depth + 2} />
          {/each}
        </div>
      {/each}
    {:else}
      {#each param.value as childParam}
        <svelte:self param={childParam} context={childContext} depth={depth + 1} />
      {/each}
    {/if}
  {/if}
{:else}
  <div class="kv-row" style="padding-left: {depth * 16}px" data-testid="kv-{param.key}">
    <span class="key">{param.key}</span>
    <span class="value type-{keyType}" data-testid="kv-{param.key}-editor">
      {#if keyType === "bool"}
        <input type="checkbox" checked={param.value} disabled />
      {:else if keyType === "enum"}
        <select disabled>
          <option>{param.value}</option>
        </select>
      {:else}
        {formatValue(param.value)}
      {/if}
    </span>
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
  .key {
    color: #2c3e50;
    font-weight: 500;
    min-width: 180px;
    font-family: "Courier New", monospace;
    font-size: 12px;
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
  .child-group {
    border-left: 2px solid #e0e0e0;
    margin: 2px 0;
  }
  .child-header {
    font-size: 12px;
    color: #7f8c8d;
    font-weight: 600;
    padding: 3px 8px;
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
