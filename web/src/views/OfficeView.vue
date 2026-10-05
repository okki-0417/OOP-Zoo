<script setup lang="ts">
import { computed, ref, shallowRef } from "vue";
import { api, unwrap, type DayReport } from "../api/client";
import ChoreChecklist from "../components/ChoreChecklist.vue";
import MeterBar from "../components/MeterBar.vue";
import PageHeader from "../components/PageHeader.vue";
import QueryState from "../components/QueryState.vue";
import { useAlerts } from "../composables/useAlerts";
import { useCommand } from "../composables/useCommand";
import { useQuery } from "../composables/useQuery";
import { yen } from "../lib/currency";

const report = useQuery(() => unwrap(api.GET("/report")));
const checklist = useQuery(() => unwrap(api.GET("/checklist")));
const operatings = useQuery(() => unwrap(api.GET("/operatings")));
const threatened = useQuery(() => unwrap(api.GET("/threatened")));
const deceased = useQuery(() => unwrap(api.GET("/deceased")));
const { critical } = useAlerts();

const { busy, run } = useCommand();
const lastDay = shallowRef<DayReport>();
const fee = ref(1500);

const today = computed(() => (operatings.data.value?.at(-1)?.day ?? 0) + 1);
const yesterday = computed(() => operatings.data.value?.at(-1));
const recentDays = computed(() => (operatings.data.value ?? []).slice(-7).reverse());
const unfinished = computed(() =>
  (checklist.data.value ?? []).filter((chore) => chore.done_count < chore.total),
);

function refresh() {
  void report.reload();
  void checklist.reload();
  void operatings.reload();
  void threatened.reload();
  void deceased.reload();
}

function confirmClosing(days: number) {
  const concerns = [
    ...unfinished.value.map(
      (chore) => `${chore.label}が ${chore.total - chore.done_count} 件残っています`,
    ),
    critical.value.length > 0 && `緊急の対応が ${critical.value.length} 件残っています`,
  ].filter(Boolean);
  if (concerns.length === 0) return true;
  return window.confirm(`${concerns.join("\n")}\n\nこのまま${days}日分を締めますか？`);
}

async function closeDay() {
  if (!confirmClosing(1)) return;
  const day = await run(() => unwrap(api.POST("/operate")));
  if (!day) return;
  lastDay.value = day;
  refresh();
}

async function runWeek() {
  if (!confirmClosing(7)) return;
  await run(
    () => unwrap(api.POST("/run-days", { body: { days: 7 } })),
    (summary) =>
      summary.total_deaths === 0
        ? `${summary.days}日間、無事に営業しました`
        : `${summary.days}日間で ${summary.total_deaths} 頭が亡くなりました`,
  );
  lastDay.value = undefined;
  refresh();
}

async function changeFee() {
  await run(
    () => unwrap(api.PATCH("/admission-fee", { body: { fee: fee.value } })),
    (result) => `入園料を ${yen(result.admission_fee)} にしました`,
  );
}
</script>

<template>
  <PageHeader title="園長室" :subtitle="`${today}日目の営業中`" />

  <div class="board">
    <div>
      <QueryState
        :loading="report.loading.value"
        :error="report.error.value"
        :empty="!report.data.value"
        @retry="report.reload"
      >
        <section v-if="report.data.value" class="kpis">
          <div class="card kpi">
            <p class="muted">資金</p>
            <p class="figure" :class="{ negative: report.data.value.balance < 0 }">
              {{ yen(report.data.value.balance) }}
            </p>
            <p v-if="yesterday" class="delta" :class="yesterday.net_income < 0 ? 'minus' : 'plus'">
              前日 {{ yesterday.net_income < 0 ? "" : "+" }}{{ yen(yesterday.net_income) }}
            </p>
          </div>
          <div class="card kpi">
            <MeterBar label="評判" :value="report.data.value.reputation" :max="100" />
            <p v-if="yesterday" class="muted">
              前日の来園 {{ yesterday.visitors.toLocaleString() }} 人
            </p>
          </div>
        </section>
      </QueryState>

      <h2 class="section-title">今日の日課</h2>
      <QueryState
        :loading="checklist.loading.value"
        :error="checklist.error.value"
        :empty="!checklist.data.value"
        @retry="checklist.reload"
      >
        <ChoreChecklist :chores="checklist.data.value ?? []" />
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
            <p v-if="lastDay.bankrupt" class="badge badge-bad">資金が赤字です</p>
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
              <td :class="day.net_income < 0 ? 'minus' : 'plus'">{{ yen(day.net_income) }}</td>
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
        :loading="threatened.loading.value"
        :error="threatened.error.value"
        :empty="!threatened.data.value?.length"
        empty-text="絶滅危惧種はまだいません"
        @retry="threatened.reload"
      >
        <ul class="card list">
          <li v-for="species in threatened.data.value" :key="species.name_ja" class="row">
            <span class="badge badge-warn">{{ species.status_code }}</span>
            <span class="grow">{{ species.name_ja }}</span>
            <span class="muted">{{ species.status_label }}・{{ species.count }}頭</span>
          </li>
        </ul>
      </QueryState>
    </div>

    <div>
      <h2 class="section-title">慰霊碑</h2>
      <QueryState
        :loading="deceased.loading.value"
        :error="deceased.error.value"
        :empty="!deceased.data.value?.length"
        empty-text="亡くなった動物はいません"
        @retry="deceased.reload"
      >
        <ul class="card list">
          <li v-for="(dead, index) in deceased.data.value" :key="index" class="row">
            <span>🪦</span>
            <span class="grow"
              >{{ dead.name }}<span class="muted">（{{ dead.species }}）</span></span
            >
            <span class="muted">{{ dead.cause }}</span>
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
