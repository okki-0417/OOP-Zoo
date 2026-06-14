<script setup lang="ts">
const props = defineProps<{ label: string; value: number; max: number; color: string }>()
const pct = () => Math.max(0, Math.min(100, (props.value / props.max) * 100))
</script>

<template>
  <div class="meter">
    <div class="meter-label"><span>{{ label }}</span><span>{{ value }}/{{ max }}</span></div>
    <div class="meter-track"><div class="meter-fill" :style="{ width: pct() + '%', background: color }" /></div>
  </div>
</template>
