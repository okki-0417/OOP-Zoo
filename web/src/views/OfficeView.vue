<script setup lang="ts">
import { ref, shallowRef } from "vue";
import { api, unwrap, type DayReport } from "../api/client";
import MeterBar from "../components/MeterBar.vue";
import PageHeader from "../components/PageHeader.vue";
import QueryState from "../components/QueryState.vue";
import { useCommand } from "../composables/useCommand";
import { useQuery } from "../composables/useQuery";
import { yen } from "../format";

const report = useQuery(() => unwrap(api.GET("/report")));
const threatened = useQuery(() => unwrap(api.GET("/threatened")));
const deceased = useQuery(() => unwrap(api.GET("/deceased")));

const { busy, run } = useCommand();
const lastDay = shallowRef<DayReport>();
const fee = ref(1500);

function refresh() {
  void report.reload();
  void threatened.reload();
  void deceased.reload();
}

async function operate() {
  const day = await run(() => unwrap(api.POST("/operate")));
  if (!day) return;
  lastDay.value = day;
  refresh();
}

async function runWeek() {
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
  <PageHeader title="園長室" subtitle="今日も開園です" />

  <QueryState
    :loading="report.loading.value"
    :error="report.error.value"
    :empty="!report.data.value"
    @retry="report.reload"
  >
    <section v-if="report.data.value" class="card hero">
      <p class="muted">資金</p>
      <p class="balance" :class="{ negative: report.data.value.balance < 0 }">
        {{ yen(report.data.value.balance) }}
      </p>
      <MeterBar label="評判" :value="report.data.value.reputation" :max="100" />
      <dl class="stats">
        <div>
          <dt>飼育数</dt>
          <dd>{{ report.data.value.population }}</dd>
        </div>
        <div>
          <dt>種数</dt>
          <dd>{{ report.data.value.species_count }}</dd>
        </div>
        <div>
          <dt>希少種</dt>
          <dd>{{ report.data.value.threatened_count }}</dd>
        </div>
        <div>
          <dt>誕生</dt>
          <dd>{{ report.data.value.births }}</dd>
        </div>
      </dl>
    </section>
  </QueryState>

  <h2 class="section-title">営業</h2>
  <section class="card stack">
    <div class="row">
      <button class="btn btn-primary btn-block" :disabled="busy" @click="operate">
        ☀️ 1日営業する
      </button>
      <button class="btn btn-block" :disabled="busy" @click="runWeek">⏩ 7日すすめる</button>
    </div>

    <Transition name="pop">
      <div v-if="lastDay" class="day">
        <p v-if="lastDay.bankrupt" class="badge badge-bad">破産しました</p>
        <p v-if="lastDay.outbreak" class="badge badge-warn">🦠 {{ lastDay.outbreak }} が流行</p>
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
</template>

<style scoped>
.hero {
  display: grid;
  gap: 12px;
  background:
    radial-gradient(
      circle at 100% 0%,
      color-mix(in srgb, var(--accent) 22%, transparent),
      transparent 55%
    ),
    var(--surface);
}

.balance {
  font-size: 2.2rem;
  font-weight: 800;
  font-variant-numeric: tabular-nums;
  line-height: 1.1;
  margin-top: -8px;
}

.balance.negative {
  color: var(--bad);
}

.stats {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  margin: 0;
  text-align: center;
}

.stats dt {
  font-size: 0.7rem;
  color: var(--ink-soft);
}

.stats dd {
  margin: 0;
  font-size: 1.3rem;
  font-weight: 800;
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
