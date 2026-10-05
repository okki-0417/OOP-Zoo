<script setup lang="ts">
import { computed, ref, watch } from "vue";
import { api, unwrap, type Animal, type AnimalOutlook, type ExamineResult } from "../api/client";
import MeterBar from "../components/MeterBar.vue";
import PageHeader from "../components/PageHeader.vue";
import QueryState from "../components/QueryState.vue";
import { useCommand } from "../composables/useCommand";
import { useQuery } from "../composables/useQuery";
import { emojiOf } from "../lib/emoji";

const props = defineProps<{ id: string }>();

const path = computed(() => ({ path: { animal_id: props.id } }));
const animal = useQuery(() => unwrap(api.GET("/animals/{animal_id}", { params: path.value })));
const keepers = useQuery(() => unwrap(api.GET("/keepers")));
const veterinarians = useQuery(() => unwrap(api.GET("/veterinarians")));
const foods = useQuery(() => unwrap(api.GET("/foods")));
const enclosures = useQuery(() => unwrap(api.GET("/enclosures")));
const prognosis = useQuery(() =>
  unwrap(api.GET("/animals/{animal_id}/prognosis", { params: path.value })),
);
const { busy, run } = useCommand();

const outlooks: Record<NonNullable<AnimalOutlook["outlook"]>, { label: string; tone: string }> = {
  good: { label: "良好", tone: "badge-good" },
  guarded: { label: "要注意", tone: "badge-warn" },
  grave: { label: "危篤", tone: "badge-bad" },
};

const foodCategories: Record<string, string> = {
  meat: "肉",
  fish: "魚",
  insect: "昆虫",
  plant: "植物",
  fruit: "果実",
  seed: "種子",
};

const keeperId = ref("");
const foodCode = ref("");
const veterinarianId = ref("");
const enclosureId = ref("");
const newName = ref("");

watch(keepers.data, (list) => (keeperId.value ||= list?.[0]?.id ?? ""));
watch(foods.data, (list) => (foodCode.value ||= list?.[0]?.key ?? ""));
watch(veterinarians.data, (list) => (veterinarianId.value ||= list?.[0]?.id ?? ""));

const transferTargets = computed(() =>
  (enclosures.data.value ?? []).filter((e) => e.id !== animal.data.value?.enclosure_id),
);

const diagnosis: Record<ExamineResult["result"], string> = {
  healthy: "健康です",
  sick: "病気にかかっています",
  injured: "けがをしています",
  dead: "すでに亡くなっています",
};

function show(updated: Animal | undefined) {
  if (!updated) return;
  animal.data.value = updated;
  void prognosis.reload();
}

async function feed() {
  show(
    await run(
      () =>
        unwrap(
          api.POST("/animals/{animal_id}/feedings", {
            params: path.value,
            body: { keeper_id: keeperId.value, food_code: foodCode.value },
          }),
        ),
      (a) => `${a.name}にごはんをあげました`,
    ),
  );
}

async function examine() {
  await run(
    () =>
      unwrap(
        api.POST("/animals/{animal_id}/examinations", {
          params: path.value,
          body: { veterinarian_id: veterinarianId.value },
        }),
      ),
    (r) => `診察結果: ${diagnosis[r.result]}`,
  );
}

async function treat() {
  show(
    await run(
      () =>
        unwrap(
          api.POST("/animals/{animal_id}/treatments", {
            params: path.value,
            body: { veterinarian_id: veterinarianId.value },
          }),
        ),
      (a) => `${a.name}を治療しました`,
    ),
  );
}

async function transfer() {
  show(
    await run(
      () =>
        unwrap(
          api.POST("/animals/{animal_id}/transfer", {
            params: path.value,
            body: { enclosure_id: enclosureId.value },
          }),
        ),
      (a) => `${a.enclosure_name ?? "新しいエリア"}へ移しました`,
    ),
  );
  void enclosures.reload();
}

async function rename() {
  show(
    await run(
      () =>
        unwrap(
          api.PATCH("/animals/{animal_id}/name", {
            params: path.value,
            body: { new_name: newName.value },
          }),
        ),
      (a) => `「${a.name}」に改名しました`,
    ),
  );
  newName.value = "";
}
</script>

<template>
  <PageHeader :title="animal.data.value?.name ?? 'どうぶつ'" back="/animals" />

  <QueryState
    :loading="animal.loading.value"
    :error="animal.error.value"
    :empty="!animal.data.value"
    @retry="animal.reload"
  >
    <div v-if="animal.data.value" class="columns">
      <div>
        <h2 class="section-title">プロフィール</h2>
        <section class="card profile" :class="{ dead: !animal.data.value.alive }">
          <div class="portrait">
            {{
              animal.data.value.alive
                ? emojiOf(animal.data.value.species, animal.data.value.taxon_class)
                : "🪦"
            }}
          </div>
          <div class="stack">
            <p class="species">{{ animal.data.value.species }}</p>
            <div class="tags">
              <span class="badge">{{ animal.data.value.sex }}</span>
              <span class="badge"
                >{{ animal.data.value.life_stage }}・{{ animal.data.value.age_in_days }}日</span
              >
              <span class="badge"
                >{{ animal.data.value.taxon_class }}・{{ animal.data.value.diet }}</span
              >
              <span class="badge badge-warn">
                {{ animal.data.value.conservation_code }} {{ animal.data.value.conservation_label }}
              </span>
            </div>
          </div>
        </section>

        <section v-if="!animal.data.value.alive" class="card memorial">
          <p>🕊️ {{ animal.data.value.cause ?? "不明" }}により亡くなりました</p>
        </section>

        <section v-else class="card stack">
          <MeterBar
            label="体力"
            :value="animal.data.value.health"
            :max="animal.data.value.max_health"
          />
          <MeterBar label="空腹" :value="animal.data.value.hunger" :max="100" invert />
          <MeterBar label="栄養" :value="animal.data.value.nutrition" :max="100" />
          <MeterBar label="ストレス" :value="animal.data.value.stress" :max="100" invert />
          <dl class="facts">
            <dt>飢餓まで</dt>
            <dd>給餌が途絶えると {{ animal.data.value.days_until_starving }} 日</dd>
            <dt>今日の食事</dt>
            <dd>
              {{
                animal.data.value.meals_today.length
                  ? animal.data.value.meals_today.map((c) => foodCategories[c] ?? c).join("・")
                  : "まだ食べていません"
              }}
            </dd>
            <template v-if="animal.data.value.expecting">
              <dt>妊娠</dt>
              <dd>
                {{ animal.data.value.gestation_days }} /
                {{ animal.data.value.gestation_period_days }} 日
                <span v-if="animal.data.value.ready_to_deliver" class="badge badge-good"
                  >出産の時期</span
                >
              </dd>
            </template>
          </dl>
          <div class="tags">
            <span v-if="animal.data.value.starving" class="badge badge-bad">飢えている</span>
            <span v-if="animal.data.value.weak" class="badge badge-bad">衰弱</span>
            <span v-if="animal.data.value.illness" class="badge badge-bad"
              >🦠 {{ animal.data.value.illness
              }}{{ animal.data.value.contagious ? "(感染性)" : "" }}</span
            >
            <span v-if="animal.data.value.malnourished" class="badge badge-bad">栄養失調</span>
            <span v-if="animal.data.value.severely_stressed" class="badge badge-bad"
              >強いストレス</span
            >
            <span v-else-if="animal.data.value.stressed" class="badge badge-warn">ストレス</span>
            <span v-if="animal.data.value.parents > 0" class="badge badge-good">園生まれ</span>
          </div>
          <RouterLink
            v-if="animal.data.value.enclosure_id"
            :to="`/enclosures/${animal.data.value.enclosure_id}`"
            class="row home"
          >
            <span>🌳</span>
            <span class="grow">{{ animal.data.value.enclosure_name }}</span>
            <span class="muted">›</span>
          </RouterLink>
          <p v-else class="muted">どのエリアにも収容されていません</p>
        </section>

        <template v-if="animal.data.value.alive">
          <h2 class="section-title">予後</h2>
          <section class="card stack">
            <template v-if="prognosis.data.value?.housed && prognosis.data.value.outlook">
              <div class="row">
                <span class="badge" :class="outlooks[prognosis.data.value.outlook].tone">
                  {{ outlooks[prognosis.data.value.outlook].label }}
                </span>
                <span class="grow">
                  {{
                    prognosis.data.value.days_to_death
                      ? `このままだと ${prognosis.data.value.days_to_death} 日以内に${prognosis.data.value.cause_of_death}する見込み`
                      : "30日以内に命に関わる見込みはありません"
                  }}
                </span>
              </div>
              <p class="muted">給餌を続け、治療や環境の改善をしなかった場合の見通しです</p>
            </template>
            <p v-else class="muted">収容されていないため、日々の経過も予後もありません</p>
          </section>
        </template>
      </div>

      <div v-if="animal.data.value.alive">
        <h2 class="section-title">ごはん</h2>
        <form class="card stack" @submit.prevent="feed">
          <div class="row">
            <label class="field grow">
              飼育員
              <select v-model="keeperId" required>
                <option v-for="k in keepers.data.value" :key="k.id" :value="k.id">
                  {{ k.name }}
                </option>
              </select>
            </label>
            <label class="field grow">
              餌
              <select v-model="foodCode" required>
                <option v-for="f in foods.data.value" :key="f.key" :value="f.key">
                  {{ f.name_ja }}（満腹+{{ f.satiety }}）
                </option>
              </select>
            </label>
          </div>
          <button class="btn btn-primary" :disabled="busy || !keeperId">🍖 ごはんをあげる</button>
        </form>

        <h2 class="section-title">診療</h2>
        <section class="card stack">
          <label class="field">
            獣医
            <select v-model="veterinarianId">
              <option v-for="v in veterinarians.data.value" :key="v.id" :value="v.id">
                {{ v.name }}
              </option>
            </select>
          </label>
          <div class="row">
            <button class="btn btn-block" :disabled="busy || !veterinarianId" @click="examine">
              🩺 診察
            </button>
            <button class="btn btn-block" :disabled="busy || !veterinarianId" @click="treat">
              💊 治療
            </button>
          </div>
        </section>

        <h2 class="section-title">移送・改名</h2>
        <section class="card stack">
          <form class="row bottom" @submit.prevent="transfer">
            <label class="field grow">
              移送先
              <select v-model="enclosureId" required>
                <option value="" disabled>選んでください</option>
                <option v-for="e in transferTargets" :key="e.id" :value="e.id">
                  {{ e.name }}（{{ e.population }}/{{ e.capacity }}）
                </option>
              </select>
            </label>
            <button class="btn" :disabled="busy || !enclosureId">移送</button>
          </form>
          <form class="row bottom" @submit.prevent="rename">
            <label class="field grow">
              新しい名前
              <input v-model.trim="newName" required maxlength="20" />
            </label>
            <button class="btn" :disabled="busy || !newName">改名</button>
          </form>
        </section>
      </div>
    </div>
  </QueryState>
</template>

<style scoped>
.profile {
  display: flex;
  gap: 16px;
  align-items: center;
  margin-bottom: 10px;
}

.profile.dead {
  filter: grayscale(1);
}

.portrait {
  flex: none;
  display: grid;
  place-items: center;
  width: 88px;
  height: 88px;
  border-radius: 24px;
  font-size: 3.2rem;
  background:
    radial-gradient(
      circle at 30% 30%,
      color-mix(in srgb, var(--accent) 30%, transparent),
      transparent 70%
    ),
    var(--surface-sunk);
}

.species {
  font-weight: 800;
  font-size: 1.1rem;
}

.tags {
  display: flex;
  flex-wrap: wrap;
  gap: 6px;
}

.tags:empty {
  display: none;
}

.memorial {
  text-align: center;
  color: var(--ink-soft);
}

.home {
  padding: 10px 12px;
  border-radius: 12px;
  background: var(--surface-sunk);
  font-weight: 700;
}

.bottom {
  align-items: end;
}

.facts {
  display: grid;
  grid-template-columns: auto 1fr;
  gap: 4px 16px;
  margin: 0;
  font-size: 0.85rem;
}

.facts dt {
  color: var(--ink-soft);
}

.facts dd {
  margin: 0;
  font-weight: 700;
}
</style>
