<script setup lang="ts">
const tabs = [
  { to: "/", label: "園長室", icon: "🏛️" },
  { to: "/animals", label: "どうぶつ", icon: "🦒" },
  { to: "/enclosures", label: "エリア", icon: "🌳" },
  { to: "/staff", label: "スタッフ", icon: "🧑‍🌾" },
];
</script>

<template>
  <nav class="sidenav">
    <RouterLink to="/" class="brand">
      <span class="icon">🦁</span>
      <span class="label">OOP-Zoo</span>
    </RouterLink>
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
.sidenav {
  position: sticky;
  top: 0;
  display: flex;
  flex-direction: column;
  gap: 4px;
  height: 100dvh;
  padding: 20px 12px;
  background: var(--surface);
  border-right: 1px solid var(--line);
}

.brand {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 4px 12px 20px;
  font-size: 1.2rem;
  font-weight: 800;
  letter-spacing: 0.02em;
}

.tab {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 10px 12px;
  border-radius: 12px;
  color: var(--ink-soft);
  font-weight: 700;
  transition: background 0.15s ease;
}

.tab:hover {
  background: var(--surface-sunk);
}

.icon {
  font-size: 1.3rem;
}

.tab .icon {
  filter: grayscale(0.8);
  opacity: 0.7;
}

.active {
  background: color-mix(in srgb, var(--brand) 14%, transparent);
  color: var(--brand);
}

.active .icon {
  filter: none;
  opacity: 1;
}

@media (width < 900px) {
  .sidenav {
    padding: 20px 8px;
  }

  .label {
    display: none;
  }

  .brand,
  .tab {
    justify-content: center;
    padding-inline: 0;
  }
}
</style>
