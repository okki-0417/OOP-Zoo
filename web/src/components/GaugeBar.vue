<script setup lang="ts">
import { computed } from "vue";

const props = withDefaults(
  defineProps<{ value: number; max: number; min?: number; marker?: number; invert?: boolean }>(),
  { min: 0, marker: undefined, invert: false },
);

const position = (value: number) =>
  Math.max(0, Math.min(100, ((value - props.min) / (props.max - props.min)) * 100));

const zero = computed(() => position(0));
const end = computed(() => position(props.value));
const fill = computed(() => ({
  left: `${Math.min(zero.value, end.value)}%`,
  width: `${Math.abs(end.value - zero.value)}%`,
}));
const signed = computed(() => props.min < 0);
const tone = computed(() => {
  if (signed.value) return props.value < 0 ? "bad" : "good";
  const goodness = props.invert ? 100 - end.value : end.value;
  if (goodness >= 60) return "good";
  if (goodness >= 30) return "warn";
  return "bad";
});
</script>

<template>
  <div class="gauge" role="meter" :aria-valuenow="value" :aria-valuemin="min" :aria-valuemax="max">
    <div class="fill" :class="tone" :style="fill" />
    <div v-if="signed" class="axis" :style="{ left: `${zero}%` }" />
    <div v-if="marker !== undefined" class="marker" :style="{ left: `${position(marker)}%` }" />
  </div>
</template>

<style scoped>
.gauge {
  position: relative;
  height: 10px;
  border-radius: 999px;
  background: var(--surface-sunk);
}

.fill {
  position: absolute;
  top: 0;
  bottom: 0;
  border-radius: 999px;
  transition:
    left 0.4s ease,
    width 0.4s ease;
}

.axis {
  position: absolute;
  top: -3px;
  bottom: -3px;
  width: 1px;
  background: var(--ink-soft);
}

.marker {
  position: absolute;
  top: -4px;
  bottom: -4px;
  width: 3px;
  margin-left: -1px;
  border-radius: 2px;
  background: var(--ink);
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
