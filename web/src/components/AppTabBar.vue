<script setup lang="ts">
const tabs = [
  { to: "/", label: "園長室", icon: "🏛️" },
  { to: "/animals", label: "どうぶつ", icon: "🦒" },
  { to: "/enclosures", label: "エリア", icon: "🌳" },
  { to: "/staff", label: "スタッフ", icon: "🧑‍🌾" },
];
</script>

<template>
  <nav class="tabbar">
    <RouterLink
      v-for="tab in tabs"
      :key="tab.to"
      :to="tab.to"
      class="tab"
      :exact-active-class="tab.to === '/' ? 'active' : ''"
      :active-class="tab.to === '/' ? '' : 'active'"
    >
      <span class="icon">{{ tab.icon }}</span>
      <span class="label">{{ tab.label }}</span>
    </RouterLink>
  </nav>
</template>

<style scoped>
.tabbar {
  position: fixed;
  inset: auto 0 0;
  z-index: 10;
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  height: calc(var(--tabbar-height) + env(safe-area-inset-bottom));
  padding-bottom: env(safe-area-inset-bottom);
  background: color-mix(in srgb, var(--surface) 92%, transparent);
  backdrop-filter: blur(12px);
  border-top: 1px solid var(--line);
}

.tab {
  display: grid;
  place-content: center;
  justify-items: center;
  gap: 2px;
  color: var(--ink-soft);
  font-size: 0.7rem;
  font-weight: 700;
}

.icon {
  font-size: 1.35rem;
  filter: grayscale(0.8);
  opacity: 0.7;
  transition: transform 0.15s ease;
}

.active {
  color: var(--brand);
}

.active .icon {
  filter: none;
  opacity: 1;
  transform: translateY(-2px) scale(1.1);
}
</style>
