<script setup lang="ts">
import AppSideNav from "./components/AppSideNav.vue";
import ToastStack from "./components/ToastStack.vue";
</script>

<template>
  <div class="layout">
    <AppSideNav />
    <main class="content">
      <RouterView />
    </main>
  </div>
  <ToastStack />
</template>

<style scoped>
.layout {
  display: grid;
  grid-template-columns: 220px minmax(0, 1fr);
  min-height: 100dvh;
}

.content {
  width: 100%;
  max-width: 1200px;
  margin: 0 auto;
  padding: 16px 40px 64px;
}

@media (width < 900px) {
  .layout {
    grid-template-columns: 64px minmax(0, 1fr);
  }

  .content {
    padding: 8px 20px 48px;
  }
}
</style>
