<script setup lang="ts">
import { computed } from "vue";
import { graphql } from "../api/generated";
import type { BlemishCause, BuzzKind } from "../api/generated/graphql";
import GaugeBar from "../components/GaugeBar.vue";
import QueryState from "../components/QueryState.vue";
import SideSheet from "../components/SideSheet.vue";
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
      spectacle
      spectacleSaturation
      spectacleCharisma
      spectacleHerdBonus
      spectacleBuzz
      herds {
        size
        multiplier
        bonus
        species {
          nameJa
        }
        enclosure {
          name
        }
      }
      buzzes {
        kind
        amount
        animal {
          id
          name
          species {
            nameJa
          }
        }
      }
      willingnessToPay
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
        code
        nameJa
        charisma
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

const buzzKinds: Record<BuzzKind, string> = {
  NEWBORN: "🍼 赤ちゃん",
  NEWCOMER: "🆕 新入り",
};

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

const exhibitedSpecies = computed(() =>
  [
    ...new Map(exhibited.value.map((animal) => [animal.species.code, animal.species])).values(),
  ].sort((a, b) => b.charisma - a.charisma),
);

const lastDay = computed(() => query.data.value?.operatings.at(-1));

function signed(value: number, digits = 0) {
  return `${value < 0 ? "−" : "+"}${Math.abs(value).toFixed(digits)}`;
}
</script>

<template>
  <SideSheet title="評判" close-to="/" wide>
    <QueryState
      :loading="query.loading.value"
      :error="query.error.value"
      :empty="!zoo"
      @retry="query.reload"
    >
      <section v-if="zoo" class="tree">
        <div class="node root">
          <span class="label">
            評判
            <small class="forecast"
              >明日 {{ signed(zoo.reputationDrift + zoo.reputationDecay, 1) }}</small
            >
          </span>
          <GaugeBar class="gauge" :value="zoo.reputation" :max="100" />
          <span class="value">{{ zoo.reputation }}</span>
        </div>
        <ul>
          <li>
            <details open>
              <summary class="node">
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
              </summary>
              <ul>
                <li>
                  <details open>
                    <summary class="node">
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
                    </summary>
                    <ul>
                      <li>
                        <details>
                          <summary class="node">
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
                          </summary>
                          <ul>
                            <li v-for="animal in exhibited" :key="animal.id">
                              <details v-if="animal.blemishes.length > 0">
                                <summary class="node">
                                  <span class="label">
                                    {{ emojiOf(animal.species.nameJa) }} {{ animal.name }}
                                    <small class="muted">{{ animal.enclosure?.name }}</small>
                                  </span>
                                  <GaugeBar
                                    class="gauge"
                                    :value="animal.visibleCondition"
                                    :max="100"
                                  />
                                  <span class="value">{{ animal.visibleCondition }}</span>
                                </summary>
                                <ul>
                                  <li v-for="blemish in animal.blemishes" :key="blemish.cause">
                                    <details v-if="blemish.cause === 'STRESSED'">
                                      <summary class="node">
                                        <span class="label">{{ causes[blemish.cause].label }}</span>
                                        <GaugeBar
                                          class="gauge"
                                          :value="-blemish.penalty"
                                          :min="-100"
                                          :max="100"
                                        />
                                        <span class="value">{{ signed(-blemish.penalty) }}</span>
                                      </summary>
                                      <ul>
                                        <li
                                          v-for="stressor in animal.stressors"
                                          :key="stressor.cause"
                                          class="node"
                                        >
                                          <span class="label">{{
                                            stressorLabel(stressor.cause)
                                          }}</span>
                                          <GaugeBar
                                            class="gauge"
                                            :value="stressor.amount"
                                            :max="20"
                                            invert
                                          />
                                          <span class="value">+{{ stressor.amount }}/日</span>
                                          <RouterLink
                                            :to="remedyOf(stressor.cause, animal).to"
                                            class="action"
                                          >
                                            {{ remedyOf(stressor.cause, animal).label }} ›
                                          </RouterLink>
                                        </li>
                                        <li v-if="animal.stressors.length === 0" class="node">
                                          <span class="label muted">原因なし・回復中</span>
                                        </li>
                                      </ul>
                                    </details>
                                    <div v-else class="node">
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
                                    </div>
                                  </li>
                                </ul>
                              </details>
                              <div v-else class="node">
                                <span class="label">
                                  {{ emojiOf(animal.species.nameJa) }} {{ animal.name }}
                                  <small class="muted">{{ animal.enclosure?.name }}</small>
                                </span>
                                <GaugeBar
                                  class="gauge"
                                  :value="animal.visibleCondition"
                                  :max="100"
                                />
                                <span class="value">{{ animal.visibleCondition }}</span>
                              </div>
                            </li>
                          </ul>
                        </details>
                      </li>
                      <li class="node">
                        <span class="label">
                          入園料 {{ yen(zoo.admissionFee) }}
                          <span class="info" tabindex="0" data-tip="入園料が高いほど体験が下がる"
                            >ⓘ</span
                          >
                        </span>
                        <GaugeBar class="gauge" :value="feeEffect" :min="-100" :max="100" />
                        <span class="value">{{ signed(feeEffect) }}</span>
                        <RouterLink to="/" class="action">入園料を見直す ›</RouterLink>
                      </li>
                    </ul>
                  </details>
                </li>
                <li>
                  <details open>
                    <summary class="node">
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
                    </summary>
                    <ul>
                      <li>
                        <details>
                          <summary class="node">
                            <span class="label">
                              展示の魅力
                              <span
                                class="info"
                                tabindex="0"
                                data-tip="来園者数の上限と、払ってもよい入園料の上限を決める"
                                >ⓘ</span
                              >
                            </span>
                            <GaugeBar
                              class="gauge"
                              :value="zoo.spectacle"
                              :max="zoo.spectacleSaturation"
                            />
                            <span class="value">{{ zoo.spectacle }}</span>
                          </summary>
                          <ul>
                            <li>
                              <details>
                                <summary class="node">
                                  <span class="label">
                                    展示中の種の人気度
                                    <span
                                      class="info"
                                      tabindex="0"
                                      data-tip="種ごとに1回だけ数え、同じ種を増やしても上がらない。合計が大きくなるほど伸びは鈍る"
                                      >ⓘ</span
                                    >
                                  </span>
                                  <GaugeBar
                                    class="gauge"
                                    :value="zoo.spectacleCharisma"
                                    :max="zoo.spectacleSaturation"
                                  />
                                  <span class="value">{{ zoo.spectacleCharisma }}</span>
                                  <RouterLink to="/animals" class="action">
                                    未展示の種を導入する ›
                                  </RouterLink>
                                </summary>
                                <ul>
                                  <li
                                    v-for="species in exhibitedSpecies"
                                    :key="species.code"
                                    class="node"
                                  >
                                    <span class="label">
                                      {{ emojiOf(species.nameJa) }} {{ species.nameJa }}
                                    </span>
                                    <GaugeBar class="gauge" :value="species.charisma" :max="100" />
                                    <span class="value">{{ species.charisma }}</span>
                                  </li>
                                </ul>
                              </details>
                            </li>
                            <li>
                              <details>
                                <summary class="node">
                                  <span class="label">
                                    群れの見応え
                                    <span
                                      class="info"
                                      tabindex="0"
                                      data-tip="群れで暮らす種は、同じエリアの頭数が多いほど見応えが増す(上限1.5倍)。過密なエリアでは増えない"
                                      >ⓘ</span
                                    >
                                  </span>
                                  <GaugeBar
                                    class="gauge"
                                    :value="zoo.spectacleHerdBonus"
                                    :max="zoo.spectacleSaturation"
                                  />
                                  <span class="value">+{{ zoo.spectacleHerdBonus }}</span>
                                  <RouterLink to="/enclosures" class="action">
                                    群れを見直す ›
                                  </RouterLink>
                                </summary>
                                <ul>
                                  <li
                                    v-for="herd in zoo.herds"
                                    :key="`${herd.species.nameJa}-${herd.enclosure.name}`"
                                    class="node"
                                  >
                                    <span class="label">
                                      {{ emojiOf(herd.species.nameJa) }} {{ herd.species.nameJa }}
                                      {{ herd.size }}頭
                                      <small class="muted"
                                        >{{ herd.enclosure.name }}・×{{ herd.multiplier }}</small
                                      >
                                    </span>
                                    <span class="value">+{{ herd.bonus }}</span>
                                  </li>
                                  <li v-if="zoo.herds.length === 0" class="node">
                                    <span class="label muted">群れで見せている種はありません</span>
                                  </li>
                                </ul>
                              </details>
                            </li>
                            <li>
                              <details>
                                <summary class="node">
                                  <span class="label">
                                    話題
                                    <span
                                      class="info"
                                      tabindex="0"
                                      data-tip="園で生まれた赤ちゃん(30日)と導入したばかりの新入り(7日)が人を呼ぶ。日が経つと薄れる"
                                      >ⓘ</span
                                    >
                                  </span>
                                  <GaugeBar
                                    class="gauge"
                                    :value="zoo.spectacleBuzz"
                                    :max="zoo.spectacleSaturation"
                                  />
                                  <span class="value">+{{ zoo.spectacleBuzz }}</span>
                                </summary>
                                <ul>
                                  <li v-for="buzz in zoo.buzzes" :key="buzz.animal.id" class="node">
                                    <span class="label">
                                      {{ buzzKinds[buzz.kind] }} {{ buzz.animal.name }}
                                      <small class="muted">{{ buzz.animal.species.nameJa }}</small>
                                    </span>
                                    <span class="value">+{{ buzz.amount }}</span>
                                    <RouterLink :to="`/animals/${buzz.animal.id}`" class="action">
                                      会いに行く ›
                                    </RouterLink>
                                  </li>
                                  <li v-if="zoo.buzzes.length === 0" class="node">
                                    <span class="label muted">赤ちゃんや新入りはいません</span>
                                  </li>
                                </ul>
                              </details>
                            </li>
                          </ul>
                        </details>
                      </li>
                      <li class="node">
                        <span class="label">
                          評判
                          <span
                            class="info"
                            tabindex="0"
                            data-tip="来園者数の上限と、払ってもよい入園料の上限の両方に掛かる"
                            >ⓘ</span
                          >
                        </span>
                        <GaugeBar class="gauge" :value="zoo.reputation" :max="100" />
                        <span class="value">{{ zoo.reputation }}</span>
                      </li>
                      <li class="node">
                        <span class="label">
                          入園料 {{ yen(zoo.admissionFee) }}
                          <span
                            class="info"
                            tabindex="0"
                            :data-tip="`来園者が払ってもよい上限は ${yen(zoo.willingnessToPay)}。上限に近いほど来園者が減り、超えると誰も来ない`"
                            >ⓘ</span
                          >
                        </span>
                        <GaugeBar
                          class="gauge"
                          :value="zoo.admissionFee"
                          :max="zoo.willingnessToPay"
                          invert
                        />
                        <span class="value"
                          >{{ Math.round((zoo.admissionFee / zoo.willingnessToPay) * 100) }}%</span
                        >
                        <RouterLink to="/" class="action">入園料を見直す ›</RouterLink>
                      </li>
                    </ul>
                  </details>
                </li>
              </ul>
            </details>
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
          </li>
          <li>
            <details>
              <summary class="node">
                <span class="label">
                  前日の出来事
                  <span
                    class="info"
                    tabindex="0"
                    data-tip="死亡や発病があると、その日に大きく下がる"
                    >ⓘ</span
                  >
                </span>
              </summary>
              <ul>
                <li class="node">
                  <span class="label">死亡</span>
                  <span class="value" :class="{ minus: (lastDay?.deaths ?? 0) > 0 }">
                    {{ lastDay?.deaths ?? 0 }}頭
                  </span>
                  <RouterLink to="/chores" class="action">日課を確かめる ›</RouterLink>
                </li>
                <li class="node">
                  <span class="label">発病</span>
                  <span class="value" :class="{ minus: lastDay?.outbreak }">
                    {{ lastDay?.outbreak ? "あり" : "なし" }}
                  </span>
                  <RouterLink to="/animals" class="action">要注意の動物を見る ›</RouterLink>
                </li>
              </ul>
            </details>
          </li>
        </ul>
      </section>
    </QueryState>
  </SideSheet>
</template>

<style scoped>
.tree {
  --branch: color-mix(in srgb, var(--ink-soft) 45%, transparent);
  font-variant-numeric: tabular-nums;
}

.tree ul {
  list-style: none;
  margin: 0;
  padding-left: 8px;
}

.tree li {
  position: relative;
  padding-left: 16px;
}

.tree li::before {
  content: "";
  position: absolute;
  top: 0;
  left: 0;
  width: 12px;
  height: 18px;
  border-left: 1px solid var(--branch);
  border-bottom: 1px solid var(--branch);
}

.tree li:not(:last-child)::after {
  content: "";
  position: absolute;
  top: 18px;
  bottom: 0;
  left: 0;
  border-left: 1px solid var(--branch);
}

.node {
  display: grid;
  grid-template-columns: minmax(0, 1fr) 110px 64px;
  grid-template-areas:
    "label gauge value"
    "action gauge value";
  align-items: center;
  column-gap: 10px;
  min-height: 36px;
  padding: 3px 0;
}

summary.node {
  cursor: pointer;
  list-style: none;
}

summary.node::-webkit-details-marker {
  display: none;
}

summary.node .label::before {
  content: "▸ ";
  color: var(--ink-soft);
}

details[open] > summary.node .label::before {
  content: "▾ ";
}

.label {
  grid-area: label;
  min-width: 0;
  font-weight: 700;
  font-size: 0.85rem;
}

.gauge {
  grid-area: gauge;
}

.value {
  grid-area: value;
  text-align: right;
  font-weight: 800;
  font-size: 0.85rem;
}

.action {
  grid-area: action;
  font-size: 0.75rem;
  font-weight: 700;
  color: var(--brand);
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

.info:focus::after {
  opacity: 1;
  visibility: visible;
}

.root .label,
.root .value {
  font-size: 1.05rem;
}

.minus {
  color: var(--bad);
}
</style>
