import { flag, formatDate, formatMoney, humanize, initials } from "./format";

describe("formatMoney", () => {
  it("formats API decimal strings with the currency", () => {
    expect(formatMoney("81000.0", "GBP")).toBe("£81,000");
    expect(formatMoney("1234.5", "USD", { decimals: 2 })).toBe("$1,234.50");
  });

  it("uses Indian digit grouping for rupees", () => {
    expect(formatMoney("1250000", "INR")).toBe("₹12,50,000");
  });

  it("shortens large amounts in compact mode, in each currency's style", () => {
    expect(formatMoney("6730797000.0", "INR", { compact: true })).toBe("₹673.1Cr");
    expect(formatMoney("1332500.0", "INR", { compact: true })).toBe("₹13.3L");
    expect(formatMoney("295329000.0", "USD", { compact: true })).toBe("$295.3M");
  });

  it("shows a dash for missing amounts", () => {
    expect(formatMoney(null, "USD")).toBe("—");
    expect(formatMoney(undefined, "USD")).toBe("—");
  });
});

describe("formatDate", () => {
  it("formats ISO dates without timezone drift", () => {
    expect(formatDate("2026-01-01")).toBe("1 Jan 2026");
    expect(formatDate("2026-10-04T15:30:00.000Z")).toBe("4 Oct 2026");
  });

  it("shows a dash for missing dates", () => {
    expect(formatDate(null)).toBe("—");
  });
});

describe("small helpers", () => {
  it("humanizes snake_case", () => {
    expect(humanize("on_leave")).toBe("On leave");
    expect(humanize("percentage_of_gross")).toBe("Percentage of gross");
  });

  it("builds initials from a name", () => {
    expect(initials("Asha Verma")).toBe("AV");
    expect(initials("Cher")).toBe("C");
    expect(initials(undefined)).toBe("");
  });

  it("turns a country code into its flag", () => {
    expect(flag("IN")).toBe("🇮🇳");
    expect(flag("gb")).toBe("🇬🇧");
  });
});
