import type { StressorCause } from "../api/generated/graphql";

type Target = "animal" | "enclosure" | "acquire";

const stressors: Record<StressorCause, { label: string; remedy: string; target: Target }> = {
  FILTH: { label: "汚れ", remedy: "清掃する", target: "enclosure" },
  BOREDOM: { label: "遊具切れ", remedy: "遊具を補充する", target: "enclosure" },
  CROWDING: { label: "過密", remedy: "別のエリアへ移す", target: "animal" },
  LONELINESS: { label: "孤独", remedy: "同じ種の仲間を迎える", target: "acquire" },
  MATERNAL_SEPARATION: { label: "母子分離", remedy: "母親と同じエリアへ移す", target: "animal" },
  SOCIAL_CONFLICT: { label: "序列争い", remedy: "別のエリアへ移す", target: "animal" },
  CLIMATE_DISCOMFORT: {
    label: "気温が合わない",
    remedy: "気温の合うエリアへ移す",
    target: "animal",
  },
  HUNGER: { label: "空腹", remedy: "給餌する", target: "animal" },
  ILLNESS: { label: "病気", remedy: "治療する", target: "animal" },
  MALNUTRITION: { label: "栄養失調", remedy: "食性に合う餌を与える", target: "animal" },
};

export function stressorLabel(cause: StressorCause) {
  return stressors[cause].label;
}

export function remedyOf(
  cause: StressorCause,
  animal: { id: string; enclosure?: { id: string } | null },
) {
  const { remedy, target } = stressors[cause];
  const to = {
    animal: `/animals/${animal.id}`,
    enclosure: animal.enclosure ? `/enclosures/${animal.enclosure.id}` : `/animals/${animal.id}`,
    acquire: "/animals",
  }[target];
  return { label: remedy, to };
}
