<script setup lang="ts">
defineProps<{ title: string; closeTo: string }>();
</script>

<template>
  <aside class="sheet">
    <header class="sheet-header">
      <h2 class="grow">{{ title }}</h2>
      <RouterLink :to="closeTo" class="close" aria-label="閉じる">✕</RouterLink>
    </header>
    <div class="sheet-body">
      <slot />
    </div>
  </aside>
</template>

<style scoped>
.sheet {
  display: grid;
  grid-template-rows: auto minmax(0, 1fr);
  min-height: 0;
  border-radius: var(--radius) 0 0 var(--radius);
  border: 1px solid var(--line);
  border-right: none;
  background: var(--surface);
  box-shadow: -8px 0 24px rgb(0 0 0 / 12%);
  animation: slide-in 0.2s ease;
}

.sheet-header {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 10px 12px 6px 16px;
}

h2 {
  font-size: 1rem;
  font-weight: 800;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.close {
  display: grid;
  place-items: center;
  width: 32px;
  height: 32px;
  border-radius: 999px;
  color: var(--ink-soft);
}

.close:hover {
  background: var(--surface-sunk);
}

.sheet-body {
  display: grid;
  align-content: start;
  gap: 10px;
  padding: 4px 16px 16px;
  overflow-y: auto;
}

@keyframes slide-in {
  from {
    transform: translateX(24px);
    opacity: 0;
  }
}
</style>
