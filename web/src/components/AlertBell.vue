<script setup lang="ts">
import { computed, onBeforeUnmount, ref, watch } from "vue";
import { useRoute } from "vue-router";
import { useAlerts } from "../composables/useAlerts";
import AlertInbox from "./AlertInbox.vue";

const { alerts, error, critical, reload } = useAlerts();
const open = ref(false);
const root = ref<HTMLElement>();
const route = useRoute();

const subjectCount = computed(
  () => new Set(alerts.value.map((a) => `${a.subjectType}:${a.subjectId ?? a.kind}`)).size,
);
const tone = computed(() => {
  if (critical.value.length > 0) return "critical";
  if (alerts.value.some((alert) => alert.severity === "WARNING")) return "warning";
  return "notice";
});

function toggle() {
  open.value = !open.value;
  if (open.value) void reload();
}

function closeOnOutside(event: MouseEvent) {
  if (!root.value?.contains(event.target as Node)) open.value = false;
}

function closeOnEscape(event: KeyboardEvent) {
  if (event.key === "Escape") open.value = false;
}

watch(open, (isOpen) => {
  if (isOpen) {
    document.addEventListener("mousedown", closeOnOutside);
    document.addEventListener("keydown", closeOnEscape);
  } else {
    document.removeEventListener("mousedown", closeOnOutside);
    document.removeEventListener("keydown", closeOnEscape);
  }
});
watch(
  () => route.fullPath,
  () => (open.value = false),
);
onBeforeUnmount(() => (open.value = false));
</script>

<template>
  <div ref="root" class="bell-root">
    <button
      type="button"
      class="bell"
      :aria-expanded="open"
      :aria-label="`要対応 ${subjectCount} 件`"
      @click="toggle"
    >
      🔔
      <span v-if="subjectCount" class="count" :class="tone">{{ subjectCount }}</span>
    </button>
    <Transition name="drop">
      <div v-if="open" class="panel">
        <h2 class="section-title">要対応</h2>
        <p v-if="error" class="muted">読み込めませんでした: {{ error.message }}</p>
        <AlertInbox v-else :alerts="[...alerts]" />
      </div>
    </Transition>
  </div>
</template>

<style scoped>
.bell-root {
  position: relative;
}

.bell {
  position: relative;
  display: grid;
  place-items: center;
  width: 40px;
  height: 40px;
  border-radius: 12px;
  border: 1px solid var(--line);
  background: var(--surface);
  font-size: 1.2rem;
  cursor: pointer;
}

.bell:hover,
.bell[aria-expanded="true"] {
  background: var(--surface-sunk);
}

.count {
  position: absolute;
  top: -6px;
  right: -6px;
  min-width: 20px;
  height: 20px;
  padding: 0 5px;
  border-radius: 10px;
  font-size: 0.72rem;
  font-weight: 800;
  line-height: 20px;
  color: #fff;
  background: var(--ink-soft);
}

.count.critical {
  background: var(--bad);
}

.count.warning {
  background: var(--warn);
}

.panel {
  position: absolute;
  z-index: 15;
  top: calc(100% + 8px);
  right: 0;
  width: min(520px, calc(100vw - 32px));
  padding: 16px;
  border-radius: 16px;
  border: 1px solid var(--line);
  background: var(--surface);
  box-shadow: 0 12px 32px rgb(0 0 0 / 18%);
}

.panel .section-title {
  margin-top: 0;
}

.panel :deep(.inbox) {
  box-shadow: none;
  padding: 0;
  border: none;
}

.drop-enter-from,
.drop-leave-to {
  opacity: 0;
  transform: translateY(-4px);
}

.drop-enter-active,
.drop-leave-active {
  transition: all 0.15s ease;
}
</style>
