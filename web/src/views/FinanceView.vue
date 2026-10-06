<script setup lang="ts">
import { computed } from "vue";
import { graphql } from "../api/generated";
import type { ExpenseCategory } from "../api/generated/graphql";
import PageHeader from "../components/PageHeader.vue";
import QueryState from "../components/QueryState.vue";
import { useQuery } from "../composables/useQuery";
import { yen } from "../lib/currency";

const FinanceQuery = graphql(`
  query Finance {
    operatings {
      day
      visitors
      income
      cost
      netIncome
      balance
      expenses {
        category
        subject
        quantity
        amount
      }
    }
  }
`);

const DAYS_SHOWN = 7;

const categories: { key: ExpenseCategory; label: string; remedy: string; to: string }[] = [
  { key: "PAYROLL", label: "人件費", remedy: "スタッフを見る", to: "/staff" },
  { key: "UPKEEP", label: "施設維持費", remedy: "エリアを見る", to: "/enclosures" },
  { key: "FEED", label: "飼料費", remedy: "動物を見る", to: "/animals" },
];

const query = useQuery(FinanceQuery);

const days = computed(() => (query.data.value?.operatings ?? []).slice(-DAYS_SHOWN));
const latest = computed(() => days.value.at(-1));
const previous = computed(() => days.value.at(-2));

type Day = (typeof days.value)[number];
type Cell = { amount: number; quantity: number } | undefined;
type Line = { label: string; cells: Cell[] };

const itemized = (day: Day) => day.expenses.length > 0 || day.cost === 0;

function categoryCell(day: Day, category: ExpenseCategory): Cell {
  if (!itemized(day)) return undefined;
  const amount = day.expenses
    .filter((expense) => expense.category === category)
    .reduce((sum, expense) => sum + expense.amount, 0);
  return { amount, quantity: 1 };
}

function subjectLines(category: ExpenseCategory): Line[] {
  const expensesOf = (day: Day) => day.expenses.filter((e) => e.category === category);
  const latestAmount = (subject: string) =>
    expensesOf(latest.value!).find((e) => e.subject === subject)?.amount ?? 0;
  const subjects = [...new Set(days.value.flatMap((day) => expensesOf(day).map((e) => e.subject)))];
  return subjects
    .sort((a, b) => latestAmount(b) - latestAmount(a))
    .map((subject) => ({
      label: subject,
      cells: days.value.map((day) => {
        const found = expensesOf(day).find((e) => e.subject === subject);
        if (found) return { amount: found.amount, quantity: found.quantity };
        return itemized(day) ? { amount: 0, quantity: 0 } : undefined;
      }),
    }));
}

const sections = computed(() =>
  categories.map((category) => ({
    ...category,
    cells: days.value.map((day) => categoryCell(day, category.key)),
    lines: subjectLines(category.key),
  })),
);

function change(cells: Cell[]) {
  const [before, after] = cells.slice(-2);
  if (cells.length < 2 || !before || !after) return undefined;
  return after.amount - before.amount;
}

function tone(diff: number | undefined, side: "income" | "expense") {
  if (!diff) return undefined;
  return diff > 0 === (side === "income") ? "plus" : "minus";
}

const signed = (amount: number) => `${amount > 0 ? "+" : ""}${yen(amount)}`;
const incomeChange = computed(() =>
  change(days.value.map((day) => ({ amount: day.income, quantity: 1 }))),
);
</script>

<template>
  <PageHeader
    title="収支"
    :crumbs="[{ label: '園長室', to: '/' }]"
    :subtitle="latest ? `${latest.day}日目までの直近${days.length}日` : undefined"
  />

  <QueryState
    :loading="query.loading.value"
    :error="query.error.value"
    :empty="days.length === 0"
    empty-text="まだ営業記録がありません"
    @retry="query.reload"
  >
    <section v-if="latest" class="kpis">
      <div class="card kpi">
        <p class="muted">前日の収入</p>
        <p class="figure plus">{{ yen(latest.income) }}</p>
        <p class="muted">来園 {{ latest.visitors.toLocaleString() }} 人</p>
      </div>
      <div class="card kpi">
        <p class="muted">前日の支出</p>
        <p class="figure minus">{{ yen(latest.cost) }}</p>
        <p v-if="previous" class="muted">前日比 {{ signed(latest.cost - previous.cost) }}</p>
      </div>
      <div class="card kpi">
        <p class="muted">前日の純益</p>
        <p class="figure" :class="latest.netIncome < 0 ? 'minus' : 'plus'">
          {{ signed(latest.netIncome) }}
        </p>
        <p class="muted">資金 {{ yen(latest.balance) }}</p>
      </div>
    </section>

    <h2 class="section-title">日別の内訳</h2>
    <div class="card table-card">
      <table class="data-table">
        <thead>
          <tr>
            <th>費目</th>
            <th v-for="day in days" :key="day.day" class="num">{{ day.day }}日目</th>
            <th class="num">前日比</th>
          </tr>
        </thead>
        <tbody>
          <tr class="group">
            <td>
              収入(入園料)
              <RouterLink to="/reputation" class="more">評判を見る ›</RouterLink>
            </td>
            <td v-for="day in days" :key="day.day" class="num">{{ yen(day.income) }}</td>
            <td class="num" :class="tone(incomeChange, 'income')">
              {{ incomeChange === undefined ? "—" : signed(incomeChange) }}
            </td>
          </tr>

          <template v-for="section in sections" :key="section.key">
            <tr class="group">
              <td>
                {{ section.label }}
                <RouterLink :to="section.to" class="more">{{ section.remedy }} ›</RouterLink>
              </td>
              <td v-for="(cell, i) in section.cells" :key="i" class="num">
                {{ cell ? yen(cell.amount) : "—" }}
              </td>
              <td class="num" :class="tone(change(section.cells), 'expense')">
                {{ change(section.cells) === undefined ? "—" : signed(change(section.cells)!) }}
              </td>
            </tr>
            <tr v-for="line in section.lines" :key="`${section.key}-${line.label}`" class="item">
              <td>{{ line.label }}</td>
              <td v-for="(cell, i) in line.cells" :key="i" class="num">
                <template v-if="cell && cell.quantity > 0">
                  {{ yen(cell.amount)
                  }}<small v-if="cell.quantity > 1" class="muted"> ×{{ cell.quantity }}</small>
                </template>
                <template v-else>—</template>
              </td>
              <td class="num" :class="tone(change(line.cells), 'expense')">
                {{ change(line.cells) ? signed(change(line.cells)!) : "" }}
              </td>
            </tr>
          </template>

          <tr class="total">
            <td>支出合計</td>
            <td v-for="day in days" :key="day.day" class="num minus">{{ yen(day.cost) }}</td>
            <td class="num">
              {{ previous ? signed(latest!.cost - previous.cost) : "—" }}
            </td>
          </tr>
          <tr class="total">
            <td>純益</td>
            <td
              v-for="day in days"
              :key="day.day"
              class="num"
              :class="day.netIncome < 0 ? 'minus' : 'plus'"
            >
              {{ signed(day.netIncome) }}
            </td>
            <td class="num">
              {{ previous ? signed(latest!.netIncome - previous.netIncome) : "—" }}
            </td>
          </tr>
          <tr>
            <td>資金</td>
            <td v-for="day in days" :key="day.day" class="num">{{ yen(day.balance) }}</td>
          </tr>
        </tbody>
      </table>
    </div>
    <p class="muted note">— は内訳を記録する前の日、または計上のなかった項目です。</p>
  </QueryState>
</template>

<style scoped>
.kpis {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
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

.data-table td:first-child {
  white-space: nowrap;
}

.more {
  margin-left: 8px;
  font-size: 0.75rem;
  font-weight: 700;
  color: var(--brand);
}

.more:hover {
  text-decoration: underline;
}

.group td {
  font-weight: 700;
  background: var(--surface-sunk);
}

.item td:first-child {
  padding-left: 32px;
  color: var(--ink-soft);
}

.total td {
  font-weight: 800;
  border-top: 2px solid var(--line);
}

.plus {
  color: var(--good);
}

.minus {
  color: var(--bad);
}

.note {
  margin-top: 8px;
  font-size: 0.8rem;
}
</style>
