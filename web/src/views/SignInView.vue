<script setup lang="ts">
import { ref } from "vue";
import { useSession } from "../composables/useSession";

const { signIn } = useSession();
const developer = import.meta.env.DEV;
const busy = ref(false);
const failure = ref<string>();

async function enter() {
  busy.value = true;
  failure.value = undefined;
  try {
    await signIn();
  } catch (e) {
    failure.value = (e as Error).message;
  } finally {
    busy.value = false;
  }
}
</script>

<template>
  <main class="sign-in">
    <div class="card panel">
      <h1>🦁 OOP-Zoo</h1>
      <template v-if="developer">
        <p class="muted">開発用のユーザーで動物園に入ります。</p>
        <button class="btn btn-primary btn-block" :disabled="busy" @click="enter">
          開発用ユーザーでログイン
        </button>
      </template>
      <p v-else class="muted">ログインの方法は準備中です。</p>
      <p v-if="failure" class="failure">{{ failure }}</p>
    </div>
  </main>
</template>

<style scoped>
.sign-in {
  display: grid;
  place-items: center;
  min-height: 100dvh;
  padding: 16px;
}

.panel {
  display: grid;
  gap: 16px;
  width: min(360px, 100%);
  padding: 32px 24px;
  text-align: center;
}

.failure {
  color: var(--bad);
  font-weight: 700;
}
</style>
