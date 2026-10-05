import { computed, effectScope } from "vue";
import { graphql } from "../api/generated";
import { useQuery } from "./useQuery";

const AlertsQuery = graphql(`
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
`);

let shared: ReturnType<typeof createAlerts> | undefined;

function createAlerts() {
  const query = useQuery(AlertsQuery);
  const alerts = computed(() => query.data.value?.alerts ?? []);
  const critical = computed(() => alerts.value.filter((alert) => alert.severity === "CRITICAL"));
  return { alerts, error: query.error, critical, reload: query.reload };
}

export function useAlerts() {
  shared ??= effectScope(true).run(createAlerts)!;
  return shared;
}
