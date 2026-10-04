const yenFormat = new Intl.NumberFormat("ja-JP", { style: "currency", currency: "JPY" });

export const yen = (amount: number) => yenFormat.format(amount);
