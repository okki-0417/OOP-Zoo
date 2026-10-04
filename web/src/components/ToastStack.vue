<script setup lang="ts">
import { useToast } from "../composables/useToast";

const { toasts, dismiss } = useToast();
</script>

<template>
  <TransitionGroup tag="div" name="toast" class="toasts">
    <button
      v-for="toast in toasts"
      :key="toast.id"
      class="toast"
      :class="toast.tone"
      @click="dismiss(toast.id)"
    >
      {{ toast.message }}
    </button>
  </TransitionGroup>
</template>

<style scoped>
.toasts {
  position: fixed;
  z-index: 20;
  inset: 12px 12px auto;
  display: grid;
  gap: 8px;
  max-width: 456px;
  margin: 0 auto;
  pointer-events: none;
}

.toast {
  pointer-events: auto;
  text-align: left;
  border: none;
  border-radius: 12px;
  padding: 12px 14px;
  font-weight: 700;
  font-size: 0.9rem;
  background: var(--ink);
  color: var(--bg);
  box-shadow: 0 8px 24px rgb(0 0 0 / 20%);
}

.toast.good {
  background: var(--good);
  color: #fff;
}

.toast.bad {
  background: var(--bad);
  color: #fff;
}

.toast-enter-from,
.toast-leave-to {
  opacity: 0;
  transform: translateY(-12px);
}

.toast-enter-active,
.toast-leave-active {
  transition: all 0.25s ease;
}
</style>
