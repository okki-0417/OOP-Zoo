<script setup lang="ts">
import { computed, ref } from "vue";
import type { Alert } from "../api/client";

const props = defineProps<{ alerts: Alert[] }>();

type Filter = "all" | Alert["severity"];

const filter = ref<Filter>("all");
const severities: { key: Alert["severity"]; label: string }[] = [
  { key: "critical", label: "緊急" },
  { key: "warning", label: "警告" },
  { key: "notice", label: "注意" },
];

const counts = computed(() =>
  Object.fromEntries(
    severities.map(({ key }) => [key, props.alerts.filter((a) => a.severity === key).length]),
  ),
);
const visible = computed(() =>
  filter.value === "all" ? props.alerts : props.alerts.filter((a) => a.severity === filter.value),
);

const kindIcons: Record<Alert["kind"], string> = {
  insolvent: "💸",
  no_keeper: "🧑‍🌾",
  no_veterinarian: "🧑‍⚕️",
  filthy: "🧹",
  overcrowded: "📦",
  barren: "🪵",
  grave: "🚨",
  guarded: "⚠️",
  starving: "🍖",
  hungry: "🍽️",
  sick: "🦠",
  malnourished: "🥗",
  stressed: "😣",
  climate: "🌡️",
  due: "🍼",
  unhoused: "🏚️",
};

function linkOf(alert: Alert) {
  if (alert.subject.type === "animal") return `/animals/${alert.subject.id}`;
  if (alert.subject.type === "enclosure") return `/enclosures/${alert.subject.id}`;
  if (alert.kind === "no_keeper" || alert.kind === "no_veterinarian") return "/staff";
  return undefined;
}
</script>

<template>
  <section class="card inbox">
    <div class="segmented" role="group" aria-label="重大度">
      <button type="button" :aria-pressed="filter === 'all'" @click="filter = 'all'">
        すべて {{ alerts.length }}
      </button>
      <button
        v-for="s in severities"
        :key="s.key"
        type="button"
        :aria-pressed="filter === s.key"
        @click="filter = s.key"
      >
        {{ s.label }} {{ counts[s.key] }}
      </button>
    </div>

    <p v-if="visible.length === 0" class="empty">対応が必要なことはありません 🎉</p>
    <ul v-else class="items">
      <li v-for="(alert, index) in visible" :key="index">
        <component
          :is="linkOf(alert) ? 'RouterLink' : 'div'"
          :to="linkOf(alert)"
          class="item"
          :class="alert.severity"
        >
          <span class="icon">{{ kindIcons[alert.kind] }}</span>
          <span class="grow">
            <strong>{{ alert.subject.name }}</strong>
            <span class="message">{{ alert.message }}</span>
          </span>
          <span v-if="linkOf(alert)" class="go">対処 ›</span>
        </component>
      </li>
    </ul>
  </section>
</template>

<style scoped>
.inbox {
  display: grid;
  gap: 12px;
}

.items {
  list-style: none;
  margin: 0;
  padding: 0;
  display: grid;
  gap: 6px;
  max-height: 560px;
  overflow-y: auto;
}

.item {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 10px 12px;
  border-radius: 12px;
  border-left: 4px solid var(--line);
  background: var(--surface-sunk);
}

a.item:hover {
  filter: brightness(0.97);
}

.item.critical {
  border-left-color: var(--bad);
  background: color-mix(in srgb, var(--bad) 10%, var(--surface));
}

.item.warning {
  border-left-color: var(--warn);
}

.icon {
  font-size: 1.3rem;
}

.message {
  display: block;
  font-size: 0.85rem;
  color: var(--ink-soft);
}

.go {
  font-size: 0.8rem;
  font-weight: 700;
  color: var(--brand);
  white-space: nowrap;
}
</style>
