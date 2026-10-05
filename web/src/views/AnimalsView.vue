<script setup lang="ts">
import { computed, reactive, ref } from "vue";
import { graphql } from "../api/generated";
import type { AnimalsQuery, Sex } from "../api/generated/graphql";
import MeterBar from "../components/MeterBar.vue";
import PageHeader from "../components/PageHeader.vue";
import QueryState from "../components/QueryState.vue";
import { useMutation } from "../composables/useMutation";
import { useQuery } from "../composables/useQuery";
import { emojiOf } from "../lib/emoji";

type Animal = AnimalsQuery["animals"][number];
type Filter = "alive" | "unhoused" | "ailing" | "dead";

const AnimalsQuery = graphql(`
  query Animals {
    animals {
      id
      name
      alive
      health
      maxHealth
      ailing
      hungry
      fedToday
      species {
        nameJa
      }
      enclosure {
        id
        name
      }
    }
    enclosures {
      id
      name
      celsius
      capacity
      occupants {
        id
      }
      occupancy {
        full
      }
    }
    species {
      code
      nameJa
      conservationLabel
      taxonClass {
        label
      }
    }
  }
`);

const HouseAnimalMutation = graphql(`
  mutation HouseAnimal($enclosureId: ID!, $animalId: ID!) {
    houseAnimal(enclosureId: $enclosureId, animalId: $animalId) {
      name
    }
  }
`);

const AcquireAnimalMutation = graphql(`
  mutation AcquireAnimal($speciesCode: String!, $name: String!, $sex: Sex!) {
    acquireAnimal(speciesCode: $speciesCode, name: $name, sex: $sex) {
      name
      species {
        nameJa
      }
    }
  }
`);

const query = useQuery(AnimalsQuery);
const { busy, mutate } = useMutation();

const animals = computed(() => query.data.value?.animals ?? []);
const vacancies = computed(() =>
  (query.data.value?.enclosures ?? []).filter((e) => !e.occupancy.full),
);

const matchers: Record<Filter, (animal: Animal) => boolean> = {
  alive: (a) => a.alive,
  unhoused: (a) => a.alive && !a.enclosure,
  ailing: (a) => a.alive && (a.ailing || a.hungry),
  dead: (a) => !a.alive,
};
const filters: { key: Filter; label: string }[] = [
  { key: "alive", label: "飼育中" },
  { key: "unhoused", label: "未収容" },
  { key: "ailing", label: "要注意" },
  { key: "dead", label: "亡くなった" },
];
const filter = ref<Filter>("alive");
const keyword = ref("");

function countOf(key: Filter) {
  return animals.value.filter(matchers[key]).length;
}

const visible = computed(() =>
  animals.value
    .filter(matchers[filter.value])
    .filter((a) => !keyword.value || `${a.name}${a.species.nameJa}`.includes(keyword.value)),
);

const destinations = reactive<Record<string, string>>({});

async function house(animal: Animal) {
  const enclosureId = destinations[animal.id];
  if (!enclosureId) return;
  const housed = await mutate(
    HouseAnimalMutation,
    { enclosureId, animalId: animal.id },
    ({ houseAnimal }) => `${animal.name}を${houseAnimal.name}に収容しました`,
  );
  if (housed) delete destinations[animal.id];
}

const acquiring = ref(false);
const draft = reactive({ speciesCode: "", name: "", sex: "FEMALE" as Sex });

async function acquire() {
  const acquired = await mutate(
    AcquireAnimalMutation,
    { ...draft },
    ({ acquireAnimal }) =>
      `${acquireAnimal.species.nameJa}の「${acquireAnimal.name}」を導入しました`,
  );
  if (!acquired) return;
  draft.name = "";
  acquiring.value = false;
  filter.value = "unhoused";
}
</script>

<template>
  <PageHeader title="動物" :subtitle="`飼育中 ${countOf('alive')} 頭`">
    <button class="btn btn-accent" @click="acquiring = !acquiring">
      {{ acquiring ? "閉じる" : "＋ 導入" }}
    </button>
  </PageHeader>

  <Transition name="slide">
    <form v-if="acquiring" class="card acquire" @submit.prevent="acquire">
      <label class="field">
        種
        <select v-model="draft.speciesCode" required>
          <option value="" disabled>選んでください</option>
          <option v-for="s in query.data.value?.species" :key="s.code" :value="s.code">
            {{ emojiOf(s.nameJa, s.taxonClass.label) }} {{ s.nameJa }}（{{ s.conservationLabel }}）
          </option>
        </select>
      </label>
      <label class="field">
        名前
        <input v-model.trim="draft.name" required maxlength="20" placeholder="例: ハナコ" />
      </label>
      <div class="segmented" role="group" aria-label="性別">
        <button type="button" :aria-pressed="draft.sex === 'FEMALE'" @click="draft.sex = 'FEMALE'">
          ♀ メス
        </button>
        <button type="button" :aria-pressed="draft.sex === 'MALE'" @click="draft.sex = 'MALE'">
          ♂ オス
        </button>
      </div>
      <button class="btn btn-primary" :disabled="busy">導入する</button>
    </form>
  </Transition>

  <div class="toolbar">
    <div class="segmented filters" role="group" aria-label="絞り込み">
      <button
        v-for="f in filters"
        :key="f.key"
        type="button"
        :aria-pressed="filter === f.key"
        @click="filter = f.key"
      >
        {{ f.label }} <span class="count">{{ countOf(f.key) }}</span>
      </button>
    </div>
    <input
      v-model.trim="keyword"
      class="inline-select search"
      type="search"
      placeholder="名前・種で検索"
      aria-label="検索"
    />
  </div>

  <QueryState
    :loading="query.loading.value"
    :error="query.error.value"
    :empty="visible.length === 0"
    empty-text="該当する動物はいません"
    @retry="query.reload"
  >
    <div class="card table-card">
      <table class="data-table">
        <thead>
          <tr>
            <th>名前</th>
            <th>種</th>
            <th>エリア</th>
            <th>体力</th>
            <th>状態</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="animal in visible" :key="animal.id" :class="{ dead: !animal.alive }">
            <td>
              <RouterLink :to="`/animals/${animal.id}`" class="cell-link">
                <span>{{ animal.alive ? emojiOf(animal.species.nameJa) : "🪦" }}</span>
                {{ animal.name }}
              </RouterLink>
            </td>
            <td>{{ animal.species.nameJa }}</td>
            <td>
              <RouterLink
                v-if="animal.enclosure"
                :to="`/enclosures/${animal.enclosure.id}`"
                class="cell-link"
              >
                {{ animal.enclosure.name }}
              </RouterLink>
              <form v-else-if="animal.alive" class="row house" @submit.prevent="house(animal)">
                <select
                  v-model="destinations[animal.id]"
                  class="inline-select"
                  required
                  aria-label="収容するエリア"
                >
                  <option :value="undefined" disabled>未収容 — 収容先…</option>
                  <option v-for="e in vacancies" :key="e.id" :value="e.id">
                    {{ e.name }}（{{ e.occupants.length }}/{{ e.capacity }}・{{ e.celsius }}℃）
                  </option>
                </select>
                <button
                  class="btn btn-primary btn-small"
                  :disabled="busy || !destinations[animal.id]"
                >
                  収容
                </button>
              </form>
              <span v-else class="muted">—</span>
            </td>
            <td class="meter-cell">
              <MeterBar
                v-if="animal.alive"
                label=""
                :value="animal.health"
                :max="animal.maxHealth"
              />
            </td>
            <td>
              <div class="badges">
                <template v-if="animal.alive">
                  <span v-if="animal.ailing" class="badge badge-bad">不調</span>
                  <span v-if="animal.hungry" class="badge badge-bad">空腹</span>
                  <span v-if="!animal.fedToday" class="badge badge-warn">未給餌</span>
                  <span v-if="!animal.enclosure" class="badge badge-warn">未収容</span>
                </template>
                <span v-else class="badge">死亡</span>
              </div>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
  </QueryState>
</template>

<style scoped>
.acquire {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 12px;
  align-items: end;
  margin-bottom: 16px;
}

.filters {
  flex: 0 1 520px;
}

.count {
  margin-left: 2px;
  font-variant-numeric: tabular-nums;
  opacity: 0.7;
}

.search {
  flex: 0 1 240px;
  padding: 8px 12px;
}

.house {
  gap: 6px;
}

.house select {
  max-width: 240px;
}

tr.dead {
  color: var(--ink-soft);
}
</style>
