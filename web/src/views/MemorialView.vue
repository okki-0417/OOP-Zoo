<script setup lang="ts">
import { computed } from "vue";
import { graphql } from "../api/generated";
import QueryState from "../components/QueryState.vue";
import SideSheet from "../components/SideSheet.vue";
import { useQuery } from "../composables/useQuery";

const MemorialQuery = graphql(`
  query Memorial {
    animals {
      id
      name
      alive
      causeOfDeath
      species {
        nameJa
      }
    }
  }
`);

const query = useQuery(MemorialQuery);
const deceased = computed(() => (query.data.value?.animals ?? []).filter((a) => !a.alive));
</script>

<template>
  <SideSheet title="慰霊碑" close-to="/">
    <QueryState
      :loading="query.loading.value"
      :error="query.error.value"
      :empty="deceased.length === 0"
      empty-text="亡くなった動物はいません"
      @retry="query.reload"
    >
      <ul class="list">
        <li v-for="dead in deceased" :key="dead.id" class="row">
          <span>🪦</span>
          <RouterLink :to="`/animals/${dead.id}`" class="grow">
            {{ dead.name }}<span class="muted">（{{ dead.species.nameJa }}）</span>
          </RouterLink>
          <span class="muted">{{ dead.causeOfDeath }}</span>
        </li>
      </ul>
    </QueryState>
  </SideSheet>
</template>

<style scoped>
.list {
  padding: 0;
}
</style>
