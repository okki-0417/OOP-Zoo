import { ref } from "vue";
import { execute } from "../api/client";
import type { TypedDocumentString } from "../api/generated/graphql";
import { refetchActiveQueries } from "./useQuery";
import { useToast } from "./useToast";

export function useMutation() {
  const busy = ref(false);
  const { notify } = useToast();

  async function mutate<R, V>(
    document: TypedDocumentString<R, V>,
    variables: V,
    success?: (result: R) => string,
  ) {
    busy.value = true;
    try {
      const result = await execute(document, variables);
      if (success) notify(success(result), "good");
      void refetchActiveQueries();
      return result;
    } catch (e) {
      notify((e as Error).message, "bad");
      return undefined;
    } finally {
      busy.value = false;
    }
  }

  return { busy, mutate };
}
