<script setup lang="ts">
import { computed, ref, watch } from "vue";
import { graphql } from "../api/generated";
import type { Diagnosis, FoodCategory, Outlook } from "../api/generated/graphql";
import MeterBar from "../components/MeterBar.vue";
import PageHeader from "../components/PageHeader.vue";
import QueryState from "../components/QueryState.vue";
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
      occupants {
        id
      }
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
  (query.data.value?.enclosures ?? []).filter((e) => e.id !== animal.value?.enclosure?.id),
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
  <PageHeader :title="animal?.name ?? 'どうぶつ'" :crumbs="[{ label: '動物', to: '/animals' }]" />

  <QueryState
    :loading="query.loading.value"
    :error="query.error.value"
    :empty="!animal"
    @retry="query.reload"
  >
    <div v-if="animal" class="columns">
      <div>
        <h2 class="section-title">プロフィール</h2>
        <section class="card profile" :class="{ dead: !animal.alive }">
          <div class="portrait">
            {{
              animal.alive ? emojiOf(animal.species.nameJa, animal.species.taxonClass.label) : "🪦"
            }}
          </div>
          <div class="stack">
            <p class="species">{{ animal.species.nameJa }}</p>
            <div class="tags">
              <span class="badge">{{ animal.sex }}</span>
              <span class="badge">{{ animal.lifeStage }}・{{ animal.ageInDays }}日</span>
              <span class="badge"
                >{{ animal.species.taxonClass.label }}・{{ animal.species.diet }}</span
              >
              <span class="badge badge-warn">
                {{ animal.species.conservationCode }} {{ animal.species.conservationLabel }}
              </span>
            </div>
          </div>
        </section>

        <section v-if="!animal.alive" class="card memorial">
          <p>🕊️ {{ animal.causeOfDeath ?? "不明" }}により亡くなりました</p>
        </section>

        <section v-else class="card stack">
          <MeterBar label="体力" :value="animal.health" :max="animal.maxHealth" />
          <MeterBar label="空腹" :value="animal.hunger" :max="100" invert />
          <MeterBar label="栄養" :value="animal.nutrition" :max="100" />
          <MeterBar label="ストレス" :value="animal.stress" :max="100" invert />
          <ul v-if="animal.stressors.length > 0" class="stressors">
            <li v-for="stressor in animal.stressors" :key="stressor.cause" class="row">
              <span class="badge badge-warn">{{ stressorLabel(stressor.cause) }}</span>
              <span class="muted">+{{ stressor.amount }}/日</span>
              <span class="grow" />
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
          <p v-else-if="animal.stress > 0 && animal.enclosure" class="muted stressors">
            ストレスの原因はありません。毎日少しずつ下がります
          </p>
          <dl class="facts">
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
          </dl>
          <div class="tags">
            <span v-if="animal.starving" class="badge badge-bad">飢えている</span>
            <span v-if="animal.weak" class="badge badge-bad">衰弱</span>
            <span v-if="animal.illness" class="badge badge-bad"
              >🦠 {{ animal.illness }}{{ animal.contagious ? "(感染性)" : "" }}</span
            >
            <span v-if="animal.malnourished" class="badge badge-bad">栄養失調</span>
            <span v-if="animal.severelyStressed" class="badge badge-bad">強いストレス</span>
            <span v-else-if="animal.stressed" class="badge badge-warn">ストレス</span>
            <span v-if="animal.parents.length > 0" class="badge badge-good">園生まれ</span>
          </div>
          <RouterLink
            v-if="animal.enclosure"
            :to="`/enclosures/${animal.enclosure.id}`"
            class="row home"
          >
            <span>🌳</span>
            <span class="grow">{{ animal.enclosure.name }}</span>
            <span class="muted">›</span>
          </RouterLink>
          <p v-else class="muted">どのエリアにも収容されていません</p>
        </section>

        <template v-if="animal.alive">
          <h2 class="section-title">予後</h2>
          <section class="card stack">
            <template v-if="animal.prognosis">
              <div class="row">
                <span class="badge" :class="outlooks[animal.prognosis.outlook].tone">
                  {{ outlooks[animal.prognosis.outlook].label }}
                </span>
                <span class="grow">
                  {{
                    animal.prognosis.daysToDeath
                      ? `このままだと ${animal.prognosis.daysToDeath} 日以内に${animal.prognosis.causeOfDeath}する見込み`
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

      <div v-if="animal.alive">
        <h2 class="section-title">ごはん</h2>
        <form class="card stack" @submit.prevent="feed">
          <div class="row">
            <label class="field grow">
              飼育員
              <select v-model="keeperId" required>
                <option v-for="k in query.data.value?.keepers" :key="k.id" :value="k.id">
                  {{ k.name }}（残り{{ k.remainingMinutes }}分）
                </option>
              </select>
            </label>
            <label class="field grow">
              餌
              <select v-model="foodCode" required>
                <option v-for="f in edibleFoods" :key="f.code" :value="f.code">
                  {{ f.nameJa }}（満腹+{{ f.satiety }}）
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
              <option v-for="v in query.data.value?.veterinarians" :key="v.id" :value="v.id">
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
                  {{ e.name }}（{{ e.occupants.length }}/{{ e.capacity }}）
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
.stressors {
  display: grid;
  gap: 6px;
  margin: -4px 0 4px;
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
