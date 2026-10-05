import { computed, readonly, shallowRef } from "vue";
import { api, unwrap, type Alert } from "../api/client";

const alerts = shallowRef<Alert[]>([]);
const error = shallowRef<Error>();
let loaded = false;

async function reload() {
  try {
    alerts.value = await unwrap(api.GET("/alerts"));
    error.value = undefined;
  } catch (e) {
    error.value = e as Error;
  }
}

const critical = computed(() => alerts.value.filter((alert) => alert.severity === "critical"));

export function useAlerts() {
  if (!loaded) {
    loaded = true;
    void reload();
  }
  return { alerts: readonly(alerts), error: readonly(error), critical, reload };
}
