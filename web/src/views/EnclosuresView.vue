<script setup lang="ts">
import { computed } from "vue";
import { graphql } from "../api/generated";
import PageHeader from "../components/PageHeader.vue";
import QueryState from "../components/QueryState.vue";
import { useQuery } from "../composables/useQuery";

const EnclosuresQuery = graphql(`
  query Enclosures {
    enclosures {
      id
      name
      celsius
      climateControlled
      capacity
      cleanliness
      enrichment
      filthy
      barren
      occupants {
        id
      }
      occupancy {
        full
      }
      keepers {
        id
        name
      }
    }
  }
`);

const query = useQuery(EnclosuresQuery);
const enclosures = computed(() => query.data.value?.enclosures ?? []);

const residents = computed(() => enclosures.value.reduce((sum, e) => sum + e.occupants.length, 0));
const seats = computed(() => enclosures.value.reduce((sum, e) => sum + e.capacity, 0));

function careTone(value: number) {
  if (value >= 60) return "";
  if (value >= 30) return "warn";
  return "bad";
}
</script>

<template>
  <PageHeader
    title="エリア"
    :subtitle="`${enclosures.length} 区画・収容 ${residents} / ${seats} 頭`"
  >
    <RouterLink to="/enclosures/new" class="btn btn-accent btn-small">＋ 建設</RouterLink>
  </PageHeader>

  <div class="split">
    <div>
      <QueryState
        :loading="query.loading.value"
        :error="query.error.value"
        :empty="enclosures.length === 0"
        empty-text="エリアがありません。まずは建設しましょう"
        @retry="query.reload"
      >
        <ul class="scroll-box tiles">
          <li v-for="enclosure in enclosures" :key="enclosure.id">
            <RouterLink :to="`/enclosures/${enclosure.id}`" class="tile">
              <span class="tile-icon">🌳</span>
              <span class="tile-text">
                <strong>{{ enclosure.name }}</strong>
                <small class="muted">
                  {{ enclosure.celsius }}℃{{ enclosure.climateControlled ? "・空調" : "" }}・{{
                    enclosure.occupants.length
                  }}/{{ enclosure.capacity }}頭
                </small>
              </span>
              <span class="tile-signs">
                <span class="dots">
                  <span class="dot" :class="careTone(enclosure.cleanliness)" title="清潔度" />
                  <span class="dot" :class="careTone(enclosure.enrichment)" title="刺激" />
                </span>
                <span v-if="enclosure.filthy" class="badge badge-bad">不潔</span>
                <span
                  v-else-if="enclosure.occupants.length && !enclosure.keepers.length"
                  class="badge badge-warn"
                  >担当なし</span
                >
                <span v-else-if="enclosure.barren" class="badge badge-warn">退屈</span>
                <span v-else-if="enclosure.occupancy.full" class="badge">満員</span>
                <span v-else-if="enclosure.occupants.length === 0" class="badge">空き</span>
              </span>
            </RouterLink>
          </li>
        </ul>
      </QueryState>
    </div>

    <RouterView />
  </div>
</template>

<style scoped>
.dots {
  display: flex;
  gap: 4px;
}
</style>
