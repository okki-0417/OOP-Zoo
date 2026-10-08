<script setup lang="ts">
import SideSheet from "../components/SideSheet.vue";
import { useRounds } from "../composables/useRounds";

const { reports } = useRounds();
</script>

<template>
  <SideSheet title="見回りの結果" close-to="/staff">
    <p v-if="reports.length === 0" class="muted">まだ見回っていません</p>
    <details v-for="rounds in reports" :key="rounds.keeper.id" class="fold" open>
      <summary>
        <span class="grow">🧑‍🌾 {{ rounds.keeper.name }}</span>
        <small class="muted">残り {{ rounds.keeper.remainingMinutes }} 分</small>
      </summary>
      <ul class="reports">
        <li v-for="round in rounds.reports" :key="round.enclosure.id">
          <strong>{{ round.enclosure.name }}</strong
          >:
          {{ round.fed.length ? `${round.fed.map((a) => a.name).join("・")}に給餌` : "給餌なし" }}
          <span v-if="round.cleaned">・清掃</span>
          <span v-if="round.enriched">・遊具を補充</span>
          <span v-for="skip in round.skipped" :key="skip.subject + skip.reason" class="skip">
            ⚠️ {{ skip.subject }}: {{ skip.reason }}
          </span>
        </li>
      </ul>
    </details>
  </SideSheet>
</template>

<style scoped>
.reports {
  display: grid;
  gap: 4px;
  padding: 0;
  list-style: none;
  font-size: 0.85rem;
}

.skip {
  display: block;
  color: var(--warn);
}
</style>
