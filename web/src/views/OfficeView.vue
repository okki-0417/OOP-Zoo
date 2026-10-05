<script setup lang="ts">
import { computed, ref, shallowRef, watch } from "vue";
import { graphql } from "../api/generated";
import type { OperateDayMutation } from "../api/generated/graphql";
import ChoreChecklist, { type Chore } from "../components/ChoreChecklist.vue";
import MeterBar from "../components/MeterBar.vue";
import PageHeader from "../components/PageHeader.vue";
import QueryState from "../components/QueryState.vue";
import { useAlerts } from "../composables/useAlerts";
import { useMutation } from "../composables/useMutation";
import { useQuery } from "../composables/useQuery";
import { yen } from "../lib/currency";

const OfficeQuery = graphql(`
  query Office {
    zoo {
      balance
      reputation
      admissionFee
    }
    operatings {
      day
      visitors
      netIncome
      deaths
    }
    enclosures {
      id
      name
      soiled
      dull
      occupants {
        id
        name
        alive
        fedToday
        species {
          nameJa
          threatened
          conservationCode
          conservationLabel
        }
      }
    }
    animals {
      id
      name
      alive
      sick
      causeOfDeath
      species {
        nameJa
      }
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
      balance
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
const { critical } = useAlerts();

const { busy, mutate } = useMutation();
const lastDay = shallowRef<OperateDayMutation["operateDay"]>();
const fee = ref(1500);

watch(
  () => office.data.value?.zoo.admissionFee,
  (current) => (fee.value = current ?? fee.value),
  { once: true },
);

const zoo = computed(() => office.data.value?.zoo);
const operatings = computed(() => office.data.value?.operatings ?? []);
const today = computed(() => (operatings.value.at(-1)?.day ?? 0) + 1);
const yesterday = computed(() => operatings.value.at(-1));
const recentDays = computed(() => operatings.value.slice(-7).reverse());

const inhabited = computed(() =>
  (office.data.value?.enclosures ?? [])
    .map((enclosure) => ({ ...enclosure, residents: enclosure.occupants.filter((a) => a.alive) }))
    .filter((enclosure) => enclosure.residents.length > 0),
);

const chores = computed<Chore[]>(() => {
  const residents = inhabited.value.flatMap((enclosure) => enclosure.residents);
  const patients = (office.data.value?.animals ?? []).filter((a) => a.alive && a.sick);
  const animal = (a: { id: string; name?: string | null }) =>
    ({ type: "animal", id: a.id, name: a.name ?? "" }) as const;
  const enclosure = (e: { id: string; name: string }) =>
    ({ type: "enclosure", id: e.id, name: e.name }) as const;
  return [
    {
      kind: "feeding",
      label: "給餌",
      items: residents.map((a) => ({ subject: animal(a), done: a.fedToday })),
    },
    {
      kind: "treatment",
      label: "治療",
      items: patients.map((a) => ({ subject: animal(a), done: false })),
    },
    {
      kind: "cleaning",
      label: "清掃",
      items: inhabited.value.map((e) => ({ subject: enclosure(e), done: !e.soiled })),
    },
    {
      kind: "enrichment",
      label: "遊具の補充",
      items: inhabited.value.map((e) => ({ subject: enclosure(e), done: !e.dull })),
    },
  ];
});
const unfinished = computed(() =>
  chores.value
    .map((chore) => ({ ...chore, left: chore.items.filter((item) => !item.done).length }))
    .filter((chore) => chore.left > 0),
);

const threatened = computed(() => {
  const counts = new Map<string, { nameJa: string; code: string; label: string; count: number }>();
  for (const { species } of inhabited.value.flatMap((enclosure) => enclosure.residents)) {
    if (!species.threatened) continue;
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
const deceased = computed(() => (office.data.value?.animals ?? []).filter((a) => !a.alive));

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
  const result = await mutate(OperateDayMutation, {});
  if (result) lastDay.value = result.operateDay;
}

async function runWeek() {
  if (!confirmClosing(7)) return;
  await mutate(RunDaysMutation, { days: 7 }, ({ runDays }) =>
    runDays.totalDeaths === 0
      ? `${runDays.days}日間、無事に営業しました`
      : `${runDays.days}日間で ${runDays.totalDeaths} 頭が亡くなりました`,
  );
  lastDay.value = undefined;
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
  <PageHeader title="園長室" :subtitle="`${today}日目の営業中`" />

  <div class="board">
    <div>
      <QueryState
        :loading="office.loading.value"
        :error="office.error.value"
        :empty="!zoo"
        @retry="office.reload"
      >
        <section v-if="zoo" class="kpis">
          <div class="card kpi">
            <p class="muted">資金</p>
            <p class="figure" :class="{ negative: zoo.balance < 0 }">
              {{ yen(zoo.balance) }}
            </p>
            <p v-if="yesterday" class="delta" :class="yesterday.netIncome < 0 ? 'minus' : 'plus'">
              前日 {{ yesterday.netIncome < 0 ? "" : "+" }}{{ yen(yesterday.netIncome) }}
            </p>
          </div>
          <div class="card kpi">
            <MeterBar label="評判" :value="zoo.reputation" :max="100" />
            <p v-if="yesterday" class="muted">
              前日の来園 {{ yesterday.visitors.toLocaleString() }} 人
            </p>
          </div>
        </section>
      </QueryState>

      <h2 class="section-title">今日の日課</h2>
      <QueryState
        :loading="office.loading.value"
        :error="office.error.value"
        :empty="!office.data.value"
        @retry="office.reload"
      >
        <ChoreChecklist :chores="chores" />
      </QueryState>
    </div>

    <div>
      <h2 class="section-title">日次締め</h2>
      <section class="card stack">
        <div class="row">
          <button class="btn btn-primary btn-block" :disabled="busy" @click="closeDay">
            🌙 今日を締める
          </button>
          <button class="btn btn-block" :disabled="busy" @click="runWeek">⏩ 7日すすめる</button>
        </div>

        <Transition name="pop">
          <div v-if="lastDay" class="day">
            <p v-if="lastDay.balance < 0" class="badge badge-bad">資金が赤字です</p>
            <p v-if="lastDay.outbreak" class="badge badge-warn">🦠 {{ lastDay.outbreak }} が発病</p>
            <dl class="ledger">
              <dt>来園者</dt>
              <dd>{{ lastDay.visitors.toLocaleString() }} 人</dd>
              <dt>収入</dt>
              <dd class="plus">+{{ yen(lastDay.income) }}</dd>
              <dt>支出</dt>
              <dd class="minus">-{{ yen(lastDay.cost) }}</dd>
              <dt>死亡</dt>
              <dd :class="{ minus: lastDay.deaths > 0 }">{{ lastDay.deaths }} 頭</dd>
            </dl>
          </div>
        </Transition>

        <form class="row fee" @submit.prevent="changeFee">
          <label class="field">
            入園料(円)
            <input v-model.number="fee" type="number" min="0" step="100" inputmode="numeric" />
          </label>
          <button class="btn" :disabled="busy">改定</button>
        </form>
      </section>

      <h2 class="section-title">直近の収支</h2>
      <section class="card">
        <p v-if="recentDays.length === 0" class="muted">まだ営業記録がありません</p>
        <table v-else class="ledger-table">
          <thead>
            <tr>
              <th>日</th>
              <th>来園</th>
              <th>純益</th>
              <th>死亡</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="day in recentDays" :key="day.day">
              <td>{{ day.day }}</td>
              <td>{{ day.visitors.toLocaleString() }}</td>
              <td :class="day.netIncome < 0 ? 'minus' : 'plus'">{{ yen(day.netIncome) }}</td>
              <td :class="{ minus: day.deaths > 0 }">{{ day.deaths }}</td>
            </tr>
          </tbody>
        </table>
      </section>
    </div>
  </div>

  <div class="columns">
    <div>
      <h2 class="section-title">展示中の絶滅危惧種</h2>
      <QueryState
        :loading="office.loading.value"
        :error="office.error.value"
        :empty="threatened.length === 0"
        empty-text="絶滅危惧種はまだいません"
        @retry="office.reload"
      >
        <ul class="card list">
          <li v-for="species in threatened" :key="species.nameJa" class="row">
            <span class="badge badge-warn">{{ species.code }}</span>
            <span class="grow">{{ species.nameJa }}</span>
            <span class="muted">{{ species.label }}・{{ species.count }}頭</span>
          </li>
        </ul>
      </QueryState>
    </div>

    <div>
      <h2 class="section-title">慰霊碑</h2>
      <QueryState
        :loading="office.loading.value"
        :error="office.error.value"
        :empty="deceased.length === 0"
        empty-text="亡くなった動物はいません"
        @retry="office.reload"
      >
        <ul class="card list">
          <li v-for="dead in deceased" :key="dead.id" class="row">
            <span>🪦</span>
            <span class="grow"
              >{{ dead.name }}<span class="muted">（{{ dead.species.nameJa }}）</span></span
            >
            <span class="muted">{{ dead.causeOfDeath }}</span>
          </li>
        </ul>
      </QueryState>
    </div>
  </div>
</template>

<style scoped>
.kpis {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
  gap: 12px;
}

.kpi {
  display: grid;
  gap: 6px;
  align-content: start;
}

.figure {
  font-size: 1.6rem;
  font-weight: 800;
  font-variant-numeric: tabular-nums;
  line-height: 1.15;
}

.figure.negative {
  color: var(--bad);
}

.delta {
  font-size: 0.85rem;
  font-weight: 700;
}

.board {
  display: grid;
  grid-template-columns: minmax(0, 2fr) minmax(300px, 1fr);
  gap: 24px;
  align-items: start;
  margin-bottom: 24px;
}

.board > * > .section-title:first-child {
  margin-top: 0;
}

@media (width < 1100px) {
  .board {
    grid-template-columns: minmax(0, 1fr);
  }
}

.day {
  display: grid;
  gap: 8px;
  padding: 12px;
  border-radius: 12px;
  background: var(--surface-sunk);
}

.ledger {
  display: grid;
  grid-template-columns: auto 1fr;
  gap: 4px 16px;
  margin: 0;
}

.ledger dt {
  color: var(--ink-soft);
}

.ledger dd {
  margin: 0;
  text-align: right;
  font-weight: 700;
  font-variant-numeric: tabular-nums;
}

.ledger-table {
  width: 100%;
  border-collapse: collapse;
  font-variant-numeric: tabular-nums;
}

.ledger-table th {
  font-size: 0.75rem;
  color: var(--ink-soft);
  text-align: right;
  padding-bottom: 6px;
}

.ledger-table td {
  text-align: right;
  padding: 6px 0;
  border-top: 1px solid var(--line);
  font-weight: 700;
}

.ledger-table th:first-child,
.ledger-table td:first-child {
  text-align: left;
}

.plus {
  color: var(--good);
}

.minus {
  color: var(--bad);
}

.fee {
  align-items: end;
}

.fee .field {
  flex: 1;
}

.pop-enter-from {
  opacity: 0;
  transform: scale(0.96);
}

.pop-enter-active {
  transition: all 0.2s ease;
}
</style>
