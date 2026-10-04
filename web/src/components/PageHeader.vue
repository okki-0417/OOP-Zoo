<script setup lang="ts">
defineProps<{ title: string; back?: string; subtitle?: string }>();
</script>

<template>
  <header class="page-header">
    <RouterLink v-if="back" :to="back" class="back" aria-label="戻る">‹</RouterLink>
    <div class="titles">
      <h1>{{ title }}</h1>
      <p v-if="subtitle" class="muted">{{ subtitle }}</p>
    </div>
    <div class="actions"><slot /></div>
  </header>
</template>

<style scoped>
.page-header {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 20px 4px 8px;
}

.back {
  display: grid;
  place-items: center;
  width: 36px;
  height: 36px;
  border-radius: 50%;
  background: var(--surface);
  border: 1px solid var(--line);
  font-size: 1.6rem;
  line-height: 1;
  padding-bottom: 3px;
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
