import { ref } from "vue";
import { useToast } from "./useToast";

export function useCommand() {
  const busy = ref(false);
  const { notify } = useToast();

  async function run<T>(command: () => Promise<T>, success?: (result: T) => string) {
    busy.value = true;
    try {
      const result = await command();
      if (success) notify(success(result), "good");
      return result;
    } catch (e) {
      notify((e as Error).message, "bad");
      return undefined;
    } finally {
      busy.value = false;
    }
  }

  return { busy, run };
}
