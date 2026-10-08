<script setup lang="ts">
import { computed, ref, watch } from "vue";
import { graphql } from "../api/generated";
import type { Diagnosis, FoodCategory, Outlook } from "../api/generated/graphql";
import MeterBar from "../components/MeterBar.vue";
import QueryState from "../components/QueryState.vue";
import SideSheet from "../components/SideSheet.vue";
import { useMutation } from "../composables/useMutation";
import { useQuery } from "../composables/useQuery";
import { emojiOf } from "../lib/emoji";
import { remedyOf, stressorLabel } from "../lib/stressors";

const props = defineProps<{ id: string }>();

const AnimalQuery = graphql(`
  query Animal($id: ID!) {
    animal(id: $id) {
      id
      name
      alive
      sex
      lifeStage
      ageInDays
      causeOfDeath
      health
      maxHealth
      hunger
      nutrition
      stress
      daysUntilStarving
      mealsToday
      dietCategories
      expecting
      gestationDays
      gestationPeriodDays
      readyToDeliver
      starving
      weak
      illness
      contagious
      malnourished
      stressed
      severelyStressed
      stressors {
        cause
        amount
      }
      parents {
        id
      }
      species {
        nameJa
        diet
        conservationCode
        conservationLabel
        taxonClass {
          label
        }
      }
      enclosure {
        id
        name
      }
      prognosis {
        outlook
        daysToDeath
        causeOfDeath
      }
    }
    keepers {
      id
      name
      remainingMinutes
    }
    veterinarians {
      id
      name
    }
    foods {
      code
      nameJa
      category
      satiety
    }
    enclosures {
      id
      name
      capacity
      celsius
      occupants {
        id
      }
      occupancy {
        full
      }
    }
  }
`);

const HouseAnimalMutation = graphql(`
  mutation HouseAnimal($enclosureId: ID!, $animalId: ID!) {
    houseAnimal(enclosureId: $enclosureId, animalId: $animalId) {
      name
    }
  }
`);

const FeedAnimalMutation = graphql(`
  mutation FeedAnimal($animalId: ID!, $keeperId: ID!, $foodCode: String!) {
    feedAnimal(animalId: $animalId, keeperId: $keeperId, foodCode: $foodCode) {
      name
    }
  }
`);

const ExamineAnimalMutation = graphql(`
  mutation ExamineAnimal($animalId: ID!, $veterinarianId: ID!) {
    examineAnimal(animalId: $animalId, veterinarianId: $veterinarianId) {
      diagnosis
    }
  }
`);

const TreatAnimalMutation = graphql(`
  mutation TreatAnimal($animalId: ID!, $veterinarianId: ID!) {
    treatAnimal(animalId: $animalId, veterinarianId: $veterinarianId) {
      name
    }
  }
`);

const TransferAnimalMutation = graphql(`
  mutation TransferAnimal($animalId: ID!, $enclosureId: ID!) {
    transferAnimal(animalId: $animalId, enclosureId: $enclosureId) {
      enclosure {
        name
      }
    }
  }
`);

const RenameAnimalMutation = graphql(`
  mutation RenameAnimal($animalId: ID!, $newName: String!) {
    renameAnimal(animalId: $animalId, newName: $newName) {
      name
    }
  }
`);

const query = useQuery(AnimalQuery, () => ({ id: props.id }));
const animal = computed(() => query.data.value?.animal ?? undefined);
const { busy, mutate } = useMutation();

const outlooks: Record<Outlook, { label: string; tone: string }> = {
  GOOD: { label: "良好", tone: "badge-good" },
  GUARDED: { label: "要注意", tone: "badge-warn" },
  GRAVE: { label: "危篤", tone: "badge-bad" },
};

const foodCategories: Record<FoodCategory, string> = {
  MEAT: "肉",
  FISH: "魚",
  INSECT: "昆虫",
  PLANT: "植物",
  FRUIT: "果実",
  SEED: "種子",
};

const keeperId = ref("");
const foodCode = ref("");
const veterinarianId = ref("");
const enclosureId = ref("");
const newName = ref("");

type Tab = "status" | "care" | "facts";
const tabs: { key: Tab; label: string }[] = [
  { key: "status", label: "状態" },
  { key: "care", label: "世話" },
  { key: "facts", label: "くわしく" },
];
const tab = ref<Tab>("status");

watch(
  () => query.data.value?.keepers,
  (list) => (keeperId.value ||= list?.[0]?.id ?? ""),
);
const edibleFoods = computed(() =>
  (query.data.value?.foods ?? []).filter((food) =>
    animal.value?.dietCategories.includes(food.category),
  ),
);

watch(edibleFoods, (list) => {
  if (!list.some((food) => food.code === foodCode.value)) foodCode.value = list[0]?.code ?? "";
});
watch(
  () => query.data.value?.veterinarians,
  (list) => (veterinarianId.value ||= list?.[0]?.id ?? ""),
);

const transferTargets = computed(() =>
  (query.data.value?.enclosures ?? []).filter(
    (e) => e.id !== animal.value?.enclosure?.id && !e.occupancy.full,
  ),
);

const diagnosis: Record<Diagnosis, string> = {
  HEALTHY: "健康です",
  SICK: "病気にかかっています",
  INJURED: "けがをしています",
  DEAD: "すでに亡くなっています",
};

async function feed() {
  await mutate(
    FeedAnimalMutation,
    { animalId: props.id, keeperId: keeperId.value, foodCode: foodCode.value },
    ({ feedAnimal }) => `${feedAnimal.name}にごはんをあげました`,
  );
}

async function examine() {
  await mutate(
    ExamineAnimalMutation,
    { animalId: props.id, veterinarianId: veterinarianId.value },
    ({ examineAnimal }) => `診察結果: ${diagnosis[examineAnimal.diagnosis]}`,
  );
}

async function treat() {
  await mutate(
    TreatAnimalMutation,
    { animalId: props.id, veterinarianId: veterinarianId.value },
    ({ treatAnimal }) => `${treatAnimal.name}を治療しました`,
  );
}

async function transfer() {
  await mutate(
    TransferAnimalMutation,
    { animalId: props.id, enclosureId: enclosureId.value },
    ({ transferAnimal }) => `${transferAnimal.enclosure?.name ?? "新しいエリア"}へ移しました`,
  );
}

async function house() {
  await mutate(
    HouseAnimalMutation,
    { animalId: props.id, enclosureId: enclosureId.value },
    ({ houseAnimal }) => `${animal.value?.name ?? ""}を${houseAnimal.name}に収容しました`,
  );
}

async function rename() {
  const renamed = await mutate(
    RenameAnimalMutation,
    { animalId: props.id, newName: newName.value },
    ({ renameAnimal }) => `「${renameAnimal.name}」に改名しました`,
  );
  if (renamed) newName.value = "";
}
</script>

<template>
  <SideSheet :title="animal?.name ?? 'どうぶつ'" close-to="/animals">
    <QueryState
      :loading="query.loading.value"
      :error="query.error.value"
      :empty="!animal"
      @retry="query.reload"
    >
      <template v-if="animal">
        <section class="profile" :class="{ dead: !animal.alive }">
          <span class="portrait">{{
            animal.alive ? emojiOf(animal.species.nameJa, animal.species.taxonClass.label) : "🪦"
          }}</span>
          <div class="grow">
            <p class="species">{{ animal.species.nameJa }}</p>
            <div class="tags">
              <span class="badge">{{ animal.sex }}</span>
              <span class="badge">{{ animal.lifeStage }}・{{ animal.ageInDays }}日</span>
              <span v-if="animal.parents.length > 0" class="badge badge-good">園生まれ</span>
            </div>
          </div>
          <RouterLink
            v-if="animal.enclosure"
            :to="`/enclosures/${animal.enclosure.id}`"
            class="home"
          >
            🌳 {{ animal.enclosure.name }} ›
          </RouterLink>
        </section>

        <p v-if="!animal.alive" class="memorial">
          🕊️ {{ animal.causeOfDeath ?? "不明" }}により亡くなりました
        </p>

        <template v-else>
          <div class="segmented" role="tablist">
            <button
              v-for="t in tabs"
              :key="t.key"
              type="button"
              role="tab"
              :aria-pressed="tab === t.key"
              @click="tab = t.key"
            >
              {{ t.label }}
            </button>
          </div>

          <template v-if="tab === 'status'">
            <div class="meters">
              <MeterBar label="体力" :value="animal.health" :max="animal.maxHealth" />
              <MeterBar label="空腹" :value="animal.hunger" :max="100" invert />
              <MeterBar label="栄養" :value="animal.nutrition" :max="100" />
              <MeterBar label="ストレス" :value="animal.stress" :max="100" invert />
            </div>

            <div class="tags">
              <button
                v-if="!animal.enclosure"
                type="button"
                class="badge badge-warn"
                @click="tab = 'care'"
              >
                未収容 › 収容する
              </button>
              <span v-if="animal.starving" class="badge badge-bad">飢えている</span>
              <span v-if="animal.weak" class="badge badge-bad">衰弱</span>
              <span v-if="animal.illness" class="badge badge-bad"
                >🦠 {{ animal.illness }}{{ animal.contagious ? "(感染性)" : "" }}</span
              >
              <span v-if="animal.malnourished" class="badge badge-bad">栄養失調</span>
              <span v-if="animal.severelyStressed" class="badge badge-bad">強いストレス</span>
              <span v-else-if="animal.stressed" class="badge badge-warn">ストレス</span>
              <span
                v-if="animal.prognosis"
                class="badge"
                :class="outlooks[animal.prognosis.outlook].tone"
              >
                予後 {{ outlooks[animal.prognosis.outlook].label }}
              </span>
            </div>

            <p v-if="animal.prognosis?.daysToDeath" class="warning">
              このままだと {{ animal.prognosis.daysToDeath }} 日以内に{{
                animal.prognosis.causeOfDeath
              }}する見込み
            </p>

            <details v-if="animal.stressors.length > 0" class="fold">
              <summary>
                <span class="grow">😣 ストレスの原因</span>
                <span class="badge badge-warn">{{ animal.stressors.length }}</span>
              </summary>
              <ul class="stressors">
                <li v-for="stressor in animal.stressors" :key="stressor.cause" class="row">
                  <span class="grow">{{ stressorLabel(stressor.cause) }}</span>
                  <span class="muted">+{{ stressor.amount }}/日</span>
                  <RouterLink
                    v-if="remedyOf(stressor.cause, animal).to !== `/animals/${animal.id}`"
                    :to="remedyOf(stressor.cause, animal).to"
                    class="remedy"
                  >
                    {{ remedyOf(stressor.cause, animal).label }} ›
                  </RouterLink>
                  <span v-else class="muted">{{ remedyOf(stressor.cause, animal).label }}</span>
                </li>
              </ul>
            </details>
          </template>

          <div v-else-if="tab === 'care'" class="care">
            <form v-if="!animal.enclosure" class="action-row" @submit.prevent="house">
              <span class="verb">🌳 収容</span>
              <select v-model="enclosureId" class="inline-select grow" required aria-label="収容先">
                <option value="" disabled>収容先…</option>
                <option v-for="e in transferTargets" :key="e.id" :value="e.id">
                  {{ e.name }}（{{ e.occupants.length }}/{{ e.capacity }}・{{ e.celsius }}℃）
                </option>
              </select>
              <button class="btn btn-primary btn-small" :disabled="busy || !enclosureId">
                収容
              </button>
            </form>

            <form class="action-row" @submit.prevent="feed">
              <span class="verb">🍖 ごはん</span>
              <select v-model="keeperId" class="inline-select grow" required aria-label="飼育員">
                <option v-for="k in query.data.value?.keepers" :key="k.id" :value="k.id">
                  {{ k.name }}（{{ k.remainingMinutes }}分）
                </option>
              </select>
              <select v-model="foodCode" class="inline-select grow" required aria-label="餌">
                <option v-for="f in edibleFoods" :key="f.code" :value="f.code">
                  {{ f.nameJa }}（+{{ f.satiety }}）
                </option>
              </select>
              <button class="btn btn-primary btn-small" :disabled="busy || !keeperId">
                あげる
              </button>
            </form>

            <div class="action-row">
              <span class="verb">🩺 診療</span>
              <select v-model="veterinarianId" class="inline-select grow" aria-label="獣医">
                <option v-for="v in query.data.value?.veterinarians" :key="v.id" :value="v.id">
                  {{ v.name }}
                </option>
              </select>
              <button class="btn btn-small" :disabled="busy || !veterinarianId" @click="examine">
                診察
              </button>
              <button class="btn btn-small" :disabled="busy || !veterinarianId" @click="treat">
                治療
              </button>
            </div>

            <form v-if="animal.enclosure" class="action-row" @submit.prevent="transfer">
              <span class="verb">🚚 移送</span>
              <select v-model="enclosureId" class="inline-select grow" required aria-label="移送先">
                <option value="" disabled>移送先…</option>
                <option v-for="e in transferTargets" :key="e.id" :value="e.id">
                  {{ e.name }}（{{ e.occupants.length }}/{{ e.capacity }}）
                </option>
              </select>
              <button class="btn btn-small" :disabled="busy || !enclosureId">移送</button>
            </form>

            <form class="action-row" @submit.prevent="rename">
              <span class="verb">✏️ 改名</span>
              <input
                v-model.trim="newName"
                class="inline-select grow"
                required
                maxlength="20"
                placeholder="新しい名前"
                aria-label="新しい名前"
              />
              <button class="btn btn-small" :disabled="busy || !newName">改名</button>
            </form>
          </div>

          <dl v-else class="facts">
            <dt>分類</dt>
            <dd>{{ animal.species.taxonClass.label }}・{{ animal.species.diet }}</dd>
            <dt>保全</dt>
            <dd>{{ animal.species.conservationCode }} {{ animal.species.conservationLabel }}</dd>
            <dt>飢餓まで</dt>
            <dd>給餌が途絶えると {{ animal.daysUntilStarving }} 日</dd>
            <dt>今日の食事</dt>
            <dd>
              {{
                animal.mealsToday.length
                  ? animal.mealsToday.map((c) => foodCategories[c]).join("・")
                  : "まだ食べていません"
              }}
            </dd>
            <template v-if="animal.expecting">
              <dt>妊娠</dt>
              <dd>
                {{ animal.gestationDays }} / {{ animal.gestationPeriodDays }} 日
                <span v-if="animal.readyToDeliver" class="badge badge-good">出産の時期</span>
              </dd>
            </template>
            <dt>予後</dt>
            <dd>
              {{
                !animal.prognosis
                  ? "収容されていないため、日々の経過も予後もありません"
                  : animal.prognosis.daysToDeath
                    ? `${animal.prognosis.daysToDeath} 日以内に${animal.prognosis.causeOfDeath}する見込み`
                    : "30日以内に命に関わる見込みはありません"
              }}
            </dd>
          </dl>
        </template>
      </template>
    </QueryState>
  </SideSheet>
</template>

<style scoped>
.profile {
  display: flex;
  gap: 10px;
  align-items: center;
}

.profile.dead {
  filter: grayscale(1);
}

.portrait {
  flex: none;
  display: grid;
  place-items: center;
  width: 48px;
  height: 48px;
  border-radius: 14px;
  font-size: 1.8rem;
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
}

.tags {
  display: flex;
  flex-wrap: wrap;
  gap: 4px;
}

.tags:empty {
  display: none;
}

.home {
  font-size: 0.8rem;
  font-weight: 700;
  white-space: nowrap;
  color: var(--brand);
}

button.badge {
  border: none;
  cursor: pointer;
}

.warning {
  font-size: 0.8rem;
  font-weight: 700;
  color: var(--bad);
}

.care {
  display: grid;
  gap: 8px;
}

.memorial {
  text-align: center;
  color: var(--ink-soft);
}

.meters {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 8px 16px;
}

.stressors {
  display: grid;
  gap: 6px;
  padding: 0;
  list-style: none;
  font-size: 0.85rem;
}

.remedy {
  font-weight: 700;
  color: var(--brand);
}

.remedy:hover {
  text-decoration: underline;
}
</style>
