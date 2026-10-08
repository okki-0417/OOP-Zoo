<script setup lang="ts">
import { computed } from "vue";
import { graphql } from "../api/generated";
import QueryState from "../components/QueryState.vue";
import SideSheet from "../components/SideSheet.vue";
import { useQuery } from "../composables/useQuery";
import { emojiOf } from "../lib/emoji";

const ThreatenedQuery = graphql(`
  query Threatened {
    enclosures {
      occupants {
        alive
        species {
          nameJa
          threatened
          conservationCode
          conservationLabel
        }
      }
    }
  }
`);

const query = useQuery(ThreatenedQuery);

const threatened = computed(() => {
  const counts = new Map<string, { nameJa: string; code: string; label: string; count: number }>();
  const residents = (query.data.value?.enclosures ?? [])
    .flatMap((enclosure) => enclosure.occupants)
    .filter((a) => a.alive && a.species.threatened);
  for (const { species } of residents) {
    const found = counts.get(species.nameJa);
    if (found) found.count += 1;
    else
      counts.set(species.nameJa, {
        nameJa: species.nameJa,
        code: species.conservationCode,
        label: species.conservationLabel,
        count: 1,
      });
  }
  return [...counts.values()];
});
</script>

<template>
  <SideSheet title="展示中の絶滅危惧種" close-to="/">
    <QueryState
      :loading="query.loading.value"
      :error="query.error.value"
      :empty="threatened.length === 0"
      empty-text="絶滅危惧種はまだいません"
      @retry="query.reload"
    >
      <ul class="list">
        <li v-for="species in threatened" :key="species.nameJa" class="row">
          <span class="badge badge-warn">{{ species.code }}</span>
          <span class="grow">{{ emojiOf(species.nameJa) }} {{ species.nameJa }}</span>
          <span class="muted">{{ species.label }}・{{ species.count }}頭</span>
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
