// Display formatting for money, dates and labels, so every screen looks the same.
// Amounts arrive from the API as decimal strings ("81000.0").
const MONEY_LOCALES = { INR: "en-IN" };

// compact: "₹673.1Cr", "$295.3M" for headline figures.
export function formatMoney(amount, currency, { decimals = 0, compact = false } = {}) {
  if (amount === null || amount === undefined || amount === "") return "—";
  const options = compact
    ? { notation: "compact", maximumFractionDigits: 1 }
    : { minimumFractionDigits: decimals, maximumFractionDigits: decimals };
  return new Intl.NumberFormat(MONEY_LOCALES[currency] ?? "en-US", { style: "currency", currency, ...options })
    .format(Number(amount));
}

// Dates are calendar days; formatting in UTC stops them shifting by timezone.
export function formatDate(value) {
  if (!value) return "—";
  const [year, month, day] = value.slice(0, 10).split("-").map(Number);
  return new Date(Date.UTC(year, month - 1, day)).toLocaleDateString("en-GB", {
    day: "numeric",
    month: "short",
    year: "numeric",
    timeZone: "UTC",
  });
}

export function formatDateTime(value) {
  return new Date(value).toLocaleString("en-GB", {
    day: "numeric", month: "short", year: "numeric", hour: "2-digit", minute: "2-digit",
  });
}

export function todayIso() {
  const now = new Date();
  return new Date(now.getTime() - now.getTimezoneOffset() * 60_000).toISOString().slice(0, 10);
}

export function humanize(value = "") {
  const text = value.replaceAll("_", " ");
  return text.charAt(0).toUpperCase() + text.slice(1);
}

export function initials(name = "") {
  return name.split(" ").filter(Boolean).map((part) => part[0]).slice(0, 2).join("").toUpperCase();
}

export function flag(countryCode = "") {
  return countryCode.toUpperCase().replace(/./g, (char) => String.fromCodePoint(127397 + char.charCodeAt(0)));
}

export function pluralize(count, word) {
  return `${count.toLocaleString("en-US")} ${word}${count === 1 ? "" : "s"}`;
}
