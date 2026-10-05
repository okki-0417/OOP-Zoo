/* eslint-disable */
import * as types from './graphql';



/**
 * Map of all GraphQL operations in the project.
 *
 * This map has several performance disadvantages:
 * 1. It is not tree-shakeable, so it will include all operations in the project.
 * 2. It is not minifiable, so the string of a GraphQL query will be multiple times inside the bundle.
 * 3. It does not support dead code elimination, so it will add unused operations.
 *
 * Therefore it is highly recommended to use the babel or swc plugin for production.
 * Learn more about it here: https://the-guild.dev/graphql/codegen/plugins/presets/preset-client#reducing-bundle-size
 */
type Documents = {
    "\n  query Alerts {\n    alerts {\n      severity\n      kind\n      subjectType\n      subjectId\n      subjectName\n      message\n    }\n  }\n": typeof types.AlertsDocument,
    "\n  query Animal($id: ID!) {\n    animal(id: $id) {\n      id\n      name\n      alive\n      sex\n      lifeStage\n      ageInDays\n      causeOfDeath\n      health\n      maxHealth\n      hunger\n      nutrition\n      stress\n      daysUntilStarving\n      mealsToday\n      dietCategories\n      expecting\n      gestationDays\n      gestationPeriodDays\n      readyToDeliver\n      starving\n      weak\n      illness\n      contagious\n      malnourished\n      stressed\n      severelyStressed\n      parents {\n        id\n      }\n      species {\n        nameJa\n        diet\n        conservationCode\n        conservationLabel\n        taxonClass {\n          label\n        }\n      }\n      enclosure {\n        id\n        name\n      }\n      prognosis {\n        outlook\n        daysToDeath\n        causeOfDeath\n      }\n    }\n    keepers {\n      id\n      name\n      remainingMinutes\n    }\n    veterinarians {\n      id\n      name\n    }\n    foods {\n      code\n      nameJa\n      category\n      satiety\n    }\n    enclosures {\n      id\n      name\n      capacity\n      occupants {\n        id\n      }\n    }\n  }\n": typeof types.AnimalDocument,
    "\n  mutation FeedAnimal($animalId: ID!, $keeperId: ID!, $foodCode: String!) {\n    feedAnimal(animalId: $animalId, keeperId: $keeperId, foodCode: $foodCode) {\n      name\n    }\n  }\n": typeof types.FeedAnimalDocument,
    "\n  mutation ExamineAnimal($animalId: ID!, $veterinarianId: ID!) {\n    examineAnimal(animalId: $animalId, veterinarianId: $veterinarianId) {\n      diagnosis\n    }\n  }\n": typeof types.ExamineAnimalDocument,
    "\n  mutation TreatAnimal($animalId: ID!, $veterinarianId: ID!) {\n    treatAnimal(animalId: $animalId, veterinarianId: $veterinarianId) {\n      name\n    }\n  }\n": typeof types.TreatAnimalDocument,
    "\n  mutation TransferAnimal($animalId: ID!, $enclosureId: ID!) {\n    transferAnimal(animalId: $animalId, enclosureId: $enclosureId) {\n      enclosure {\n        name\n      }\n    }\n  }\n": typeof types.TransferAnimalDocument,
    "\n  mutation RenameAnimal($animalId: ID!, $newName: String!) {\n    renameAnimal(animalId: $animalId, newName: $newName) {\n      name\n    }\n  }\n": typeof types.RenameAnimalDocument,
    "\n  query Animals {\n    animals {\n      id\n      name\n      alive\n      health\n      maxHealth\n      ailing\n      hungry\n      fedToday\n      species {\n        nameJa\n      }\n      enclosure {\n        id\n        name\n      }\n    }\n    enclosures {\n      id\n      name\n      celsius\n      capacity\n      occupants {\n        id\n      }\n      occupancy {\n        full\n      }\n    }\n    species {\n      code\n      nameJa\n      conservationLabel\n      taxonClass {\n        label\n      }\n    }\n  }\n": typeof types.AnimalsDocument,
    "\n  mutation HouseAnimal($enclosureId: ID!, $animalId: ID!) {\n    houseAnimal(enclosureId: $enclosureId, animalId: $animalId) {\n      name\n    }\n  }\n": typeof types.HouseAnimalDocument,
    "\n  mutation AcquireAnimal($speciesCode: String!, $name: String!, $sex: Sex!) {\n    acquireAnimal(speciesCode: $speciesCode, name: $name, sex: $sex) {\n      name\n      species {\n        nameJa\n      }\n    }\n  }\n": typeof types.AcquireAnimalDocument,
    "\n  query Enclosure($id: ID!) {\n    enclosure(id: $id) {\n      id\n      name\n      celsius\n      climateControlled\n      capacity\n      cleanliness\n      enrichment\n      occupancy {\n        full\n      }\n      occupants {\n        id\n        name\n        health\n        maxHealth\n        ailing\n        hungry\n        fedToday\n        species {\n          nameJa\n        }\n      }\n      keepers {\n        id\n        name\n      }\n    }\n    animals {\n      id\n      name\n      alive\n      enclosure {\n        id\n      }\n      species {\n        nameJa\n      }\n    }\n    keepers {\n      id\n      name\n      remainingMinutes\n      specialties {\n        label\n      }\n    }\n  }\n": typeof types.EnclosureDocument,
    "\n  mutation CleanEnclosure($enclosureId: ID!, $keeperId: ID!) {\n    cleanEnclosure(enclosureId: $enclosureId, keeperId: $keeperId) {\n      name\n    }\n  }\n": typeof types.CleanEnclosureDocument,
    "\n  mutation EnrichEnclosure($enclosureId: ID!, $keeperId: ID!) {\n    enrichEnclosure(enclosureId: $enclosureId, keeperId: $keeperId) {\n      name\n    }\n  }\n": typeof types.EnrichEnclosureDocument,
    "\n  mutation AssignKeeper($enclosureId: ID!, $keeperId: ID!) {\n    assignKeeper(enclosureId: $enclosureId, keeperId: $keeperId) {\n      id\n    }\n  }\n": typeof types.AssignKeeperDocument,
    "\n  mutation DischargeKeeper($enclosureId: ID!, $keeperId: ID!) {\n    dischargeKeeper(enclosureId: $enclosureId, keeperId: $keeperId) {\n      id\n    }\n  }\n": typeof types.DischargeKeeperDocument,
    "\n  mutation HouseOccupant($enclosureId: ID!, $animalId: ID!) {\n    houseAnimal(enclosureId: $enclosureId, animalId: $animalId) {\n      id\n    }\n  }\n": typeof types.HouseOccupantDocument,
    "\n  mutation ReleaseAnimal($animalId: ID!) {\n    releaseAnimal(animalId: $animalId) {\n      id\n    }\n  }\n": typeof types.ReleaseAnimalDocument,
    "\n  query Enclosures {\n    enclosures {\n      id\n      name\n      celsius\n      climateControlled\n      capacity\n      cleanliness\n      enrichment\n      filthy\n      barren\n      occupants {\n        id\n      }\n      occupancy {\n        full\n      }\n      keepers {\n        id\n        name\n      }\n    }\n  }\n": typeof types.EnclosuresDocument,
    "\n  mutation AddEnclosure(\n    $name: String!\n    $celsius: Int!\n    $capacity: Int!\n    $climateControlled: Boolean\n  ) {\n    addEnclosure(\n      name: $name\n      celsius: $celsius\n      capacity: $capacity\n      climateControlled: $climateControlled\n    ) {\n      name\n    }\n  }\n": typeof types.AddEnclosureDocument,
    "\n  query Office {\n    zoo {\n      balance\n      reputation\n      admissionFee\n    }\n    operatings {\n      day\n      visitors\n      netIncome\n      deaths\n    }\n    enclosures {\n      id\n      name\n      soiled\n      dull\n      occupants {\n        id\n        name\n        alive\n        fedToday\n        species {\n          nameJa\n          threatened\n          conservationCode\n          conservationLabel\n        }\n      }\n    }\n    animals {\n      id\n      name\n      alive\n      sick\n      causeOfDeath\n      species {\n        nameJa\n      }\n    }\n  }\n": typeof types.OfficeDocument,
    "\n  mutation OperateDay {\n    operateDay {\n      visitors\n      income\n      cost\n      deaths\n      balance\n      outbreak\n    }\n  }\n": typeof types.OperateDayDocument,
    "\n  mutation RunDays($days: Int!) {\n    runDays(days: $days) {\n      days\n      totalDeaths\n    }\n  }\n": typeof types.RunDaysDocument,
    "\n  mutation SetAdmissionFee($fee: Int!) {\n    setAdmissionFee(fee: $fee) {\n      admissionFee\n    }\n  }\n": typeof types.SetAdmissionFeeDocument,
    "\n  query Reputation {\n    zoo {\n      reputation\n      admissionFee\n      exhibitCondition\n      experience\n      expectedVisitors\n      expectedReputationChange\n    }\n    animals {\n      id\n      name\n      alive\n      visibleCondition\n      stressed\n      sick\n      weak\n      species {\n        nameJa\n      }\n      enclosure {\n        id\n        name\n      }\n    }\n    operatings {\n      deaths\n      outbreak\n    }\n  }\n": typeof types.ReputationDocument,
    "\n  query Staff {\n    keepers {\n      id\n      name\n      workedMinutes\n      specialties {\n        label\n      }\n      enclosures {\n        id\n        name\n        occupants {\n          alive\n          fedToday\n        }\n      }\n    }\n    veterinarians {\n      id\n      name\n    }\n    taxonClasses {\n      code\n      label\n    }\n  }\n": typeof types.StaffDocument,
    "\n  mutation MakeRounds($keeperId: ID!) {\n    makeRounds(keeperId: $keeperId) {\n      keeper {\n        id\n        name\n        remainingMinutes\n      }\n      reports {\n        enclosure {\n          id\n          name\n        }\n        fed {\n          name\n        }\n        cleaned\n        enriched\n        skipped {\n          subject\n          reason\n        }\n      }\n    }\n  }\n": typeof types.MakeRoundsDocument,
    "\n  mutation HireKeeper($name: String!, $specialties: [String!]!) {\n    hireKeeper(name: $name, specialties: $specialties) {\n      name\n    }\n  }\n": typeof types.HireKeeperDocument,
    "\n  mutation HireVeterinarian($name: String!) {\n    hireVeterinarian(name: $name) {\n      name\n    }\n  }\n": typeof types.HireVeterinarianDocument,
};
const documents: Documents = {
    "\n  query Alerts {\n    alerts {\n      severity\n      kind\n      subjectType\n      subjectId\n      subjectName\n      message\n    }\n  }\n": types.AlertsDocument,
    "\n  query Animal($id: ID!) {\n    animal(id: $id) {\n      id\n      name\n      alive\n      sex\n      lifeStage\n      ageInDays\n      causeOfDeath\n      health\n      maxHealth\n      hunger\n      nutrition\n      stress\n      daysUntilStarving\n      mealsToday\n      dietCategories\n      expecting\n      gestationDays\n      gestationPeriodDays\n      readyToDeliver\n      starving\n      weak\n      illness\n      contagious\n      malnourished\n      stressed\n      severelyStressed\n      parents {\n        id\n      }\n      species {\n        nameJa\n        diet\n        conservationCode\n        conservationLabel\n        taxonClass {\n          label\n        }\n      }\n      enclosure {\n        id\n        name\n      }\n      prognosis {\n        outlook\n        daysToDeath\n        causeOfDeath\n      }\n    }\n    keepers {\n      id\n      name\n      remainingMinutes\n    }\n    veterinarians {\n      id\n      name\n    }\n    foods {\n      code\n      nameJa\n      category\n      satiety\n    }\n    enclosures {\n      id\n      name\n      capacity\n      occupants {\n        id\n      }\n    }\n  }\n": types.AnimalDocument,
    "\n  mutation FeedAnimal($animalId: ID!, $keeperId: ID!, $foodCode: String!) {\n    feedAnimal(animalId: $animalId, keeperId: $keeperId, foodCode: $foodCode) {\n      name\n    }\n  }\n": types.FeedAnimalDocument,
    "\n  mutation ExamineAnimal($animalId: ID!, $veterinarianId: ID!) {\n    examineAnimal(animalId: $animalId, veterinarianId: $veterinarianId) {\n      diagnosis\n    }\n  }\n": types.ExamineAnimalDocument,
    "\n  mutation TreatAnimal($animalId: ID!, $veterinarianId: ID!) {\n    treatAnimal(animalId: $animalId, veterinarianId: $veterinarianId) {\n      name\n    }\n  }\n": types.TreatAnimalDocument,
    "\n  mutation TransferAnimal($animalId: ID!, $enclosureId: ID!) {\n    transferAnimal(animalId: $animalId, enclosureId: $enclosureId) {\n      enclosure {\n        name\n      }\n    }\n  }\n": types.TransferAnimalDocument,
    "\n  mutation RenameAnimal($animalId: ID!, $newName: String!) {\n    renameAnimal(animalId: $animalId, newName: $newName) {\n      name\n    }\n  }\n": types.RenameAnimalDocument,
    "\n  query Animals {\n    animals {\n      id\n      name\n      alive\n      health\n      maxHealth\n      ailing\n      hungry\n      fedToday\n      species {\n        nameJa\n      }\n      enclosure {\n        id\n        name\n      }\n    }\n    enclosures {\n      id\n      name\n      celsius\n      capacity\n      occupants {\n        id\n      }\n      occupancy {\n        full\n      }\n    }\n    species {\n      code\n      nameJa\n      conservationLabel\n      taxonClass {\n        label\n      }\n    }\n  }\n": types.AnimalsDocument,
    "\n  mutation HouseAnimal($enclosureId: ID!, $animalId: ID!) {\n    houseAnimal(enclosureId: $enclosureId, animalId: $animalId) {\n      name\n    }\n  }\n": types.HouseAnimalDocument,
    "\n  mutation AcquireAnimal($speciesCode: String!, $name: String!, $sex: Sex!) {\n    acquireAnimal(speciesCode: $speciesCode, name: $name, sex: $sex) {\n      name\n      species {\n        nameJa\n      }\n    }\n  }\n": types.AcquireAnimalDocument,
    "\n  query Enclosure($id: ID!) {\n    enclosure(id: $id) {\n      id\n      name\n      celsius\n      climateControlled\n      capacity\n      cleanliness\n      enrichment\n      occupancy {\n        full\n      }\n      occupants {\n        id\n        name\n        health\n        maxHealth\n        ailing\n        hungry\n        fedToday\n        species {\n          nameJa\n        }\n      }\n      keepers {\n        id\n        name\n      }\n    }\n    animals {\n      id\n      name\n      alive\n      enclosure {\n        id\n      }\n      species {\n        nameJa\n      }\n    }\n    keepers {\n      id\n      name\n      remainingMinutes\n      specialties {\n        label\n      }\n    }\n  }\n": types.EnclosureDocument,
    "\n  mutation CleanEnclosure($enclosureId: ID!, $keeperId: ID!) {\n    cleanEnclosure(enclosureId: $enclosureId, keeperId: $keeperId) {\n      name\n    }\n  }\n": types.CleanEnclosureDocument,
    "\n  mutation EnrichEnclosure($enclosureId: ID!, $keeperId: ID!) {\n    enrichEnclosure(enclosureId: $enclosureId, keeperId: $keeperId) {\n      name\n    }\n  }\n": types.EnrichEnclosureDocument,
    "\n  mutation AssignKeeper($enclosureId: ID!, $keeperId: ID!) {\n    assignKeeper(enclosureId: $enclosureId, keeperId: $keeperId) {\n      id\n    }\n  }\n": types.AssignKeeperDocument,
    "\n  mutation DischargeKeeper($enclosureId: ID!, $keeperId: ID!) {\n    dischargeKeeper(enclosureId: $enclosureId, keeperId: $keeperId) {\n      id\n    }\n  }\n": types.DischargeKeeperDocument,
    "\n  mutation HouseOccupant($enclosureId: ID!, $animalId: ID!) {\n    houseAnimal(enclosureId: $enclosureId, animalId: $animalId) {\n      id\n    }\n  }\n": types.HouseOccupantDocument,
    "\n  mutation ReleaseAnimal($animalId: ID!) {\n    releaseAnimal(animalId: $animalId) {\n      id\n    }\n  }\n": types.ReleaseAnimalDocument,
    "\n  query Enclosures {\n    enclosures {\n      id\n      name\n      celsius\n      climateControlled\n      capacity\n      cleanliness\n      enrichment\n      filthy\n      barren\n      occupants {\n        id\n      }\n      occupancy {\n        full\n      }\n      keepers {\n        id\n        name\n      }\n    }\n  }\n": types.EnclosuresDocument,
    "\n  mutation AddEnclosure(\n    $name: String!\n    $celsius: Int!\n    $capacity: Int!\n    $climateControlled: Boolean\n  ) {\n    addEnclosure(\n      name: $name\n      celsius: $celsius\n      capacity: $capacity\n      climateControlled: $climateControlled\n    ) {\n      name\n    }\n  }\n": types.AddEnclosureDocument,
    "\n  query Office {\n    zoo {\n      balance\n      reputation\n      admissionFee\n    }\n    operatings {\n      day\n      visitors\n      netIncome\n      deaths\n    }\n    enclosures {\n      id\n      name\n      soiled\n      dull\n      occupants {\n        id\n        name\n        alive\n        fedToday\n        species {\n          nameJa\n          threatened\n          conservationCode\n          conservationLabel\n        }\n      }\n    }\n    animals {\n      id\n      name\n      alive\n      sick\n      causeOfDeath\n      species {\n        nameJa\n      }\n    }\n  }\n": types.OfficeDocument,
    "\n  mutation OperateDay {\n    operateDay {\n      visitors\n      income\n      cost\n      deaths\n      balance\n      outbreak\n    }\n  }\n": types.OperateDayDocument,
    "\n  mutation RunDays($days: Int!) {\n    runDays(days: $days) {\n      days\n      totalDeaths\n    }\n  }\n": types.RunDaysDocument,
    "\n  mutation SetAdmissionFee($fee: Int!) {\n    setAdmissionFee(fee: $fee) {\n      admissionFee\n    }\n  }\n": types.SetAdmissionFeeDocument,
    "\n  query Reputation {\n    zoo {\n      reputation\n      admissionFee\n      exhibitCondition\n      experience\n      expectedVisitors\n      expectedReputationChange\n    }\n    animals {\n      id\n      name\n      alive\n      visibleCondition\n      stressed\n      sick\n      weak\n      species {\n        nameJa\n      }\n      enclosure {\n        id\n        name\n      }\n    }\n    operatings {\n      deaths\n      outbreak\n    }\n  }\n": types.ReputationDocument,
    "\n  query Staff {\n    keepers {\n      id\n      name\n      workedMinutes\n      specialties {\n        label\n      }\n      enclosures {\n        id\n        name\n        occupants {\n          alive\n          fedToday\n        }\n      }\n    }\n    veterinarians {\n      id\n      name\n    }\n    taxonClasses {\n      code\n      label\n    }\n  }\n": types.StaffDocument,
    "\n  mutation MakeRounds($keeperId: ID!) {\n    makeRounds(keeperId: $keeperId) {\n      keeper {\n        id\n        name\n        remainingMinutes\n      }\n      reports {\n        enclosure {\n          id\n          name\n        }\n        fed {\n          name\n        }\n        cleaned\n        enriched\n        skipped {\n          subject\n          reason\n        }\n      }\n    }\n  }\n": types.MakeRoundsDocument,
    "\n  mutation HireKeeper($name: String!, $specialties: [String!]!) {\n    hireKeeper(name: $name, specialties: $specialties) {\n      name\n    }\n  }\n": types.HireKeeperDocument,
    "\n  mutation HireVeterinarian($name: String!) {\n    hireVeterinarian(name: $name) {\n      name\n    }\n  }\n": types.HireVeterinarianDocument,
};

/**
 * The graphql function is used to parse GraphQL queries into a document that can be used by GraphQL clients.
 */
export function graphql(source: "\n  query Alerts {\n    alerts {\n      severity\n      kind\n      subjectType\n      subjectId\n      subjectName\n      message\n    }\n  }\n"): typeof import('./graphql').AlertsDocument;
/**
 * The graphql function is used to parse GraphQL queries into a document that can be used by GraphQL clients.
 */
export function graphql(source: "\n  query Animal($id: ID!) {\n    animal(id: $id) {\n      id\n      name\n      alive\n      sex\n      lifeStage\n      ageInDays\n      causeOfDeath\n      health\n      maxHealth\n      hunger\n      nutrition\n      stress\n      daysUntilStarving\n      mealsToday\n      dietCategories\n      expecting\n      gestationDays\n      gestationPeriodDays\n      readyToDeliver\n      starving\n      weak\n      illness\n      contagious\n      malnourished\n      stressed\n      severelyStressed\n      parents {\n        id\n      }\n      species {\n        nameJa\n        diet\n        conservationCode\n        conservationLabel\n        taxonClass {\n          label\n        }\n      }\n      enclosure {\n        id\n        name\n      }\n      prognosis {\n        outlook\n        daysToDeath\n        causeOfDeath\n      }\n    }\n    keepers {\n      id\n      name\n      remainingMinutes\n    }\n    veterinarians {\n      id\n      name\n    }\n    foods {\n      code\n      nameJa\n      category\n      satiety\n    }\n    enclosures {\n      id\n      name\n      capacity\n      occupants {\n        id\n      }\n    }\n  }\n"): typeof import('./graphql').AnimalDocument;
/**
 * The graphql function is used to parse GraphQL queries into a document that can be used by GraphQL clients.
 */
export function graphql(source: "\n  mutation FeedAnimal($animalId: ID!, $keeperId: ID!, $foodCode: String!) {\n    feedAnimal(animalId: $animalId, keeperId: $keeperId, foodCode: $foodCode) {\n      name\n    }\n  }\n"): typeof import('./graphql').FeedAnimalDocument;
/**
 * The graphql function is used to parse GraphQL queries into a document that can be used by GraphQL clients.
 */
export function graphql(source: "\n  mutation ExamineAnimal($animalId: ID!, $veterinarianId: ID!) {\n    examineAnimal(animalId: $animalId, veterinarianId: $veterinarianId) {\n      diagnosis\n    }\n  }\n"): typeof import('./graphql').ExamineAnimalDocument;
/**
 * The graphql function is used to parse GraphQL queries into a document that can be used by GraphQL clients.
 */
export function graphql(source: "\n  mutation TreatAnimal($animalId: ID!, $veterinarianId: ID!) {\n    treatAnimal(animalId: $animalId, veterinarianId: $veterinarianId) {\n      name\n    }\n  }\n"): typeof import('./graphql').TreatAnimalDocument;
/**
 * The graphql function is used to parse GraphQL queries into a document that can be used by GraphQL clients.
 */
export function graphql(source: "\n  mutation TransferAnimal($animalId: ID!, $enclosureId: ID!) {\n    transferAnimal(animalId: $animalId, enclosureId: $enclosureId) {\n      enclosure {\n        name\n      }\n    }\n  }\n"): typeof import('./graphql').TransferAnimalDocument;
/**
 * The graphql function is used to parse GraphQL queries into a document that can be used by GraphQL clients.
 */
export function graphql(source: "\n  mutation RenameAnimal($animalId: ID!, $newName: String!) {\n    renameAnimal(animalId: $animalId, newName: $newName) {\n      name\n    }\n  }\n"): typeof import('./graphql').RenameAnimalDocument;
/**
 * The graphql function is used to parse GraphQL queries into a document that can be used by GraphQL clients.
 */
export function graphql(source: "\n  query Animals {\n    animals {\n      id\n      name\n      alive\n      health\n      maxHealth\n      ailing\n      hungry\n      fedToday\n      species {\n        nameJa\n      }\n      enclosure {\n        id\n        name\n      }\n    }\n    enclosures {\n      id\n      name\n      celsius\n      capacity\n      occupants {\n        id\n      }\n      occupancy {\n        full\n      }\n    }\n    species {\n      code\n      nameJa\n      conservationLabel\n      taxonClass {\n        label\n      }\n    }\n  }\n"): typeof import('./graphql').AnimalsDocument;
/**
 * The graphql function is used to parse GraphQL queries into a document that can be used by GraphQL clients.
 */
export function graphql(source: "\n  mutation HouseAnimal($enclosureId: ID!, $animalId: ID!) {\n    houseAnimal(enclosureId: $enclosureId, animalId: $animalId) {\n      name\n    }\n  }\n"): typeof import('./graphql').HouseAnimalDocument;
/**
 * The graphql function is used to parse GraphQL queries into a document that can be used by GraphQL clients.
 */
export function graphql(source: "\n  mutation AcquireAnimal($speciesCode: String!, $name: String!, $sex: Sex!) {\n    acquireAnimal(speciesCode: $speciesCode, name: $name, sex: $sex) {\n      name\n      species {\n        nameJa\n      }\n    }\n  }\n"): typeof import('./graphql').AcquireAnimalDocument;
/**
 * The graphql function is used to parse GraphQL queries into a document that can be used by GraphQL clients.
 */
export function graphql(source: "\n  query Enclosure($id: ID!) {\n    enclosure(id: $id) {\n      id\n      name\n      celsius\n      climateControlled\n      capacity\n      cleanliness\n      enrichment\n      occupancy {\n        full\n      }\n      occupants {\n        id\n        name\n        health\n        maxHealth\n        ailing\n        hungry\n        fedToday\n        species {\n          nameJa\n        }\n      }\n      keepers {\n        id\n        name\n      }\n    }\n    animals {\n      id\n      name\n      alive\n      enclosure {\n        id\n      }\n      species {\n        nameJa\n      }\n    }\n    keepers {\n      id\n      name\n      remainingMinutes\n      specialties {\n        label\n      }\n    }\n  }\n"): typeof import('./graphql').EnclosureDocument;
/**
 * The graphql function is used to parse GraphQL queries into a document that can be used by GraphQL clients.
 */
export function graphql(source: "\n  mutation CleanEnclosure($enclosureId: ID!, $keeperId: ID!) {\n    cleanEnclosure(enclosureId: $enclosureId, keeperId: $keeperId) {\n      name\n    }\n  }\n"): typeof import('./graphql').CleanEnclosureDocument;
/**
 * The graphql function is used to parse GraphQL queries into a document that can be used by GraphQL clients.
 */
export function graphql(source: "\n  mutation EnrichEnclosure($enclosureId: ID!, $keeperId: ID!) {\n    enrichEnclosure(enclosureId: $enclosureId, keeperId: $keeperId) {\n      name\n    }\n  }\n"): typeof import('./graphql').EnrichEnclosureDocument;
/**
 * The graphql function is used to parse GraphQL queries into a document that can be used by GraphQL clients.
 */
export function graphql(source: "\n  mutation AssignKeeper($enclosureId: ID!, $keeperId: ID!) {\n    assignKeeper(enclosureId: $enclosureId, keeperId: $keeperId) {\n      id\n    }\n  }\n"): typeof import('./graphql').AssignKeeperDocument;
/**
 * The graphql function is used to parse GraphQL queries into a document that can be used by GraphQL clients.
 */
export function graphql(source: "\n  mutation DischargeKeeper($enclosureId: ID!, $keeperId: ID!) {\n    dischargeKeeper(enclosureId: $enclosureId, keeperId: $keeperId) {\n      id\n    }\n  }\n"): typeof import('./graphql').DischargeKeeperDocument;
/**
 * The graphql function is used to parse GraphQL queries into a document that can be used by GraphQL clients.
 */
export function graphql(source: "\n  mutation HouseOccupant($enclosureId: ID!, $animalId: ID!) {\n    houseAnimal(enclosureId: $enclosureId, animalId: $animalId) {\n      id\n    }\n  }\n"): typeof import('./graphql').HouseOccupantDocument;
/**
 * The graphql function is used to parse GraphQL queries into a document that can be used by GraphQL clients.
 */
export function graphql(source: "\n  mutation ReleaseAnimal($animalId: ID!) {\n    releaseAnimal(animalId: $animalId) {\n      id\n    }\n  }\n"): typeof import('./graphql').ReleaseAnimalDocument;
/**
 * The graphql function is used to parse GraphQL queries into a document that can be used by GraphQL clients.
 */
export function graphql(source: "\n  query Enclosures {\n    enclosures {\n      id\n      name\n      celsius\n      climateControlled\n      capacity\n      cleanliness\n      enrichment\n      filthy\n      barren\n      occupants {\n        id\n      }\n      occupancy {\n        full\n      }\n      keepers {\n        id\n        name\n      }\n    }\n  }\n"): typeof import('./graphql').EnclosuresDocument;
/**
 * The graphql function is used to parse GraphQL queries into a document that can be used by GraphQL clients.
 */
export function graphql(source: "\n  mutation AddEnclosure(\n    $name: String!\n    $celsius: Int!\n    $capacity: Int!\n    $climateControlled: Boolean\n  ) {\n    addEnclosure(\n      name: $name\n      celsius: $celsius\n      capacity: $capacity\n      climateControlled: $climateControlled\n    ) {\n      name\n    }\n  }\n"): typeof import('./graphql').AddEnclosureDocument;
/**
 * The graphql function is used to parse GraphQL queries into a document that can be used by GraphQL clients.
 */
export function graphql(source: "\n  query Office {\n    zoo {\n      balance\n      reputation\n      admissionFee\n    }\n    operatings {\n      day\n      visitors\n      netIncome\n      deaths\n    }\n    enclosures {\n      id\n      name\n      soiled\n      dull\n      occupants {\n        id\n        name\n        alive\n        fedToday\n        species {\n          nameJa\n          threatened\n          conservationCode\n          conservationLabel\n        }\n      }\n    }\n    animals {\n      id\n      name\n      alive\n      sick\n      causeOfDeath\n      species {\n        nameJa\n      }\n    }\n  }\n"): typeof import('./graphql').OfficeDocument;
/**
 * The graphql function is used to parse GraphQL queries into a document that can be used by GraphQL clients.
 */
export function graphql(source: "\n  mutation OperateDay {\n    operateDay {\n      visitors\n      income\n      cost\n      deaths\n      balance\n      outbreak\n    }\n  }\n"): typeof import('./graphql').OperateDayDocument;
/**
 * The graphql function is used to parse GraphQL queries into a document that can be used by GraphQL clients.
 */
export function graphql(source: "\n  mutation RunDays($days: Int!) {\n    runDays(days: $days) {\n      days\n      totalDeaths\n    }\n  }\n"): typeof import('./graphql').RunDaysDocument;
/**
 * The graphql function is used to parse GraphQL queries into a document that can be used by GraphQL clients.
 */
export function graphql(source: "\n  mutation SetAdmissionFee($fee: Int!) {\n    setAdmissionFee(fee: $fee) {\n      admissionFee\n    }\n  }\n"): typeof import('./graphql').SetAdmissionFeeDocument;
/**
 * The graphql function is used to parse GraphQL queries into a document that can be used by GraphQL clients.
 */
export function graphql(source: "\n  query Reputation {\n    zoo {\n      reputation\n      admissionFee\n      exhibitCondition\n      experience\n      expectedVisitors\n      expectedReputationChange\n    }\n    animals {\n      id\n      name\n      alive\n      visibleCondition\n      stressed\n      sick\n      weak\n      species {\n        nameJa\n      }\n      enclosure {\n        id\n        name\n      }\n    }\n    operatings {\n      deaths\n      outbreak\n    }\n  }\n"): typeof import('./graphql').ReputationDocument;
/**
 * The graphql function is used to parse GraphQL queries into a document that can be used by GraphQL clients.
 */
export function graphql(source: "\n  query Staff {\n    keepers {\n      id\n      name\n      workedMinutes\n      specialties {\n        label\n      }\n      enclosures {\n        id\n        name\n        occupants {\n          alive\n          fedToday\n        }\n      }\n    }\n    veterinarians {\n      id\n      name\n    }\n    taxonClasses {\n      code\n      label\n    }\n  }\n"): typeof import('./graphql').StaffDocument;
/**
 * The graphql function is used to parse GraphQL queries into a document that can be used by GraphQL clients.
 */
export function graphql(source: "\n  mutation MakeRounds($keeperId: ID!) {\n    makeRounds(keeperId: $keeperId) {\n      keeper {\n        id\n        name\n        remainingMinutes\n      }\n      reports {\n        enclosure {\n          id\n          name\n        }\n        fed {\n          name\n        }\n        cleaned\n        enriched\n        skipped {\n          subject\n          reason\n        }\n      }\n    }\n  }\n"): typeof import('./graphql').MakeRoundsDocument;
/**
 * The graphql function is used to parse GraphQL queries into a document that can be used by GraphQL clients.
 */
export function graphql(source: "\n  mutation HireKeeper($name: String!, $specialties: [String!]!) {\n    hireKeeper(name: $name, specialties: $specialties) {\n      name\n    }\n  }\n"): typeof import('./graphql').HireKeeperDocument;
/**
 * The graphql function is used to parse GraphQL queries into a document that can be used by GraphQL clients.
 */
export function graphql(source: "\n  mutation HireVeterinarian($name: String!) {\n    hireVeterinarian(name: $name) {\n      name\n    }\n  }\n"): typeof import('./graphql').HireVeterinarianDocument;


export function graphql(source: string) {
  return (documents as any)[source] ?? {};
}
