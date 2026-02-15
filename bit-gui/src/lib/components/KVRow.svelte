<script lang="ts">
  import { createEventDispatcher } from "svelte";
  import { getContextKeys, mergeWithDefaults, isOptionalNode } from "../schema";

  export let param: { key: string; value: any };
  export let context: string;
  export let depth: number = 0;

  const dispatch = createEventDispatcher();

  let expanded = true;

  $: keyDefs = getContextKeys(context);
  $: keySchema = (keyDefs as any)[param.key] || null;
  $: keyType = keySchema?.type || "unknown";
  $: isNested = keyType === "table" || keyType === "table_list";
  $: childContext = keySchema?.child_context || context;
  $: defaultVal = keySchema?.default;
  $: isExpr = param.value && typeof param.value === "object" && "__expr" in param.value;
  $: isDefault = !isNested && !isExpr && JSON.stringify(param.value) === JSON.stringify(defaultVal);

  function update(newValue: any) {
    param.value = newValue;
    dispatch("change", { key: param.key, value: newValue });
  }

  function revert() {
    if (defaultVal !== undefined) {
      update(structuredClone(defaultVal));
    }
  }

  // Helpers for array-based types
  function updateIndex(arr: any[], i: number, val: any): any[] {
    const copy = [...arr];
    copy[i] = val;
    return copy;
  }

  function parseNum(s: string): number {
    const n = parseFloat(s);
    return isNaN(n) ? 0 : n;
  }

  const SIDE_LABELS = ["F", "B", "L", "R"];
</script>

{#if isNested}
  <!-- Nested: table or table_list -->
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
  <!-- Scalar row -->
  <div
    class="kv-row"
    class:muted={isDefault}
    style="padding-left: {depth * 16}px"
    data-testid="kv-{param.key}"
  >
    <span class="key" class:muted={isDefault}>{param.key}</span>

    <span class="value" data-testid="kv-{param.key}-editor">
      {#if isExpr}
        <input
          class="str-input wide expr"
          type="text"
          value={param.value.__expr}
          on:change={(e) => update({ __expr: e.currentTarget.value })}
          data-testid="kv-{param.key}-expr"
        />
      {:else if keyType === "bool"}
        <input
          type="checkbox"
          checked={param.value}
          on:change={(e) => update(e.currentTarget.checked)}
        />

      {:else if keyType === "enum"}
        <select
          value={param.value}
          on:change={(e) => update(e.currentTarget.value)}
        >
          {#each keySchema?.values || [] as v}
            <option value={v}>{v}</option>
          {/each}
        </select>

      {:else if keyType === "number"}
        <input
          class="num-input"
          type="number"
          step="any"
          value={param.value}
          on:change={(e) => update(parseNum(e.currentTarget.value))}
          data-testid="kv-{param.key}-val"
        />

      {:else if keyType === "string"}
        <input
          class="str-input"
          type="text"
          value={param.value ?? ""}
          on:change={(e) => update(e.currentTarget.value)}
          data-testid="kv-{param.key}-val"
        />

      {:else if keyType === "xy"}
        <input
          class="num-input sm"
          type="number" step="any"
          value={param.value?.[0] ?? 0}
          on:change={(e) => update(updateIndex(param.value, 0, parseNum(e.currentTarget.value)))}
          data-testid="kv-{param.key}-x"
        />
        <input
          class="num-input sm"
          type="number" step="any"
          value={param.value?.[1] ?? 0}
          on:change={(e) => update(updateIndex(param.value, 1, parseNum(e.currentTarget.value)))}
          data-testid="kv-{param.key}-y"
        />

      {:else if keyType === "xyz"}
        <input
          class="num-input sm"
          type="number" step="any"
          value={param.value?.[0] ?? 0}
          on:change={(e) => update(updateIndex(param.value, 0, parseNum(e.currentTarget.value)))}
          data-testid="kv-{param.key}-x"
        />
        <input
          class="num-input sm"
          type="number" step="any"
          value={param.value?.[1] ?? 0}
          on:change={(e) => update(updateIndex(param.value, 1, parseNum(e.currentTarget.value)))}
          data-testid="kv-{param.key}-y"
        />
        <input
          class="num-input sm"
          type="number" step="any"
          value={param.value?.[2] ?? 0}
          on:change={(e) => update(updateIndex(param.value, 2, parseNum(e.currentTarget.value)))}
          data-testid="kv-{param.key}-z"
        />

      {:else if keyType === "4bool"}
        {#each [0, 1, 2, 3] as i}
          <label class="side-label">
            <span class="side-tag">{SIDE_LABELS[i]}</span>
            <input
              type="checkbox"
              checked={param.value?.[i] ?? false}
              on:change={(e) => update(updateIndex(param.value, i, e.currentTarget.checked))}
            />
          </label>
        {/each}

      {:else if keyType === "4num"}
        {#each [0, 1, 2, 3] as i}
          <label class="side-label">
            <span class="side-tag">{SIDE_LABELS[i]}</span>
            <input
              class="num-input xs"
              type="number" step="any"
              value={param.value?.[i] ?? 0}
              on:change={(e) => update(updateIndex(param.value, i, parseNum(e.currentTarget.value)))}
            />
          </label>
        {/each}

      {:else if keyType === "position_xy"}
        {#each [0, 1] as i}
          <input
            class="str-input sm"
            type="text"
            value={param.value?.[i] ?? ""}
            on:change={(e) => {
              const raw = e.currentTarget.value;
              const parsed = (raw === "CENTER" || raw === "MAX") ? raw : parseNum(raw);
              update(updateIndex(param.value, i, parsed));
            }}
            data-testid="kv-{param.key}-{i === 0 ? 'x' : 'y'}"
          />
        {/each}

      {:else if keyType === "string_list"}
        <input
          class="str-input wide"
          type="text"
          value={(param.value || []).join(", ")}
          on:change={(e) => update(e.currentTarget.value.split(",").map((s) => s.trim()).filter(Boolean))}
          data-testid="kv-{param.key}-val"
          placeholder="comma-separated"
        />

      {:else}
        <span class="fallback">{JSON.stringify(param.value)}</span>
      {/if}
    </span>

    {#if !isDefault}
      <button class="revert-btn" data-testid="kv-{param.key}-delete" title="Revert to default" on:click={revert}>✕</button>
    {/if}
  </div>
{/if}

<style>
  .kv-row {
    display: flex;
    align-items: center;
    padding: 2px 8px;
    gap: 6px;
    font-size: 13px;
    border-bottom: 1px solid #f0f0f0;
    min-height: 26px;
  }
  .kv-row:hover { background: #f8f9fa; }
  .kv-row.muted { opacity: 0.45; }
  .kv-row.muted:hover { opacity: 0.7; }

  .key {
    color: #2c3e50;
    font-weight: 500;
    min-width: 170px;
    font-family: "Courier New", monospace;
    font-size: 11px;
    flex-shrink: 0;
  }
  .key.muted { font-weight: 400; }
  .nested-key { color: #8e44ad; font-weight: 600; }

  .value {
    display: flex;
    align-items: center;
    gap: 4px;
    flex: 1;
    min-width: 0;
  }

  /* Input styles */
  .num-input, .str-input, select {
    font-family: "Courier New", monospace;
    font-size: 12px;
    padding: 1px 4px;
    border: 1px solid #ccc;
    border-radius: 2px;
    background: white;
  }
  .num-input { width: 64px; }
  .num-input.sm { width: 52px; }
  .num-input.xs { width: 40px; }
  .str-input { width: 120px; }
  .str-input.sm { width: 64px; }
  .str-input.wide { width: 200px; }
  .str-input.expr { color: #e67e22; font-style: italic; }
  select { padding: 1px 2px; }
  input[type="checkbox"] { margin: 0; }

  /* 4bool / 4num side labels */
  .side-label {
    display: inline-flex;
    align-items: center;
    gap: 1px;
    font-size: 11px;
  }
  .side-tag {
    color: #999;
    font-size: 10px;
    font-weight: 600;
    width: 10px;
    text-align: center;
  }

  .fallback {
    color: #999;
    font-family: "Courier New", monospace;
    font-size: 11px;
  }

  /* Nested styles */
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
  .add-btn:hover { border-color: #3498db; color: #3498db; }
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
    flex-shrink: 0;
  }
  .revert-btn:hover { color: #e74c3c; }
</style>
