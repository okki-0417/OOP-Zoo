<script setup lang="ts">
import { computed } from "vue";
import { graphql } from "../api/generated";
import PageHeader from "../components/PageHeader.vue";
import QueryState from "../components/QueryState.vue";
import { useQuery } from "../composables/useQuery";
import { yen } from "../lib/currency";
import { emojiOf } from "../lib/emoji";

const ReputationQuery = graphql(`
  query Reputation {
    zoo {
      reputation
      admissionFee
      exhibitCondition
      experience
      expectedVisitors
      expectedReputationChange
    }
    animals {
      id
      name
      alive
      visibleCondition
      stressed
      sick
      weak
      species {
        nameJa
      }
      enclosure {
        id
        name
      }
    }
    operatings {
      deaths
      outbreak
    }
  }
`);

const query = useQuery(ReputationQuery);

const zoo = computed(() => query.data.value?.zoo);
const change = computed(() => {
  const value = zoo.value?.expectedReputationChange ?? 0;
  return `${value < 0 ? "−" : "+"}${Math.abs(value).toFixed(1)}`;
});
const feeEffect = computed(() =>
  zoo.value ? zoo.value.exhibitCondition - zoo.value.experience : 0,
);
const pull = computed(() => {
  if (!zoo.value) return "";
  if (zoo.value.experience > zoo.value.reputation) return "評判より高いので、評判を引き上げる";
  if (zoo.value.experience < zoo.value.reputation) return "評判より低いので、評判を引き下げる";
  return "評判と釣り合っている";
});

const exhibited = computed(() =>
  (query.data.value?.animals ?? [])
    .filter((animal) => animal.alive && animal.enclosure)
    .map((animal) => ({
      ...animal,
      causes: [animal.stressed && "ストレス", animal.sick && "病気", animal.weak && "衰弱"].filter(
        (cause): cause is string => Boolean(cause),
      ),
    }))
    .sort((a, b) => a.visibleCondition - b.visibleCondition),
);

const lastDay = computed(() => query.data.value?.operatings.at(-1));

function tone(value: number) {
  if (value >= 60) return "good";
  if (value >= 30) return "warn";
  return "bad";
}
</script>

<template>
  <PageHeader title="評判" :crumbs="[{ label: '園長室', to: '/' }]" />

  <QueryState
    :loading="query.loading.value"
    :error="query.error.value"
    :empty="!zoo"
    @retry="query.reload"
  >
    <section v-if="zoo" class="card tree">
      <details open>
        <summary class="node root">
          <span class="label">評判</span>
          <span class="value" :class="tone(zoo.reputation)">{{ zoo.reputation }}</span>
          <span class="hint" :class="zoo.expectedReputationChange < 0 ? 'minus' : 'plus'">
            明日 {{ change }}
          </span>
        </summary>
        <ul>
          <li>
            <details open>
              <summary class="node">
                <span class="label">来園者の体験</span>
                <span class="value" :class="tone(zoo.experience)">{{ zoo.experience }}</span>
                <span class="hint">{{ pull }}</span>
              </summary>
              <ul>
                <li>
                  <details>
                    <summary class="node">
                      <span class="label">展示動物の見た目（平均）</span>
                      <span class="value" :class="tone(zoo.exhibitCondition)">
                        {{ zoo.exhibitCondition }}
                      </span>
                      <span class="hint">{{ exhibited.length }} 頭</span>
                    </summary>
                    <ul>
                      <li v-if="exhibited.length === 0" class="leaf">
                        <span class="hint">展示中の動物がいません</span>
                      </li>
                      <li v-for="animal in exhibited" :key="animal.id">
                        <details v-if="animal.causes.length > 0">
                          <summary class="node">
                            <RouterLink :to="`/animals/${animal.id}`" class="label link">
                              {{ emojiOf(animal.species.nameJa) }} {{ animal.name }}
                            </RouterLink>
                            <span class="value" :class="tone(animal.visibleCondition)">
                              {{ animal.visibleCondition }}
                            </span>
                            <span class="hint">{{ animal.enclosure?.name }}</span>
                          </summary>
                          <ul>
                            <li v-for="cause in animal.causes" :key="cause" class="leaf">
                              <span class="label minus">{{ cause }}</span>
                            </li>
                          </ul>
                        </details>
                        <div v-else class="leaf">
                          <RouterLink :to="`/animals/${animal.id}`" class="label link">
                            {{ emojiOf(animal.species.nameJa) }} {{ animal.name }}
                          </RouterLink>
                          <span class="value good">{{ animal.visibleCondition }}</span>
                          <span class="hint">{{ animal.enclosure?.name }}</span>
                        </div>
                      </li>
                    </ul>
                  </details>
                </li>
                <li class="leaf">
                  <span class="label">入園料 {{ yen(zoo.admissionFee) }}</span>
                  <span class="value" :class="{ minus: feeEffect > 0 }">−{{ feeEffect }}</span>
                  <RouterLink to="/" class="hint link">高いほど体験が下がる</RouterLink>
                </li>
              </ul>
            </details>
          </li>
          <li class="leaf">
            <span class="label">来園の見込み</span>
            <span class="value">{{ zoo.expectedVisitors.toLocaleString() }} 人</span>
            <span class="hint">多いほど、評判が体験へ速く近づく</span>
          </li>
          <li class="leaf">
            <span class="label">自然減衰</span>
            <span class="hint">中立を超えた分は、毎日少しずつ減る</span>
          </li>
          <li>
            <details>
              <summary class="node">
                <span class="label">前日の出来事</span>
                <span
                  class="value"
                  :class="{ minus: lastDay && (lastDay.deaths > 0 || lastDay.outbreak) }"
                >
                  {{ lastDay && (lastDay.deaths > 0 || lastDay.outbreak) ? "あり" : "なし" }}
                </span>
                <span class="hint">死亡や発病があると、その日に大きく下がる</span>
              </summary>
              <ul>
                <li class="leaf">
                  <span class="label">死亡</span>
                  <span class="value" :class="{ minus: (lastDay?.deaths ?? 0) > 0 }">
                    {{ lastDay?.deaths ?? 0 }} 頭
                  </span>
                </li>
                <li class="leaf">
                  <span class="label">発病</span>
                  <span class="value" :class="{ minus: lastDay?.outbreak }">
                    {{ lastDay?.outbreak ?? "なし" }}
                  </span>
                </li>
              </ul>
            </details>
          </li>
        </ul>
      </details>
    </section>
  </QueryState>
</template>

<style scoped>
.tree {
  --branch: color-mix(in srgb, var(--ink-soft) 45%, transparent);
  padding: 20px 24px;
  font-variant-numeric: tabular-nums;
}

.tree ul {
  list-style: none;
  margin: 0;
  padding-left: 22px;
}

.tree li {
  position: relative;
  padding-left: 22px;
}

.tree li::before {
  content: "";
  position: absolute;
  top: 0;
  left: 0;
  width: 16px;
  height: 20px;
  border-left: 1px solid var(--branch);
  border-bottom: 1px solid var(--branch);
}

.tree li:not(:last-child)::after {
  content: "";
  position: absolute;
  top: 20px;
  bottom: 0;
  left: 0;
  border-left: 1px solid var(--branch);
}

.node,
.leaf {
  display: flex;
  align-items: baseline;
  gap: 12px;
  min-height: 40px;
  padding: 8px 0;
}

.node {
  cursor: pointer;
  list-style: none;
}

.node::-webkit-details-marker {
  display: none;
}

.tree .leaf {
  padding-left: 26px;
}

.tree li.leaf {
  padding-left: 48px;
}

.node::before {
  content: "▸";
  flex: 0 0 14px;
  text-align: center;
  color: var(--ink-soft);
  transition: transform 0.15s ease;
}

details[open] > .node::before {
  transform: rotate(90deg);
}

.root {
  font-size: 1.2rem;
}

.label {
  font-weight: 700;
}

.value {
  font-weight: 800;
}

.root .value {
  font-size: 1.6rem;
}

.hint {
  font-size: 0.85rem;
  color: var(--ink-soft);
}

.link:hover {
  color: var(--brand);
  text-decoration: underline;
}

.good {
  color: var(--good);
}

.warn {
  color: var(--warn);
}

.bad,
.minus {
  color: var(--bad);
}

.plus {
  color: var(--good);
}
</style>
