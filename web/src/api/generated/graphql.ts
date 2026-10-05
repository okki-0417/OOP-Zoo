/* eslint-disable */
/** Internal type. DO NOT USE DIRECTLY. */
type Exact<T extends { [key: string]: unknown }> = { [K in keyof T]: T[K] };
/** Internal type. DO NOT USE DIRECTLY. */
export type Incremental<T> = T | { [P in keyof T]?: P extends ' $fragmentName' | '__typename' ? T[P] : never };
import type { DocumentTypeDecoration } from '@graphql-typed-document-node/core';
export type AlertKind =
  | 'BARREN'
  | 'CLIMATE'
  | 'DUE'
  | 'FILTHY'
  | 'GRAVE'
  | 'GUARDED'
  | 'HUNGRY'
  | 'INSOLVENT'
  | 'MALNOURISHED'
  | 'NO_KEEPER'
  | 'NO_VETERINARIAN'
  | 'OVERCROWDED'
  | 'SICK'
  | 'STARVING'
  | 'STRESSED'
  | 'UNASSIGNED'
  | 'UNHOUSED';

export type AlertSeverity =
  | 'CRITICAL'
  | 'NOTICE'
  | 'WARNING';

export type AlertSubject =
  | 'ANIMAL'
  | 'ENCLOSURE'
  | 'ZOO';

export type Diagnosis =
  | 'DEAD'
  | 'HEALTHY'
  | 'INJURED'
  | 'SICK';

export type FoodCategory =
  | 'FISH'
  | 'FRUIT'
  | 'INSECT'
  | 'MEAT'
  | 'PLANT'
  | 'SEED';

export type Outlook =
  | 'GOOD'
  | 'GRAVE'
  | 'GUARDED';

export type Sex =
  | 'FEMALE'
  | 'MALE';

export type AlertsQueryVariables = Exact<{ [key: string]: never; }>;


export type AlertsQuery = { alerts: Array<{ severity: AlertSeverity, kind: AlertKind, subjectType: AlertSubject, subjectId: string | null, subjectName: string, message: string }> };

export type AnimalQueryVariables = Exact<{
  id: string | number;
}>;


export type AnimalQuery = { animal: { id: string, name: string | null, alive: boolean, sex: string, lifeStage: string, ageInDays: number, causeOfDeath: string | null, health: number, maxHealth: number, hunger: number, nutrition: number, stress: number, daysUntilStarving: number, mealsToday: Array<FoodCategory>, dietCategories: Array<FoodCategory>, expecting: boolean, gestationDays: number | null, gestationPeriodDays: number | null, readyToDeliver: boolean, starving: boolean, weak: boolean, illness: string | null, contagious: boolean, malnourished: boolean, stressed: boolean, severelyStressed: boolean, parents: Array<{ id: string }>, species: { nameJa: string, diet: string, conservationCode: string, conservationLabel: string, taxonClass: { label: string } }, enclosure: { id: string, name: string } | null, prognosis: { outlook: Outlook, daysToDeath: number | null, causeOfDeath: string | null } | null } | null, keepers: Array<{ id: string, name: string, remainingMinutes: number }>, veterinarians: Array<{ id: string, name: string }>, foods: Array<{ code: string, nameJa: string, category: FoodCategory, satiety: number }>, enclosures: Array<{ id: string, name: string, capacity: number, occupants: Array<{ id: string }> }> };

export type FeedAnimalMutationVariables = Exact<{
  animalId: string | number;
  keeperId: string | number;
  foodCode: string;
}>;


export type FeedAnimalMutation = { feedAnimal: { name: string | null } };

export type ExamineAnimalMutationVariables = Exact<{
  animalId: string | number;
  veterinarianId: string | number;
}>;


export type ExamineAnimalMutation = { examineAnimal: { diagnosis: Diagnosis } };

export type TreatAnimalMutationVariables = Exact<{
  animalId: string | number;
  veterinarianId: string | number;
}>;


export type TreatAnimalMutation = { treatAnimal: { name: string | null } };

export type TransferAnimalMutationVariables = Exact<{
  animalId: string | number;
  enclosureId: string | number;
}>;


export type TransferAnimalMutation = { transferAnimal: { enclosure: { name: string } | null } };

export type RenameAnimalMutationVariables = Exact<{
  animalId: string | number;
  newName: string;
}>;


export type RenameAnimalMutation = { renameAnimal: { name: string | null } };

export type AnimalsQueryVariables = Exact<{ [key: string]: never; }>;


export type AnimalsQuery = { animals: Array<{ id: string, name: string | null, alive: boolean, health: number, maxHealth: number, ailing: boolean, hungry: boolean, fedToday: boolean, species: { nameJa: string }, enclosure: { id: string, name: string } | null }>, enclosures: Array<{ id: string, name: string, celsius: number, capacity: number, occupants: Array<{ id: string }>, occupancy: { full: boolean } }>, species: Array<{ code: string, nameJa: string, conservationLabel: string, taxonClass: { label: string } }> };

export type HouseAnimalMutationVariables = Exact<{
  enclosureId: string | number;
  animalId: string | number;
}>;


export type HouseAnimalMutation = { houseAnimal: { name: string } };

export type AcquireAnimalMutationVariables = Exact<{
  speciesCode: string;
  name: string;
  sex: Sex;
}>;


export type AcquireAnimalMutation = { acquireAnimal: { name: string | null, species: { nameJa: string } } };

export type EnclosureQueryVariables = Exact<{
  id: string | number;
}>;


export type EnclosureQuery = { enclosure: { id: string, name: string, celsius: number, climateControlled: boolean, capacity: number, cleanliness: number, enrichment: number, occupancy: { full: boolean }, occupants: Array<{ id: string, name: string | null, health: number, maxHealth: number, ailing: boolean, hungry: boolean, fedToday: boolean, species: { nameJa: string } }>, keepers: Array<{ id: string, name: string }> } | null, animals: Array<{ id: string, name: string | null, alive: boolean, enclosure: { id: string } | null, species: { nameJa: string } }>, keepers: Array<{ id: string, name: string, remainingMinutes: number, specialties: Array<{ label: string }> }> };

export type CleanEnclosureMutationVariables = Exact<{
  enclosureId: string | number;
  keeperId: string | number;
}>;


export type CleanEnclosureMutation = { cleanEnclosure: { name: string } };

export type EnrichEnclosureMutationVariables = Exact<{
  enclosureId: string | number;
  keeperId: string | number;
}>;


export type EnrichEnclosureMutation = { enrichEnclosure: { name: string } };

export type AssignKeeperMutationVariables = Exact<{
  enclosureId: string | number;
  keeperId: string | number;
}>;


export type AssignKeeperMutation = { assignKeeper: { id: string } };

export type DischargeKeeperMutationVariables = Exact<{
  enclosureId: string | number;
  keeperId: string | number;
}>;


export type DischargeKeeperMutation = { dischargeKeeper: { id: string } };

export type HouseOccupantMutationVariables = Exact<{
  enclosureId: string | number;
  animalId: string | number;
}>;


export type HouseOccupantMutation = { houseAnimal: { id: string } };

export type ReleaseAnimalMutationVariables = Exact<{
  animalId: string | number;
}>;


export type ReleaseAnimalMutation = { releaseAnimal: { id: string } };

export type EnclosuresQueryVariables = Exact<{ [key: string]: never; }>;


export type EnclosuresQuery = { enclosures: Array<{ id: string, name: string, celsius: number, climateControlled: boolean, capacity: number, cleanliness: number, enrichment: number, filthy: boolean, barren: boolean, occupants: Array<{ id: string }>, occupancy: { full: boolean }, keepers: Array<{ id: string, name: string }> }> };

export type AddEnclosureMutationVariables = Exact<{
  name: string;
  celsius: number;
  capacity: number;
  climateControlled?: boolean | null | undefined;
}>;


export type AddEnclosureMutation = { addEnclosure: { name: string } };

export type OfficeQueryVariables = Exact<{ [key: string]: never; }>;


export type OfficeQuery = { zoo: { balance: number, reputation: number, admissionFee: number }, operatings: Array<{ day: number, visitors: number, netIncome: number, deaths: number }>, enclosures: Array<{ id: string, name: string, soiled: boolean, dull: boolean, occupants: Array<{ id: string, name: string | null, alive: boolean, fedToday: boolean, species: { nameJa: string, threatened: boolean, conservationCode: string, conservationLabel: string } }> }>, animals: Array<{ id: string, name: string | null, alive: boolean, sick: boolean, causeOfDeath: string | null, species: { nameJa: string } }> };

export type OperateDayMutationVariables = Exact<{ [key: string]: never; }>;


export type OperateDayMutation = { operateDay: { visitors: number, income: number, cost: number, deaths: number, balance: number, outbreak: string | null } };

export type RunDaysMutationVariables = Exact<{
  days: number;
}>;


export type RunDaysMutation = { runDays: { days: number, totalDeaths: number } };

export type SetAdmissionFeeMutationVariables = Exact<{
  fee: number;
}>;


export type SetAdmissionFeeMutation = { setAdmissionFee: { admissionFee: number } };

export type ReputationQueryVariables = Exact<{ [key: string]: never; }>;


export type ReputationQuery = { zoo: { reputation: number, admissionFee: number, exhibitCondition: number, experience: number, expectedVisitors: number, expectedReputationChange: number }, animals: Array<{ id: string, name: string | null, alive: boolean, visibleCondition: number, stressed: boolean, sick: boolean, weak: boolean, species: { nameJa: string }, enclosure: { id: string, name: string } | null }>, operatings: Array<{ day: number, reputation: number, visitors: number, deaths: number, outbreak: string | null }> };

export type StaffQueryVariables = Exact<{ [key: string]: never; }>;


export type StaffQuery = { keepers: Array<{ id: string, name: string, workedMinutes: number, specialties: Array<{ label: string }>, enclosures: Array<{ id: string, name: string, occupants: Array<{ alive: boolean, fedToday: boolean }> }> }>, veterinarians: Array<{ id: string, name: string }>, taxonClasses: Array<{ code: string, label: string }> };

export type MakeRoundsMutationVariables = Exact<{
  keeperId: string | number;
}>;


export type MakeRoundsMutation = { makeRounds: { keeper: { id: string, name: string, remainingMinutes: number }, reports: Array<{ cleaned: boolean, enriched: boolean, enclosure: { id: string, name: string }, fed: Array<{ name: string | null }>, skipped: Array<{ subject: string, reason: string }> }> } };

export type HireKeeperMutationVariables = Exact<{
  name: string;
  specialties: Array<string> | string;
}>;


export type HireKeeperMutation = { hireKeeper: { name: string } };

export type HireVeterinarianMutationVariables = Exact<{
  name: string;
}>;


export type HireVeterinarianMutation = { hireVeterinarian: { name: string } };

export class TypedDocumentString<TResult, TVariables>
  extends String
  implements DocumentTypeDecoration<TResult, TVariables>
{
  __apiType?: NonNullable<DocumentTypeDecoration<TResult, TVariables>['__apiType']>;
  private value: string;
  public __meta__?: Record<string, any> | undefined;

  constructor(value: string, __meta__?: Record<string, any> | undefined) {
    super(value);
    this.value = value;
    this.__meta__ = __meta__;
  }

  override toString(): string & DocumentTypeDecoration<TResult, TVariables> {
    return this.value;
  }
}

export const AlertsDocument = new TypedDocumentString(`
    query Alerts {
  alerts {
    severity
    kind
    subjectType
    subjectId
    subjectName
    message
  }
}
    `) as unknown as TypedDocumentString<AlertsQuery, AlertsQueryVariables>;
export const AnimalDocument = new TypedDocumentString(`
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
    `) as unknown as TypedDocumentString<AnimalQuery, AnimalQueryVariables>;
export const FeedAnimalDocument = new TypedDocumentString(`
    mutation FeedAnimal($animalId: ID!, $keeperId: ID!, $foodCode: String!) {
  feedAnimal(animalId: $animalId, keeperId: $keeperId, foodCode: $foodCode) {
    name
  }
}
    `) as unknown as TypedDocumentString<FeedAnimalMutation, FeedAnimalMutationVariables>;
export const ExamineAnimalDocument = new TypedDocumentString(`
    mutation ExamineAnimal($animalId: ID!, $veterinarianId: ID!) {
  examineAnimal(animalId: $animalId, veterinarianId: $veterinarianId) {
    diagnosis
  }
}
    `) as unknown as TypedDocumentString<ExamineAnimalMutation, ExamineAnimalMutationVariables>;
export const TreatAnimalDocument = new TypedDocumentString(`
    mutation TreatAnimal($animalId: ID!, $veterinarianId: ID!) {
  treatAnimal(animalId: $animalId, veterinarianId: $veterinarianId) {
    name
  }
}
    `) as unknown as TypedDocumentString<TreatAnimalMutation, TreatAnimalMutationVariables>;
export const TransferAnimalDocument = new TypedDocumentString(`
    mutation TransferAnimal($animalId: ID!, $enclosureId: ID!) {
  transferAnimal(animalId: $animalId, enclosureId: $enclosureId) {
    enclosure {
      name
    }
  }
}
    `) as unknown as TypedDocumentString<TransferAnimalMutation, TransferAnimalMutationVariables>;
export const RenameAnimalDocument = new TypedDocumentString(`
    mutation RenameAnimal($animalId: ID!, $newName: String!) {
  renameAnimal(animalId: $animalId, newName: $newName) {
    name
  }
}
    `) as unknown as TypedDocumentString<RenameAnimalMutation, RenameAnimalMutationVariables>;
export const AnimalsDocument = new TypedDocumentString(`
    query Animals {
  animals {
    id
    name
    alive
    health
    maxHealth
    ailing
    hungry
    fedToday
    species {
      nameJa
    }
    enclosure {
      id
      name
    }
  }
  enclosures {
    id
    name
    celsius
    capacity
    occupants {
      id
    }
    occupancy {
      full
    }
  }
  species {
    code
    nameJa
    conservationLabel
    taxonClass {
      label
    }
  }
}
    `) as unknown as TypedDocumentString<AnimalsQuery, AnimalsQueryVariables>;
export const HouseAnimalDocument = new TypedDocumentString(`
    mutation HouseAnimal($enclosureId: ID!, $animalId: ID!) {
  houseAnimal(enclosureId: $enclosureId, animalId: $animalId) {
    name
  }
}
    `) as unknown as TypedDocumentString<HouseAnimalMutation, HouseAnimalMutationVariables>;
export const AcquireAnimalDocument = new TypedDocumentString(`
    mutation AcquireAnimal($speciesCode: String!, $name: String!, $sex: Sex!) {
  acquireAnimal(speciesCode: $speciesCode, name: $name, sex: $sex) {
    name
    species {
      nameJa
    }
  }
}
    `) as unknown as TypedDocumentString<AcquireAnimalMutation, AcquireAnimalMutationVariables>;
export const EnclosureDocument = new TypedDocumentString(`
    query Enclosure($id: ID!) {
  enclosure(id: $id) {
    id
    name
    celsius
    climateControlled
    capacity
    cleanliness
    enrichment
    occupancy {
      full
    }
    occupants {
      id
      name
      health
      maxHealth
      ailing
      hungry
      fedToday
      species {
        nameJa
      }
    }
    keepers {
      id
      name
    }
  }
  animals {
    id
    name
    alive
    enclosure {
      id
    }
    species {
      nameJa
    }
  }
  keepers {
    id
    name
    remainingMinutes
    specialties {
      label
    }
  }
}
    `) as unknown as TypedDocumentString<EnclosureQuery, EnclosureQueryVariables>;
export const CleanEnclosureDocument = new TypedDocumentString(`
    mutation CleanEnclosure($enclosureId: ID!, $keeperId: ID!) {
  cleanEnclosure(enclosureId: $enclosureId, keeperId: $keeperId) {
    name
  }
}
    `) as unknown as TypedDocumentString<CleanEnclosureMutation, CleanEnclosureMutationVariables>;
export const EnrichEnclosureDocument = new TypedDocumentString(`
    mutation EnrichEnclosure($enclosureId: ID!, $keeperId: ID!) {
  enrichEnclosure(enclosureId: $enclosureId, keeperId: $keeperId) {
    name
  }
}
    `) as unknown as TypedDocumentString<EnrichEnclosureMutation, EnrichEnclosureMutationVariables>;
export const AssignKeeperDocument = new TypedDocumentString(`
    mutation AssignKeeper($enclosureId: ID!, $keeperId: ID!) {
  assignKeeper(enclosureId: $enclosureId, keeperId: $keeperId) {
    id
  }
}
    `) as unknown as TypedDocumentString<AssignKeeperMutation, AssignKeeperMutationVariables>;
export const DischargeKeeperDocument = new TypedDocumentString(`
    mutation DischargeKeeper($enclosureId: ID!, $keeperId: ID!) {
  dischargeKeeper(enclosureId: $enclosureId, keeperId: $keeperId) {
    id
  }
}
    `) as unknown as TypedDocumentString<DischargeKeeperMutation, DischargeKeeperMutationVariables>;
export const HouseOccupantDocument = new TypedDocumentString(`
    mutation HouseOccupant($enclosureId: ID!, $animalId: ID!) {
  houseAnimal(enclosureId: $enclosureId, animalId: $animalId) {
    id
  }
}
    `) as unknown as TypedDocumentString<HouseOccupantMutation, HouseOccupantMutationVariables>;
export const ReleaseAnimalDocument = new TypedDocumentString(`
    mutation ReleaseAnimal($animalId: ID!) {
  releaseAnimal(animalId: $animalId) {
    id
  }
}
    `) as unknown as TypedDocumentString<ReleaseAnimalMutation, ReleaseAnimalMutationVariables>;
export const EnclosuresDocument = new TypedDocumentString(`
    query Enclosures {
  enclosures {
    id
    name
    celsius
    climateControlled
    capacity
    cleanliness
    enrichment
    filthy
    barren
    occupants {
      id
    }
    occupancy {
      full
    }
    keepers {
      id
      name
    }
  }
}
    `) as unknown as TypedDocumentString<EnclosuresQuery, EnclosuresQueryVariables>;
export const AddEnclosureDocument = new TypedDocumentString(`
    mutation AddEnclosure($name: String!, $celsius: Int!, $capacity: Int!, $climateControlled: Boolean) {
  addEnclosure(
    name: $name
    celsius: $celsius
    capacity: $capacity
    climateControlled: $climateControlled
  ) {
    name
  }
}
    `) as unknown as TypedDocumentString<AddEnclosureMutation, AddEnclosureMutationVariables>;
export const OfficeDocument = new TypedDocumentString(`
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
    `) as unknown as TypedDocumentString<OfficeQuery, OfficeQueryVariables>;
export const OperateDayDocument = new TypedDocumentString(`
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
    `) as unknown as TypedDocumentString<OperateDayMutation, OperateDayMutationVariables>;
export const RunDaysDocument = new TypedDocumentString(`
    mutation RunDays($days: Int!) {
  runDays(days: $days) {
    days
    totalDeaths
  }
}
    `) as unknown as TypedDocumentString<RunDaysMutation, RunDaysMutationVariables>;
export const SetAdmissionFeeDocument = new TypedDocumentString(`
    mutation SetAdmissionFee($fee: Int!) {
  setAdmissionFee(fee: $fee) {
    admissionFee
  }
}
    `) as unknown as TypedDocumentString<SetAdmissionFeeMutation, SetAdmissionFeeMutationVariables>;
export const ReputationDocument = new TypedDocumentString(`
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
    `) as unknown as TypedDocumentString<ReputationQuery, ReputationQueryVariables>;
export const StaffDocument = new TypedDocumentString(`
    query Staff {
  keepers {
    id
    name
    workedMinutes
    specialties {
      label
    }
    enclosures {
      id
      name
      occupants {
        alive
        fedToday
      }
    }
  }
  veterinarians {
    id
    name
  }
  taxonClasses {
    code
    label
  }
}
    `) as unknown as TypedDocumentString<StaffQuery, StaffQueryVariables>;
export const MakeRoundsDocument = new TypedDocumentString(`
    mutation MakeRounds($keeperId: ID!) {
  makeRounds(keeperId: $keeperId) {
    keeper {
      id
      name
      remainingMinutes
    }
    reports {
      enclosure {
        id
        name
      }
      fed {
        name
      }
      cleaned
      enriched
      skipped {
        subject
        reason
      }
    }
  }
}
    `) as unknown as TypedDocumentString<MakeRoundsMutation, MakeRoundsMutationVariables>;
export const HireKeeperDocument = new TypedDocumentString(`
    mutation HireKeeper($name: String!, $specialties: [String!]!) {
  hireKeeper(name: $name, specialties: $specialties) {
    name
  }
}
    `) as unknown as TypedDocumentString<HireKeeperMutation, HireKeeperMutationVariables>;
export const HireVeterinarianDocument = new TypedDocumentString(`
    mutation HireVeterinarian($name: String!) {
  hireVeterinarian(name: $name) {
    name
  }
}
    `) as unknown as TypedDocumentString<HireVeterinarianMutation, HireVeterinarianMutationVariables>;