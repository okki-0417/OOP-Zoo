<script setup lang="ts">
import { computed, ref } from "vue";
import { graphql } from "../api/generated";
import type { AnimalsQuery } from "../api/generated/graphql";
import PageHeader from "../components/PageHeader.vue";
import QueryState from "../components/QueryState.vue";
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
  }
`);

const query = useQuery(AnimalsQuery);

const animals = computed(() => query.data.value?.animals ?? []);

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
  { key: "dead", label: "死亡" },
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

function healthTone(animal: Animal) {
  const ratio = animal.health / animal.maxHealth;
  if (ratio >= 0.6) return "good";
  if (ratio >= 0.3) return "warn";
  return "bad";
}
</script>

<template>
  <PageHeader title="動物">
    <RouterLink to="/animals/new" class="btn btn-accent btn-small">＋ 導入</RouterLink>
  </PageHeader>

  <div class="split">
    <div class="pane">
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
        <ul class="scroll-box cards">
          <li v-for="animal in visible" :key="animal.id">
            <RouterLink
              :to="`/animals/${animal.id}`"
              class="animal"
              :class="{ dead: !animal.alive }"
            >
              <span class="emoji">{{ animal.alive ? emojiOf(animal.species.nameJa) : "🪦" }}</span>
              <span class="who">
                <strong>{{ animal.name }}</strong>
                <small class="muted">{{ animal.enclosure?.name ?? animal.species.nameJa }}</small>
              </span>
              <span v-if="animal.alive" class="signs">
                <span class="dot" :class="healthTone(animal)" title="体力" />
                <span v-if="animal.ailing" class="badge badge-bad">不調</span>
                <span v-else-if="animal.hungry" class="badge badge-bad">空腹</span>
                <span v-else-if="!animal.enclosure" class="badge badge-warn">未収容</span>
                <span v-else-if="!animal.fedToday" class="badge badge-warn">未給餌</span>
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
.pane {
  container-type: inline-size;
}

.toolbar {
  margin: 0;
  gap: 8px;
}

.filters {
  flex: 1;
}

.filters button {
  white-space: nowrap;
}

.count {
  margin-left: 2px;
  font-variant-numeric: tabular-nums;
  opacity: 0.7;
}

.search {
  flex: 0 1 160px;
  padding: 8px 12px;
}

@container (width < 480px) {
  .search {
    flex-basis: 100%;
  }
}

.cards {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(170px, 1fr));
  align-content: start;
  gap: 8px;
  margin: 0;
  padding: 0;
  list-style: none;
}

.animal {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 8px 10px;
  border-radius: 12px;
  border: 1px solid var(--line);
  background: var(--surface);
}

.animal:hover {
  border-color: var(--brand);
}

.animal.router-link-active {
  border-color: var(--brand);
  background: color-mix(in srgb, var(--brand) 12%, var(--surface));
}

.animal.dead {
  filter: grayscale(1);
  opacity: 0.7;
}

.emoji {
  font-size: 1.5rem;
}

.who {
  flex: 1;
  min-width: 0;
  display: grid;
  line-height: 1.25;
}

.who > * {
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.signs {
  display: grid;
  justify-items: end;
  gap: 4px;
}

.dot {
  width: 8px;
  height: 8px;
  border-radius: 999px;
}

.dot.good {
  background: var(--good);
}

.dot.warn {
  background: var(--warn);
}

.dot.bad {
  background: var(--bad);
}
</style>
