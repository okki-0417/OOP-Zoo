<script setup lang="ts">
import { computed, ref, watch } from "vue";
import { graphql } from "../api/generated";
import MeterBar from "../components/MeterBar.vue";
import PageHeader from "../components/PageHeader.vue";
import { useAlerts } from "../composables/useAlerts";
import { useChores } from "../composables/useChores";
import { useMutation } from "../composables/useMutation";
import { useQuery } from "../composables/useQuery";
import { yen } from "../lib/currency";

const OfficeQuery = graphql(`
  query Office {
    zoo {
      reputation
      reputationDrift
      reputationDecay
      admissionFee
    }
    operatings {
      visitors
      netIncome
    }
    enclosures {
      occupants {
        alive
        species {
          nameJa
          threatened
        }
      }
    }
    animals {
      alive
    }
  }
`);

const OperateDayMutation = graphql(`
  mutation OperateDay {
    operateDay {
      visitors
      income
      cost
      deaths
      outbreak
    }
  }
`);

const RunDaysMutation = graphql(`
  mutation RunDays($days: Int!) {
    runDays(days: $days) {
      days
      totalDeaths
    }
  }
`);

const SetAdmissionFeeMutation = graphql(`
  mutation SetAdmissionFee($fee: Int!) {
    setAdmissionFee(fee: $fee) {
      admissionFee
    }
  }
`);

const office = useQuery(OfficeQuery);
const { chores, unfinished } = useChores();
const { critical } = useAlerts();
const { busy, mutate } = useMutation();
const fee = ref(1500);

watch(
  () => office.data.value?.zoo.admissionFee,
  (current) => (fee.value = current ?? fee.value),
  { once: true },
);

const zoo = computed(() => office.data.value?.zoo);
const yesterday = computed(() => office.data.value?.operatings.at(-1));
const residents = computed(() =>
  (office.data.value?.enclosures ?? []).flatMap((e) => e.occupants).filter((a) => a.alive),
);
const threatenedSpecies = computed(
  () => new Set(residents.value.filter((a) => a.species.threatened).map((a) => a.species.nameJa)),
);
const deceased = computed(() => (office.data.value?.animals ?? []).filter((a) => !a.alive));

const icons: Record<string, string> = {
  feeding: "🍖",
  treatment: "💊",
  cleaning: "🧹",
  enrichment: "🪵",
};

function doneOf(chore: (typeof chores.value)[number]) {
  return chore.items.filter((item) => item.done).length;
}

function signed(value: number, digits = 0) {
  return `${value < 0 ? "−" : "+"}${Math.abs(value).toFixed(digits)}`;
}

function confirmClosing(days: number) {
  const concerns = [
    ...unfinished.value.map((chore) => `${chore.label}が ${chore.left} 件残っています`),
    critical.value.length > 0 && `緊急の対応が ${critical.value.length} 件残っています`,
  ].filter(Boolean);
  if (concerns.length === 0) return true;
  return window.confirm(`${concerns.join("\n")}\n\nこのまま${days}日分を締めますか？`);
}

async function closeDay() {
  if (!confirmClosing(1)) return;
  await mutate(OperateDayMutation, {}, ({ operateDay: day }) =>
    [
      `来園 ${day.visitors.toLocaleString()}人・収入 ${yen(day.income)}・支出 ${yen(day.cost)}`,
      day.deaths > 0 && `${day.deaths}頭が亡くなりました`,
      day.outbreak && `${day.outbreak}が発病しました`,
    ]
      .filter(Boolean)
      .join("。"),
  );
}

async function runWeek() {
  if (!confirmClosing(7)) return;
  await mutate(RunDaysMutation, { days: 7 }, ({ runDays }) =>
    runDays.totalDeaths === 0
      ? `${runDays.days}日間、無事に営業しました`
      : `${runDays.days}日間で ${runDays.totalDeaths} 頭が亡くなりました`,
  );
}

async function changeFee() {
  await mutate(
    SetAdmissionFeeMutation,
    { fee: fee.value },
    ({ setAdmissionFee }) => `入園料を ${yen(setAdmissionFee.admissionFee)} にしました`,
  );
}
</script>

<template>
  <PageHeader title="園長室" />

  <div class="split">
    <div class="scroll-box">
      <div class="board">
        <div class="main">
          <RouterLink to="/chores" class="card link-card chores">
            <p class="card-title">
              今日の日課
              <span class="more">くわしく ›</span>
            </p>
            <div v-for="chore in chores" :key="chore.kind" class="chore">
              <span>{{ icons[chore.kind] }}</span>
              <span class="label">{{ chore.label }}</span>
              <span class="track">
                <span
                  :style="{
                    width: `${chore.items.length ? (doneOf(chore) / chore.items.length) * 100 : 100}%`,
                  }"
                />
              </span>
              <span class="tally" :class="{ left: doneOf(chore) < chore.items.length }">
                {{ doneOf(chore) }} / {{ chore.items.length }}
              </span>
            </div>
          </RouterLink>

          <section class="card closing">
            <button class="btn btn-primary btn-small" :disabled="busy" @click="closeDay">
              🌙 今日を締める
            </button>
            <button class="btn btn-small" :disabled="busy" @click="runWeek">⏩ 7日</button>
            <form class="fee" @submit.prevent="changeFee">
              <label class="muted" for="fee">入園料</label>
              <input
                id="fee"
                v-model.number="fee"
                class="inline-select"
                type="number"
                min="0"
                step="100"
                inputmode="numeric"
              />
              <button class="btn btn-small" :disabled="busy">改定</button>
            </form>
          </section>
        </div>

        <div class="side">
          <RouterLink to="/finance" class="card link-card stat">
            <p class="card-title">収支 <span class="more">内訳 ›</span></p>
            <template v-if="yesterday">
              <p class="figure" :class="yesterday.netIncome < 0 ? 'minus' : 'plus'">
                {{ yesterday.netIncome < 0 ? "" : "+" }}{{ yen(yesterday.netIncome) }}
              </p>
              <p class="muted">前日・来園 {{ yesterday.visitors.toLocaleString() }} 人</p>
            </template>
            <p v-else class="muted">まだ営業記録がありません</p>
          </RouterLink>

          <RouterLink v-if="zoo" to="/reputation" class="card link-card stat">
            <p class="card-title">評判 <span class="more">内訳 ›</span></p>
            <MeterBar label="" :value="zoo.reputation" :max="100" />
            <p class="muted">明日 {{ signed(zoo.reputationDrift + zoo.reputationDecay, 1) }}</p>
          </RouterLink>

          <div class="pair">
            <RouterLink to="/threatened" class="card link-card stat">
              <p class="card-title">絶滅危惧種</p>
              <p class="figure">{{ threatenedSpecies.size }}<small> 種</small></p>
            </RouterLink>
            <RouterLink to="/memorial" class="card link-card stat">
              <p class="card-title">慰霊碑</p>
              <p class="figure">{{ deceased.length }}<small> 頭</small></p>
            </RouterLink>
          </div>
        </div>
      </div>
    </div>

    <RouterView />
  </div>
</template>

<style scoped>
.scroll-box {
  container-type: inline-size;
}

.board {
  display: grid;
  grid-template-columns: minmax(0, 1.3fr) minmax(0, 1fr);
  gap: 10px;
}

@container (width < 520px) {
  .board {
    grid-template-columns: minmax(0, 1fr);
  }
}

.main,
.side {
  display: grid;
  align-content: start;
  gap: 10px;
}

.card {
  padding: 10px 14px;
}

.link-card:hover {
  border-color: var(--brand);
}

.card-title {
  display: flex;
  justify-content: space-between;
  font-size: 0.8rem;
  font-weight: 700;
  color: var(--ink-soft);
}

.more {
  font-size: 0.75rem;
  color: var(--brand);
}

.chores {
  display: grid;
  gap: 8px;
}

.chore {
  display: grid;
  grid-template-columns: 1.4em 5.5em minmax(0, 1fr) 3.5em;
  align-items: center;
  gap: 6px;
  font-size: 0.85rem;
  font-weight: 700;
}

.track {
  height: 6px;
  border-radius: 999px;
  background: var(--surface-sunk);
  overflow: hidden;
}

.track span {
  display: block;
  height: 100%;
  border-radius: inherit;
  background: var(--good);
}

.tally {
  text-align: right;
  font-variant-numeric: tabular-nums;
}

.tally.left {
  color: var(--warn);
}

.closing {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  gap: 6px;
}

.fee {
  display: flex;
  align-items: center;
  gap: 6px;
  margin-left: auto;
}

.fee input {
  width: 80px;
}

.stat {
  display: grid;
  gap: 4px;
}

.figure {
  font-size: 1.3rem;
  font-weight: 800;
  font-variant-numeric: tabular-nums;
  line-height: 1.2;
}

.figure small {
  font-size: 0.8rem;
  color: var(--ink-soft);
}

.pair {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 10px;
}

.plus {
  color: var(--good);
}

.minus {
  color: var(--bad);
}
</style>
