<script setup lang="ts">
import AlertBell from "./AlertBell.vue";

defineProps<{ title: string; crumbs?: { label: string; to: string }[]; subtitle?: string }>();
</script>

<template>
  <header class="page-header">
    <div class="titles">
      <nav v-if="crumbs?.length" class="crumbs" aria-label="現在地">
        <template v-for="crumb in crumbs" :key="crumb.to">
          <RouterLink :to="crumb.to">{{ crumb.label }}</RouterLink>
          <span aria-hidden="true">›</span>
        </template>
      </nav>
      <h1>{{ title }}</h1>
      <p v-if="subtitle" class="muted">{{ subtitle }}</p>
    </div>
    <div class="actions"><slot /></div>
    <AlertBell />
  </header>
</template>

<style scoped>
.page-header {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 20px 4px 8px;
}

.crumbs {
  display: flex;
  flex-wrap: wrap;
  gap: 6px;
  margin-bottom: 2px;
  font-size: 0.85rem;
  font-weight: 700;
  color: var(--ink-soft);
}

.crumbs a:hover {
  color: var(--brand);
  text-decoration: underline;
}

.titles {
  flex: 1;
  min-width: 0;
}

h1 {
  font-size: 1.5rem;
  font-weight: 800;
  letter-spacing: 0.02em;
}
</style>
