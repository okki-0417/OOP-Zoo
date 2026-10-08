import { readonly, ref } from "vue";
import { ApiError } from "../api/client";
import { createDeveloperSession, deleteSession } from "../api/session";

const signedOut = ref(false);

function noticeUnauthenticated(error: unknown) {
  if (error instanceof ApiError && error.code === "Unauthenticated") signedOut.value = true;
}

async function signIn() {
  await createDeveloperSession();
  signedOut.value = false;
}

async function signOut() {
  await deleteSession();
  signedOut.value = true;
}

export function useSession() {
  return { signedOut: readonly(signedOut), noticeUnauthenticated, signIn, signOut };
}
