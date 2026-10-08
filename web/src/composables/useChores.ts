import { computed } from "vue";
import { graphql } from "../api/generated";
import { useQuery } from "./useQuery";

export type Chore = {
  kind: "feeding" | "treatment" | "cleaning" | "enrichment";
  label: string;
  items: { subject: { type: "animal" | "enclosure"; id: string; name: string }; done: boolean }[];
};

const ChoresQuery = graphql(`
  query Chores {
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
      }
    }
    animals {
      id
      name
      alive
      sick
    }
  }
`);

export function useChores() {
  const query = useQuery(ChoresQuery);

  const inhabited = computed(() =>
    (query.data.value?.enclosures ?? [])
      .map((enclosure) => ({ ...enclosure, residents: enclosure.occupants.filter((a) => a.alive) }))
      .filter((enclosure) => enclosure.residents.length > 0),
  );

  const chores = computed<Chore[]>(() => {
    const residents = inhabited.value.flatMap((enclosure) => enclosure.residents);
    const patients = (query.data.value?.animals ?? []).filter((a) => a.alive && a.sick);
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

  return { query, chores, unfinished };
}
