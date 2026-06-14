<script setup lang="ts">
defineProps<{ text: string; color?: string }>()
</script>

<template>
  <span class="badge" :style="color ? { borderColor: color, color } : {}">{{ text }}</span>
</template>
