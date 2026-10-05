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
import { remedyOf, stressorLabel } from "../lib/stressors";

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
      stressors {
        cause
        amount
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

const causes: Record<BlemishCause, { label: string; remedy?: string }> = {
  STRESSED: { label: "ストレス" },
  SICK: { label: "病気", remedy: "治療する" },
  WEAK: { label: "衰弱", remedy: "給餌・治療する" },
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
      <div class="node root">
        <span class="label">
          評判
          <small class="forecast"
            >明日 {{ signed(zoo.reputationDrift + zoo.reputationDecay, 1) }}</small
          >
        </span>
        <GaugeBar class="gauge" :value="zoo.reputation" :max="100" />
        <span class="value">{{ zoo.reputation }}</span>
        <span class="action" />
      </div>
      <ul>
        <li>
          <div class="node">
            <span class="label">
              体験による寄り
              <span class="info" tabindex="0" :data-tip="pull">ⓘ</span>
            </span>
            <GaugeBar
              class="gauge"
              :value="zoo.reputationDrift"
              :min="-zoo.reputationSwingLimit"
              :max="zoo.reputationSwingLimit"
            />
            <span class="value">{{ signed(zoo.reputationDrift, 1) }}</span>
            <span class="action" />
          </div>
          <ul>
            <li>
              <div class="node">
                <span class="label">
                  来園者の体験
                  <span
                    class="info"
                    tabindex="0"
                    data-tip="評判はこの値に毎日少しずつ近づく。印はいまの評判"
                    >ⓘ</span
                  >
                </span>
                <GaugeBar
                  class="gauge"
                  :value="zoo.experience"
                  :max="100"
                  :marker="zoo.reputation"
                />
                <span class="value">{{ zoo.experience }}</span>
                <span class="action" />
              </div>
              <ul>
                <li>
                  <div class="node">
                    <span class="label">
                      展示動物の見た目
                      <span
                        class="info"
                        tabindex="0"
                        :data-tip="`展示中 ${exhibited.length} 頭の見た目の平均`"
                        >ⓘ</span
                      >
                    </span>
                    <GaugeBar class="gauge" :value="zoo.exhibitCondition" :max="100" />
                    <span class="value">{{ zoo.exhibitCondition }}</span>
                    <span class="action" />
                  </div>
                  <ul>
                    <li v-for="animal in exhibited" :key="animal.id">
                      <div class="node">
                        <span class="label">
                          {{ emojiOf(animal.species.nameJa) }} {{ animal.name }}
                          <small class="muted">{{ animal.enclosure?.name }}</small>
                        </span>
                        <GaugeBar class="gauge" :value="animal.visibleCondition" :max="100" />
                        <span class="value">{{ animal.visibleCondition }}</span>
                        <span class="action" />
                      </div>
                      <ul v-if="animal.blemishes.length > 0">
                        <li v-for="blemish in animal.blemishes" :key="blemish.cause">
                          <div class="node">
                            <span class="label">{{ causes[blemish.cause].label }}</span>
                            <GaugeBar
                              class="gauge"
                              :value="-blemish.penalty"
                              :min="-100"
                              :max="100"
                            />
                            <span class="value">{{ signed(-blemish.penalty) }}</span>
                            <RouterLink
                              v-if="causes[blemish.cause].remedy"
                              :to="`/animals/${animal.id}`"
                              class="action"
                            >
                              {{ causes[blemish.cause].remedy }} ›
                            </RouterLink>
                            <span v-else class="action" />
                          </div>
                          <ul v-if="blemish.cause === 'STRESSED'">
                            <li
                              v-for="stressor in animal.stressors"
                              :key="stressor.cause"
                              class="node"
                            >
                              <span class="label">{{ stressorLabel(stressor.cause) }}</span>
                              <GaugeBar class="gauge" :value="stressor.amount" :max="20" invert />
                              <span class="value">+{{ stressor.amount }}/日</span>
                              <RouterLink :to="remedyOf(stressor.cause, animal).to" class="action">
                                {{ remedyOf(stressor.cause, animal).label }} ›
                              </RouterLink>
                            </li>
                            <li v-if="animal.stressors.length === 0" class="node">
                              <span class="label muted">原因なし・回復中</span>
                              <span class="gauge" />
                              <span class="value" />
                              <span class="action" />
                            </li>
                          </ul>
                        </li>
                      </ul>
                    </li>
                  </ul>
                </li>
                <li class="node">
                  <span class="label">
                    入園料 {{ yen(zoo.admissionFee) }}
                    <span class="info" tabindex="0" data-tip="入園料が高いほど体験が下がる">ⓘ</span>
                  </span>
                  <GaugeBar class="gauge" :value="feeEffect" :min="-100" :max="100" />
                  <span class="value">{{ signed(feeEffect) }}</span>
                  <RouterLink to="/" class="action">入園料を見直す ›</RouterLink>
                </li>
              </ul>
            </li>
            <li class="node">
              <span class="label">
                来園の見込み
                <span
                  class="info"
                  tabindex="0"
                  :data-tip="`来園者が多いほど評判は速く動く。${zoo.visitorsForFullSwing.toLocaleString()}人で最速、いま ${swingRate}%`"
                  >ⓘ</span
                >
              </span>
              <GaugeBar
                class="gauge"
                :value="zoo.expectedVisitors"
                :max="zoo.visitorsForFullSwing"
              />
              <span class="value">{{ zoo.expectedVisitors.toLocaleString() }}人</span>
              <RouterLink to="/animals" class="action">人気の動物を導入する ›</RouterLink>
            </li>
          </ul>
        </li>
        <li class="node">
          <span class="label">
            自然減衰
            <span class="info" tabindex="0" data-tip="中立を超えた分が毎日少しずつ減る">ⓘ</span>
          </span>
          <GaugeBar
            class="gauge"
            :value="zoo.reputationDecay"
            :min="-zoo.reputationSwingLimit"
            :max="zoo.reputationSwingLimit"
          />
          <span class="value">{{ signed(zoo.reputationDecay, 1) }}</span>
          <span class="action" />
        </li>
        <li>
          <div class="node">
            <span class="label">
              前日の出来事
              <span class="info" tabindex="0" data-tip="死亡や発病があると、その日に大きく下がる"
                >ⓘ</span
              >
            </span>
            <span class="gauge" />
            <span class="value" />
            <span class="action" />
          </div>
          <ul>
            <li class="node">
              <span class="label">死亡</span>
              <span class="gauge" />
              <span class="value" :class="{ minus: (lastDay?.deaths ?? 0) > 0 }">
                {{ lastDay?.deaths ?? 0 }}頭
              </span>
              <RouterLink to="/" class="action">日課を確かめる ›</RouterLink>
            </li>
            <li class="node">
              <span class="label">発病</span>
              <span class="gauge" />
              <span class="value" :class="{ minus: lastDay?.outbreak }">
                {{ lastDay?.outbreak ? "あり" : "なし" }}
              </span>
              <RouterLink to="/animals" class="action">要注意の動物を見る ›</RouterLink>
            </li>
          </ul>
        </li>
      </ul>
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

.node {
  display: flex;
  align-items: center;
  gap: 12px;
  min-width: 720px;
  min-height: 40px;
  padding: 4px 0;
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

.action {
  flex: 0 0 200px;
  font-size: 0.85rem;
  font-weight: 700;
  color: var(--brand);
}

a.action:hover {
  text-decoration: underline;
}

.forecast {
  margin-left: 8px;
  font-size: 0.85rem;
  color: var(--ink-soft);
}

.info {
  position: relative;
  margin-left: 4px;
  font-size: 0.85rem;
  font-weight: 400;
  color: var(--ink-soft);
  cursor: help;
}

.info::after {
  content: attr(data-tip);
  position: absolute;
  z-index: 1;
  top: calc(100% + 6px);
  left: -8px;
  width: max-content;
  max-width: 280px;
  padding: 8px 10px;
  border: 1px solid var(--line);
  border-radius: 8px;
  background: var(--surface);
  box-shadow: var(--shadow);
  color: var(--ink);
  font-size: 0.8rem;
  line-height: 1.5;
  opacity: 0;
  visibility: hidden;
  transition: opacity 0.12s ease;
}

.info:hover::after,
.info:focus::after {
  opacity: 1;
  visibility: visible;
}

.root .label,
.root .value {
  font-size: 1.2rem;
}

.minus {
  color: var(--bad);
}
</style>
