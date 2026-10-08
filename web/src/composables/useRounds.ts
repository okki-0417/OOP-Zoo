import { readonly, shallowRef } from "vue";
import { graphql } from "../api/generated";
import type { MakeRoundsMutation } from "../api/generated/graphql";
import { useMutation } from "./useMutation";

type Rounds = MakeRoundsMutation["makeRounds"];

const MakeRoundsMutation = graphql(`
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
`);

const reports = shallowRef<Rounds[]>([]);

export function useRounds() {
  const { busy, mutate } = useMutation();

  async function makeRounds(keeperIds: string[]) {
    const done: Rounds[] = [];
    for (const keeperId of keeperIds) {
      const result = await mutate(MakeRoundsMutation, { keeperId });
      if (result) done.push(result.makeRounds);
    }
    reports.value = done;
  }

  return { reports: readonly(reports), busy, makeRounds };
}
