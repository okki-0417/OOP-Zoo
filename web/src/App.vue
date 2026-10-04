<script setup lang="ts">
import AppTabBar from "./components/AppTabBar.vue";
import ToastStack from "./components/ToastStack.vue";
</script>

<template>
  <main class="shell">
    <RouterView />
  </main>
  <AppTabBar />
  <ToastStack />
</template>

<style scoped>
.shell {
  max-width: 480px;
  margin: 0 auto;
  padding: 0 16px calc(var(--tabbar-height) + env(safe-area-inset-bottom) + 24px);
}
</style>
