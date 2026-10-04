import { ref, shallowRef } from "vue";

export function useQuery<T>(fetcher: () => Promise<T>) {
  const data = shallowRef<T>();
  const error = shallowRef<Error>();
  const loading = ref(false);

  async function reload() {
    loading.value = true;
    try {
      data.value = await fetcher();
      error.value = undefined;
    } catch (e) {
      error.value = e as Error;
    } finally {
      loading.value = false;
    }
  }

  void reload();

  return { data, error, loading, reload };
}
