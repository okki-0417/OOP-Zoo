<script setup lang="ts">
import { computed } from "vue";
import { graphql } from "../api/generated";
import { useQuery } from "../composables/useQuery";
import { yen } from "../lib/currency";

const ZooStatusQuery = graphql(`
  query ZooStatus {
    zoo {
      day
      balance
      reputation
    }
  }
`);

const query = useQuery(ZooStatusQuery);
const zoo = computed(() => query.data.value?.zoo);
</script>

<template>
  <div v-if="zoo" class="status">
    <span class="day">{{ zoo.day + 1 }}日目</span>
    <RouterLink to="/finance" class="pill" :class="{ negative: zoo.balance < 0 }">
      💰 {{ yen(zoo.balance) }}
    </RouterLink>
    <RouterLink to="/reputation" class="pill">⭐ {{ zoo.reputation }}</RouterLink>
  </div>
</template>

<style scoped>
.status {
  display: flex;
  align-items: center;
  gap: 6px;
  font-size: 0.8rem;
  font-weight: 800;
  font-variant-numeric: tabular-nums;
  white-space: nowrap;
}

.day {
  color: var(--ink-soft);
  padding-inline: 4px;
}

.pill {
  padding: 4px 10px;
  border-radius: 999px;
  background: var(--surface-sunk);
}

.negative {
  color: var(--bad);
}
</style>
