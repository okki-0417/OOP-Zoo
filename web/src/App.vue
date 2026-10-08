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
  grid-template-columns: 220px minmax(0, 1fr);
  min-height: 100cqh;
}

.content {
  width: 100%;
  max-width: 1200px;
  margin: 0 auto;
  padding: 16px 40px 64px;
}

@container screen (width < 900px) {
  .layout {
    grid-template-columns: 64px minmax(0, 1fr);
  }

  .content {
    padding: 8px 20px 48px;
  }
}
</style>
