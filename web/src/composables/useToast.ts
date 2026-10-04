import { readonly, ref } from "vue";

export type Tone = "info" | "good" | "bad";
export type Toast = { id: number; message: string; tone: Tone };

const toasts = ref<Toast[]>([]);
let sequence = 0;

function dismiss(id: number) {
  toasts.value = toasts.value.filter((toast) => toast.id !== id);
}

function notify(message: string, tone: Tone = "info") {
  const id = ++sequence;
  toasts.value = [...toasts.value, { id, message, tone }];
  setTimeout(() => dismiss(id), 3200);
}

export function useToast() {
  return { toasts: readonly(toasts), notify, dismiss };
}
