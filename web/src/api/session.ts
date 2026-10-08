export async function createDeveloperSession() {
  const response = await globalThis.fetch("/dev/session", { method: "POST" });
  if (!response.ok) throw new Error(`ログインできませんでした(${response.status})`);
}

export async function deleteSession() {
  await globalThis.fetch("/session", { method: "DELETE" });
}
