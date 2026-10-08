<script setup lang="ts">
import AlertBell from "./AlertBell.vue";
import ZooStatus from "./ZooStatus.vue";

defineProps<{ title: string; subtitle?: string }>();
</script>

<template>
  <header class="page-header">
    <h1>{{ title }}</h1>
    <p v-if="subtitle" class="muted subtitle">{{ subtitle }}</p>
    <div class="actions"><slot /></div>
    <ZooStatus />
    <AlertBell />
  </header>
</template>

<style scoped>
.page-header {
  display: flex;
  align-items: center;
  gap: 10px;
  height: 52px;
}

h1 {
  font-size: 1.1rem;
  font-weight: 800;
  letter-spacing: 0.02em;
  white-space: nowrap;
}

.subtitle {
  font-size: 0.75rem;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  min-width: 0;
}

.actions {
  flex: 1;
  display: flex;
  justify-content: flex-end;
  gap: 6px;
}
</style>
