import {
  getCurrentScope,
  onScopeDispose,
  ref,
  shallowRef,
  toValue,
  watch,
  type MaybeRefOrGetter,
} from "vue";
import { execute } from "../api/client";
import type { TypedDocumentString } from "../api/generated/graphql";

const active = new Set<() => Promise<void>>();

export function refetchActiveQueries() {
  return Promise.all([...active].map((reload) => reload()));
}

export function useQuery<R, V>(
  document: TypedDocumentString<R, V>,
  variables?: MaybeRefOrGetter<V>,
) {
  const data = shallowRef<R>();
  const error = shallowRef<Error>();
  const loading = ref(false);
  let latest = 0;

  async function reload() {
    const request = ++latest;
    loading.value = true;
    try {
      const result = await execute(document, toValue(variables));
      if (request !== latest) return;
      data.value = result;
      error.value = undefined;
    } catch (e) {
      if (request === latest) error.value = e as Error;
    } finally {
      if (request === latest) loading.value = false;
    }
  }

  watch(() => JSON.stringify(toValue(variables) ?? null), reload, { immediate: true });
  active.add(reload);
  if (getCurrentScope()) onScopeDispose(() => active.delete(reload));

  return { data, error, loading, reload };
}
