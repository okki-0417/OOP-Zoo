<script setup lang="ts">
import { computed, ref } from "vue";
import type { AlertsQuery } from "../api/generated/graphql";

type Alert = AlertsQuery["alerts"][number];

const props = defineProps<{ alerts: Alert[] }>();

type Filter = "all" | Alert["severity"];

const filter = ref<Filter>("all");
const severities: { key: Alert["severity"]; label: string }[] = [
  { key: "CRITICAL", label: "緊急" },
  { key: "WARNING", label: "警告" },
  { key: "NOTICE", label: "注意" },
];

type Case = {
  key: string;
  severity: Alert["severity"];
  subjectName: string;
  alerts: Alert[];
};

const cases = computed(() => {
  const grouped = new Map<string, Case>();
  for (const alert of props.alerts) {
    const key = `${alert.subjectType}:${alert.subjectId ?? alert.kind}`;
    const found = grouped.get(key);
    if (found) found.alerts.push(alert);
    else
      grouped.set(key, {
        key,
        severity: alert.severity,
        subjectName: alert.subjectName,
        alerts: [alert],
      });
  }
  return [...grouped.values()];
});
const counts = computed(() =>
  Object.fromEntries(
    severities.map(({ key }) => [key, cases.value.filter((c) => c.severity === key).length]),
  ),
);
const visible = computed(() =>
  filter.value === "all" ? cases.value : cases.value.filter((c) => c.severity === filter.value),
);

const kindIcons: Record<Alert["kind"], string> = {
  INSOLVENT: "💸",
  NO_KEEPER: "🧑‍🌾",
  NO_VETERINARIAN: "🧑‍⚕️",
  UNASSIGNED: "📋",
  FILTHY: "🧹",
  OVERCROWDED: "📦",
  BARREN: "🪵",
  GRAVE: "🚨",
  GUARDED: "⚠️",
  STARVING: "🍖",
  HUNGRY: "🍽️",
  SICK: "🦠",
  MALNOURISHED: "🥗",
  STRESSED: "😣",
  CLIMATE: "🌡️",
  DUE: "🍼",
  UNHOUSED: "🏚️",
};

function linkOf(alert: Alert) {
  if (alert.subjectType === "ANIMAL") return `/animals/${alert.subjectId}`;
  if (alert.subjectType === "ENCLOSURE") return `/enclosures/${alert.subjectId}`;
  if (alert.kind === "NO_KEEPER" || alert.kind === "NO_VETERINARIAN") return "/staff";
  return undefined;
}
</script>

<template>
  <section class="card inbox">
    <div class="segmented" role="group" aria-label="重大度">
      <button type="button" :aria-pressed="filter === 'all'" @click="filter = 'all'">
        すべて {{ cases.length }}
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
      <li v-for="c in visible" :key="c.key">
        <component
          :is="linkOf(c.alerts[0]!) ? 'RouterLink' : 'div'"
          :to="linkOf(c.alerts[0]!)"
          class="item"
          :class="c.severity"
        >
          <span class="icon">{{ kindIcons[c.alerts[0]!.kind] }}</span>
          <span class="grow">
            <strong>{{ c.subjectName }}</strong>
            <span v-for="alert in c.alerts" :key="alert.kind" class="message">
              {{ c.alerts.length > 1 ? kindIcons[alert.kind] : "" }} {{ alert.message }}
            </span>
          </span>
          <span v-if="linkOf(c.alerts[0]!)" class="go">対処 ›</span>
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
