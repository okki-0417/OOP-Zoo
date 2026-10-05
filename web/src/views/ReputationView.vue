<script setup lang="ts">
import { computed } from "vue";
import { graphql } from "../api/generated";
import type { BlemishCause } from "../api/generated/graphql";
import GaugeBar from "../components/GaugeBar.vue";
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
      reputationDrift
      reputationDecay
      reputationSwingLimit
      visitorsForFullSwing
    }
    animals {
      id
      name
      alive
      visibleCondition
      blemishes {
        cause
        penalty
      }
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

const causeLabels: Record<BlemishCause, string> = {
  STRESSED: "ストレス",
  SICK: "病気",
  WEAK: "衰弱",
};

const query = useQuery(ReputationQuery);

const zoo = computed(() => query.data.value?.zoo);
const feeEffect = computed(() =>
  zoo.value ? zoo.value.experience - zoo.value.exhibitCondition : 0,
);
const pull = computed(() => {
  if (!zoo.value) return "";
  if (zoo.value.experience > zoo.value.reputation) return "体験が評判より高いので、引き上げる";
  if (zoo.value.experience < zoo.value.reputation) return "体験が評判より低いので、引き下げる";
  return "体験と評判が釣り合っている";
});
const swingRate = computed(() =>
  zoo.value
    ? Math.min(100, Math.round((zoo.value.expectedVisitors / zoo.value.visitorsForFullSwing) * 100))
    : 0,
);

const exhibited = computed(() =>
  (query.data.value?.animals ?? [])
    .filter((animal) => animal.alive && animal.enclosure)
    .sort((a, b) => a.visibleCondition - b.visibleCondition),
);

const lastDay = computed(() => query.data.value?.operatings.at(-1));

function signed(value: number, digits = 0) {
  return `${value < 0 ? "−" : "+"}${Math.abs(value).toFixed(digits)}`;
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
          <GaugeBar class="gauge" :value="zoo.reputation" :max="100" />
          <span class="value">{{ zoo.reputation }}</span>
          <span class="hint">明日 {{ signed(zoo.reputationDrift + zoo.reputationDecay, 1) }}</span>
        </summary>
        <ul>
          <li>
            <details open>
              <summary class="node">
                <span class="label">体験による寄り</span>
                <GaugeBar
                  class="gauge"
                  :value="zoo.reputationDrift"
                  :min="-zoo.reputationSwingLimit"
                  :max="zoo.reputationSwingLimit"
                />
                <span class="value">{{ signed(zoo.reputationDrift, 1) }}</span>
                <span class="hint">{{ pull }}</span>
              </summary>
              <ul>
                <li>
                  <details open>
                    <summary class="node">
                      <span class="label">来園者の体験</span>
                      <GaugeBar
                        class="gauge"
                        :value="zoo.experience"
                        :max="100"
                        :marker="zoo.reputation"
                      />
                      <span class="value">{{ zoo.experience }}</span>
                      <span class="hint">印はいまの評判</span>
                    </summary>
                    <ul>
                      <li>
                        <details open>
                          <summary class="node">
                            <span class="label">展示動物の見た目</span>
                            <GaugeBar class="gauge" :value="zoo.exhibitCondition" :max="100" />
                            <span class="value">{{ zoo.exhibitCondition }}</span>
                            <span class="hint">{{ exhibited.length }} 頭の平均</span>
                          </summary>
                          <ul>
                            <li v-for="animal in exhibited" :key="animal.id">
                              <details v-if="animal.blemishes.length > 0" open>
                                <summary class="node">
                                  <RouterLink :to="`/animals/${animal.id}`" class="label link">
                                    {{ emojiOf(animal.species.nameJa) }} {{ animal.name }}
                                  </RouterLink>
                                  <GaugeBar
                                    class="gauge"
                                    :value="animal.visibleCondition"
                                    :max="100"
                                  />
                                  <span class="value">{{ animal.visibleCondition }}</span>
                                  <span class="hint">{{ animal.enclosure?.name }}</span>
                                </summary>
                                <ul>
                                  <li
                                    v-for="blemish in animal.blemishes"
                                    :key="blemish.cause"
                                    class="leaf"
                                  >
                                    <span class="label">{{ causeLabels[blemish.cause] }}</span>
                                    <GaugeBar
                                      class="gauge"
                                      :value="-blemish.penalty"
                                      :min="-100"
                                      :max="100"
                                    />
                                    <span class="value">{{ signed(-blemish.penalty) }}</span>
                                    <span class="hint" />
                                  </li>
                                </ul>
                              </details>
                              <div v-else class="leaf">
                                <RouterLink :to="`/animals/${animal.id}`" class="label link">
                                  {{ emojiOf(animal.species.nameJa) }} {{ animal.name }}
                                </RouterLink>
                                <GaugeBar
                                  class="gauge"
                                  :value="animal.visibleCondition"
                                  :max="100"
                                />
                                <span class="value">{{ animal.visibleCondition }}</span>
                                <span class="hint">{{ animal.enclosure?.name }}</span>
                              </div>
                            </li>
                          </ul>
                        </details>
                      </li>
                      <li class="leaf">
                        <span class="label">入園料 {{ yen(zoo.admissionFee) }}</span>
                        <GaugeBar class="gauge" :value="feeEffect" :min="-100" :max="100" />
                        <span class="value">{{ signed(feeEffect) }}</span>
                        <span class="hint">高いほど体験が下がる</span>
                      </li>
                    </ul>
                  </details>
                </li>
                <li class="leaf">
                  <span class="label">来園の見込み</span>
                  <GaugeBar
                    class="gauge"
                    :value="zoo.expectedVisitors"
                    :max="zoo.visitorsForFullSwing"
                  />
                  <span class="value">{{ zoo.expectedVisitors.toLocaleString() }}人</span>
                  <span class="hint">
                    {{ zoo.visitorsForFullSwing.toLocaleString() }}人で最速・いま {{ swingRate }}%
                  </span>
                </li>
              </ul>
            </details>
          </li>
          <li class="leaf">
            <span class="label">自然減衰</span>
            <GaugeBar
              class="gauge"
              :value="zoo.reputationDecay"
              :min="-zoo.reputationSwingLimit"
              :max="zoo.reputationSwingLimit"
            />
            <span class="value">{{ signed(zoo.reputationDecay, 1) }}</span>
            <span class="hint">中立を超えた分が毎日減る</span>
          </li>
          <li>
            <details open>
              <summary class="node">
                <span class="label">前日の出来事</span>
                <span class="gauge" />
                <span class="value" />
                <span class="hint">死亡・発病でその日に大きく下がる</span>
              </summary>
              <ul>
                <li class="leaf">
                  <span class="label">死亡</span>
                  <span class="gauge" />
                  <span class="value" :class="{ minus: (lastDay?.deaths ?? 0) > 0 }">
                    {{ lastDay?.deaths ?? 0 }}頭
                  </span>
                  <span class="hint" />
                </li>
                <li class="leaf">
                  <span class="label">発病</span>
                  <span class="gauge" />
                  <span class="value" :class="{ minus: lastDay?.outbreak }">
                    {{ lastDay?.outbreak ? "あり" : "なし" }}
                  </span>
                  <span class="hint">{{ lastDay?.outbreak }}</span>
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
  overflow-x: auto;
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
  align-items: center;
  gap: 12px;
  min-width: 720px;
  min-height: 40px;
  padding: 4px 0;
}

.node {
  cursor: pointer;
  list-style: none;
}

.node::-webkit-details-marker {
  display: none;
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

.tree .leaf {
  padding-left: 26px;
}

.tree li.leaf {
  padding-left: 48px;
}

.label {
  flex: 1;
  min-width: 0;
  font-weight: 700;
}

.gauge {
  flex: 0 0 240px;
}

.value {
  flex: 0 0 72px;
  text-align: right;
  font-weight: 800;
}

.hint {
  flex: 0 0 260px;
  font-size: 0.85rem;
  color: var(--ink-soft);
}

.root .label,
.root .value {
  font-size: 1.2rem;
}

.link:hover {
  color: var(--brand);
  text-decoration: underline;
}

.minus {
  color: var(--bad);
}
</style>
