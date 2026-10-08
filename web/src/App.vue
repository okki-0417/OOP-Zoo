<script setup lang="ts">
import AppSideNav from "./components/AppSideNav.vue";
import LandscapeScreen from "./components/LandscapeScreen.vue";
import ToastStack from "./components/ToastStack.vue";
import { useSession } from "./composables/useSession";
import SignInView from "./views/SignInView.vue";

const { signedOut } = useSession();
</script>

<template>
  <LandscapeScreen>
    <SignInView v-if="signedOut" />
    <div v-else class="layout">
      <AppSideNav />
      <main class="content">
        <RouterView />
      </main>
    </div>
    <ToastStack />
  </LandscapeScreen>
</template>

<style scoped>
.layout {
  display: grid;
  grid-template-columns: 64px minmax(0, 1fr);
  height: 100cqh;
}

.content {
  display: grid;
  grid-template-rows: auto minmax(0, 1fr);
  min-height: 0;
  padding: 0 0 12px 16px;
}

.content :deep(.page-header) {
  padding-right: 12px;
}
</style>
