<script setup lang="ts">
import { computed } from "vue";
import { percent } from "../format";

const props = defineProps<{
  label: string;
  value: number;
  max: number;
  invert?: boolean;
}>();

const ratio = computed(() => percent(props.value, props.max));
const tone = computed(() => {
  const goodness = props.invert ? 100 - ratio.value : ratio.value;
  if (goodness >= 60) return "good";
  if (goodness >= 30) return "warn";
  return "bad";
});
</script>

<template>
  <div class="meter">
    <div class="head">
      <span>{{ label }}</span>
      <span class="value"
        >{{ value }}<small> / {{ max }}</small></span
      >
    </div>
    <div class="track">
      <div class="fill" :class="tone" :style="{ width: `${ratio}%` }" />
    </div>
  </div>
</template>

<style scoped>
.meter {
  display: grid;
  gap: 4px;
}

.head {
  display: flex;
  justify-content: space-between;
  font-size: 0.75rem;
  font-weight: 700;
  color: var(--ink-soft);
}

.value {
  color: var(--ink);
  font-variant-numeric: tabular-nums;
}

.value small {
  color: var(--ink-soft);
  font-weight: 400;
}

.track {
  height: 8px;
  border-radius: 999px;
  background: var(--surface-sunk);
  overflow: hidden;
}

.fill {
  height: 100%;
  border-radius: inherit;
  transition: width 0.4s ease;
}

.good {
  background: var(--good);
}

.warn {
  background: var(--warn);
}

.bad {
  background: var(--bad);
}
</style>
