// One card per country: headcount, annual cost and median in local currency.
// Clicking a card selects the country for the drill-down below.
import clsx from "clsx";
import { flag, formatMoney } from "@/lib/format";

function Figure({ label, value }) {
  return (
    <div>
      <p className="text-[11px] text-zinc-400">{label}</p>
      <p className="tabular text-sm font-semibold text-zinc-900">{value}</p>
    </div>
  );
}

export default function CountryCards({ countries, selected, onSelect }) {
  if (!countries) {
    return (
      <div className="grid gap-3 sm:grid-cols-2 lg:grid-cols-3">
        {[1, 2, 3].map((i) => <div key={i} className="h-[120px] animate-pulse rounded-2xl bg-zinc-100" />)}
      </div>
    );
  }

  return (
    <div className="grid gap-3 sm:grid-cols-2 lg:grid-cols-3">
      {countries.map((country) => {
        const active = country.country_code === selected;
        const money = (amount) => formatMoney(amount, country.currency, { compact: true });
        return (
          <button
            key={country.country_code}
            type="button"
            aria-pressed={active}
            onClick={() => onSelect(country.country_code)}
            className={clsx(
              "rounded-2xl bg-white p-4 text-left shadow-card ring-1 transition",
              active ? "ring-2 ring-brand-500" : "ring-zinc-200/70 hover:ring-zinc-300",
            )}
          >
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-2">
                <span className="text-lg leading-none">{flag(country.country_code)}</span>
                <span className="text-sm font-medium text-zinc-900">{country.country_name}</span>
              </div>
              <span className="text-xs text-zinc-400">{country.currency}</span>
            </div>
            <div className="mt-4 grid grid-cols-3 gap-2">
              <Figure label="People" value={country.headcount.toLocaleString("en-US")} />
              <Figure label="Annual cost" value={money(country.total_cost)} />
              <Figure label="Median" value={money(country.median)} />
            </div>
          </button>
        );
      })}
    </div>
  );
}
