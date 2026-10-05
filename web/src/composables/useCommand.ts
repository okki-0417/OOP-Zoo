import { ref } from "vue";
import { useAlerts } from "./useAlerts";
import { useToast } from "./useToast";

export function useCommand() {
  const busy = ref(false);
  const { notify } = useToast();
  const { reload: reloadAlerts } = useAlerts();

  async function run<T>(command: () => Promise<T>, success?: (result: T) => string) {
    busy.value = true;
    try {
      const result = await command();
      if (success) notify(success(result), "good");
      void reloadAlerts();
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
