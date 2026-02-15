<script lang="ts">
  import { getContextKeys, mergeWithDefaults, isOptionalNode } from "../schema";
  import { moveComponent, duplicateComponent, deleteComponent } from "../stores/project";

  let { param, context, depth = 0, elementIndex = -1, onchange } = $props();


  let expanded = $state(true);

  let keyDefs = $derived.by(() => getContextKeys(context));
  let keySchema = $derived(keyDefs[param.key] || null);
  let keyType = $derived(keySchema?.type || "unknown");
  let isNested = $derived(keyType === "table" || keyType === "table_list");
  let childContext = $derived(keySchema?.child_context || context);
  let defaultVal = $derived(keySchema?.default);
  let isExpr = $derived(param.value && typeof param.value === "object" && "__expr" in param.value);
  let isDefault = $derived(!isNested && !isExpr && JSON.stringify(param.value) === JSON.stringify(defaultVal));

  function update(newValue) {
    param.value = newValue;
    if (onchange) onchange({ detail: { key: param.key, value: newValue } });
  }

  function revert() {
    if (defaultVal !== undefined) {
      update(structuredClone(defaultVal));
    }
  }

  // Helpers for array-based types
  function updateIndex(arr, i, val) {
    const copy = [...arr];
    copy[i] = val;
    return copy;
  }

  function parseNum(s) {
    const n = parseFloat(s);
    return isNaN(n) ? 0 : n;
  }

  const SIDE_LABELS = ["F", "B", "L", "R"];
</script>

{#if isNested}
  <!-- Nested: table or table_list -->
  <div class="kv-row nested" style="padding-left: {depth * 16}px" data-testid="kv-{param.key}">
    <button class="toggle" data-testid="kv-{param.key}-toggle" onclick={() => (expanded = !expanded)}>
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
            <span class="child-actions">
              <button class="action-btn" title="Move up" onclick={() => moveComponent(elementIndex, i, -1)}>▲</button>
              <button class="action-btn" title="Move down" onclick={() => moveComponent(elementIndex, i, 1)}>▼</button>
              <button class="action-btn" title="Duplicate" onclick={() => duplicateComponent(elementIndex, i)}>⧉</button>
              <button class="delete-btn" data-testid="kv-{param.key}-{i}-delete" onclick={() => deleteComponent(elementIndex, i)}>✕</button>
            </span>
          </div>
          {#each merged as childParam (childParam.key)}
            <svelte:self param={childParam} context={childContext} depth={depth + 2} {elementIndex} {onchange} />
          {/each}
        </div>
      {/each}
    {:else}
      {@const merged = mergeWithDefaults(param.value, childContext)}
      {#each merged as childParam (childParam.key)}
        <svelte:self param={childParam} context={childContext} depth={depth + 1} {elementIndex} {onchange} />
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
          onchange={(e) => update({ __expr: e.currentTarget.value })}
          data-testid="kv-{param.key}-expr"
        />
      {:else if keyType === "bool"}
        <input
          type="checkbox"
          checked={param.value}
          onchange={(e) => update(e.currentTarget.checked)}
        />

      {:else if keyType === "enum"}
        <select
          value={param.value}
          onchange={(e) => update(e.currentTarget.value)}
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
          onchange={(e) => update(parseNum(e.currentTarget.value))}
          data-testid="kv-{param.key}-val"
        />

      {:else if keyType === "string"}
        <input
          class="str-input"
          type="text"
          value={param.value ?? ""}
          onchange={(e) => update(e.currentTarget.value)}
          data-testid="kv-{param.key}-val"
        />

      {:else if keyType === "xy"}
        <input
          class="num-input sm"
          type="number" step="any"
          value={param.value?.[0] ?? 0}
          onchange={(e) => update(updateIndex(param.value, 0, parseNum(e.currentTarget.value)))}
          data-testid="kv-{param.key}-x"
        />
        <input
          class="num-input sm"
          type="number" step="any"
          value={param.value?.[1] ?? 0}
          onchange={(e) => update(updateIndex(param.value, 1, parseNum(e.currentTarget.value)))}
          data-testid="kv-{param.key}-y"
        />

      {:else if keyType === "xyz"}
        <input
          class="num-input sm"
          type="number" step="any"
          value={param.value?.[0] ?? 0}
          onchange={(e) => update(updateIndex(param.value, 0, parseNum(e.currentTarget.value)))}
          data-testid="kv-{param.key}-x"
        />
        <input
          class="num-input sm"
          type="number" step="any"
          value={param.value?.[1] ?? 0}
          onchange={(e) => update(updateIndex(param.value, 1, parseNum(e.currentTarget.value)))}
          data-testid="kv-{param.key}-y"
        />
        <input
          class="num-input sm"
          type="number" step="any"
          value={param.value?.[2] ?? 0}
          onchange={(e) => update(updateIndex(param.value, 2, parseNum(e.currentTarget.value)))}
          data-testid="kv-{param.key}-z"
        />

      {:else if keyType === "4bool"}
        {#each [0, 1, 2, 3] as i}
          <label class="side-label">
            <span class="side-tag">{SIDE_LABELS[i]}</span>
            <input
              type="checkbox"
              checked={param.value?.[i] ?? false}
              onchange={(e) => update(updateIndex(param.value, i, e.currentTarget.checked))}
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
              onchange={(e) => update(updateIndex(param.value, i, parseNum(e.currentTarget.value)))}
            />
          </label>
        {/each}

      {:else if keyType === "position_xy"}
        {#each [0, 1] as i}
          <input
            class="str-input sm"
            type="text"
            value={param.value?.[i] ?? ""}
            onchange={(e) => {
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
          onchange={(e) => update(e.currentTarget.value.split(",").map((s) => s.trim()).filter(Boolean))}
          data-testid="kv-{param.key}-val"
          placeholder="comma-separated"
        />

      {:else}
        <span class="fallback">{JSON.stringify(param.value)}</span>
      {/if}
    </span>

    {#if !isDefault}
      <button class="revert-btn" data-testid="kv-{param.key}-delete" title="Revert to default" onclick={revert}>✕</button>
    {/if}
  </div>
{/if}

<style>
  .kv-row {
    display: flex;
    align-items: center;
    padding: 1px 8px;
    gap: 4px;
    font-size: 12px;
    border-bottom: 1px solid #f5f5f5;
    min-height: 20px;
  }
  .kv-row:hover { background: #f8f9fa; }
  .kv-row.muted { opacity: 0.45; }
  .kv-row.muted:hover { opacity: 0.7; }

  .key {
    color: #2c3e50;
    font-weight: 500;
    min-width: 150px;
    font-family: "Courier New", monospace;
    font-size: 10px;
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
    font-size: 11px;
    padding: 0px 3px;
    border: 1px solid #ddd;
    border-radius: 2px;
    background: white;
    height: 18px;
  }
  .num-input { width: 56px; }
  .num-input.sm { width: 44px; }
  .num-input.xs { width: 36px; }
  .str-input { width: 110px; }
  .str-input.sm { width: 56px; }
  .str-input.wide { width: 180px; }
  .str-input.expr { color: #e67e22; font-style: italic; }
  select { padding: 1px 2px; }
  input[type="checkbox"] { margin: 0; }

  /* 4bool / 4num side labels */
  .side-label {
    display: inline-flex;
    align-items: center;
    gap: 0px;
    font-size: 10px;
  }
  .side-tag {
    color: #999;
    font-size: 9px;
    font-weight: 600;
    width: 9px;
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
    margin: 1px 0;
  }
  .child-header {
    display: flex;
    align-items: center;
    font-size: 11px;
    color: #7f8c8d;
    font-weight: 600;
    padding: 1px 8px;
  }
  .child-actions {
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
    font-size: 12px;
    padding: 0 4px;
  }
  .delete-btn:hover { color: #e74c3c; }
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
