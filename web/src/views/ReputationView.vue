<script setup lang="ts">
import { computed } from "vue";
import { graphql } from "../api/generated";
import MeterBar from "../components/MeterBar.vue";
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
      day
      reputation
      visitors
      deaths
      outbreak
    }
  }
`);

const query = useQuery(ReputationQuery);

const zoo = computed(() => query.data.value?.zoo);
const feeEffect = computed(() =>
  zoo.value ? zoo.value.exhibitCondition - zoo.value.experience : 0,
);
const change = computed(() => {
  const value = zoo.value?.expectedReputationChange ?? 0;
  return `${value < 0 ? "−" : "+"}${Math.abs(value).toFixed(1)}`;
});
const heading = computed(() => {
  if (!zoo.value) return "";
  if (zoo.value.expectedVisitors === 0) return "来園者がいないので、体験では評判が動きません";
  if (zoo.value.experience > zoo.value.reputation)
    return "体験が評判を上回っています。来園者が増えるほど評判は上がります";
  if (zoo.value.experience < zoo.value.reputation)
    return "体験が評判を下回っています。このままだと評判は下がっていきます";
  return "体験と評判が釣り合っています";
});

const blemished = computed(() =>
  (query.data.value?.animals ?? [])
    .filter((animal) => animal.alive && animal.enclosure && animal.visibleCondition < 100)
    .sort((a, b) => a.visibleCondition - b.visibleCondition),
);

const history = computed(() => {
  const days = query.data.value?.operatings ?? [];
  return days
    .map((day, index) => ({
      ...day,
      delta: day.reputation - (days[index - 1]?.reputation ?? day.reputation),
    }))
    .slice(-14)
    .reverse();
});
</script>

<template>
  <PageHeader title="評判" :crumbs="[{ label: '園長室', to: '/' }]" />

  <QueryState
    :loading="query.loading.value"
    :error="query.error.value"
    :empty="!zoo"
    @retry="query.reload"
  >
    <template v-if="zoo">
      <section class="kpis">
        <div class="card kpi">
          <MeterBar label="いまの評判" :value="zoo.reputation" :max="100" />
        </div>
        <div class="card kpi">
          <MeterBar label="来園者の体験（評判が向かう先）" :value="zoo.experience" :max="100" />
        </div>
        <div class="card kpi">
          <p class="muted">明日の見込み</p>
          <p class="figure" :class="zoo.expectedReputationChange < 0 ? 'minus' : 'plus'">
            {{ change }}
          </p>
          <p class="muted">
            来園 {{ zoo.expectedVisitors.toLocaleString() }} 人の見込み・事故がなければ
          </p>
        </div>
      </section>

      <p class="card verdict">{{ heading }}</p>

      <h2 class="section-title">体験の内訳</h2>
      <section class="card">
        <dl class="ledger">
          <dt>展示動物の見た目（平均）</dt>
          <dd>{{ zoo.exhibitCondition }}</dd>
          <dt>入園料 {{ yen(zoo.admissionFee) }} による差し引き</dt>
          <dd :class="{ minus: feeEffect > 0 }">−{{ feeEffect }}</dd>
          <dt class="total">来園者の体験</dt>
          <dd class="total">{{ zoo.experience }}</dd>
        </dl>
        <p class="muted note">
          評判は毎日、来園者の体験に少しずつ近づきます。来園者が多いほど速く動き、下がるときは上がるときより速く動きます。中立を超えた分は、何もしなければ少しずつ減ります。死亡や感染症の発生があると、その日に大きく下がります。
        </p>
      </section>
    </template>
  </QueryState>

  <h2 class="section-title">見た目が損なわれている展示動物</h2>
  <QueryState
    :loading="query.loading.value"
    :error="query.error.value"
    :empty="blemished.length === 0"
    empty-text="展示中の動物はみな良い状態です"
    @retry="query.reload"
  >
    <div class="card table-card">
      <table class="data-table">
        <thead>
          <tr>
            <th>名前</th>
            <th>種</th>
            <th>エリア</th>
            <th>見た目</th>
            <th>原因</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="animal in blemished" :key="animal.id">
            <td>
              <RouterLink :to="`/animals/${animal.id}`" class="cell-link">
                <span>{{ emojiOf(animal.species.nameJa) }}</span>
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
            </td>
            <td class="meter-cell">
              <MeterBar label="" :value="animal.visibleCondition" :max="100" />
            </td>
            <td>
              <div class="badges">
                <span v-if="animal.stressed" class="badge badge-warn">ストレス</span>
                <span v-if="animal.sick" class="badge badge-bad">病気</span>
                <span v-if="animal.weak" class="badge badge-bad">衰弱</span>
              </div>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
  </QueryState>

  <h2 class="section-title">評判の推移</h2>
  <section class="card">
    <p v-if="history.length === 0" class="muted">まだ営業記録がありません</p>
    <table v-else class="ledger-table">
      <thead>
        <tr>
          <th>日</th>
          <th>評判</th>
          <th>前日比</th>
          <th>来園</th>
          <th>出来事</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="day in history" :key="day.day">
          <td>{{ day.day }}</td>
          <td>{{ day.reputation }}</td>
          <td :class="{ plus: day.delta > 0, minus: day.delta < 0 }">
            {{ day.delta > 0 ? "+" : "" }}{{ day.delta }}
          </td>
          <td>{{ day.visitors.toLocaleString() }}</td>
          <td>
            <span v-if="day.deaths > 0" class="badge badge-bad">死亡 {{ day.deaths }} 頭</span>
            <span v-if="day.outbreak" class="badge badge-warn">{{ day.outbreak }} が発病</span>
          </td>
        </tr>
      </tbody>
    </table>
  </section>
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

.verdict {
  margin-top: 12px;
  font-weight: 700;
}

.ledger {
  display: grid;
  grid-template-columns: auto 1fr;
  gap: 6px 0;
  margin: 0;
}

.ledger dt {
  color: var(--ink-soft);
}

.ledger dd {
  margin: 0;
  padding-left: 16px;
  text-align: right;
  font-weight: 700;
  font-variant-numeric: tabular-nums;
}

.ledger .total {
  padding-top: 6px;
  border-top: 1px solid var(--line);
  color: var(--ink);
}

.note {
  margin-top: 12px;
  font-size: 0.85rem;
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

.ledger-table th:last-child,
.ledger-table td:last-child {
  width: 45%;
  text-align: left;
  padding-left: 24px;
}

.plus {
  color: var(--good);
}

.minus {
  color: var(--bad);
}
</style>
