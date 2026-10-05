// Histogram of a country's salaries: one bar per salary band, height = headcount.
// Plain CSS bars; no chart library needed for this.
import { useDistribution } from "@/lib/queries";
import { formatMoney } from "@/lib/format";
import Card, { CardHeader } from "@/components/ui/Card";

export default function DistributionChart({ country }) {
  const distribution = useDistribution(country.country_code);
  const bands = distribution.data?.bands;
  const peak = Math.max(1, ...(bands ?? []).map((band) => band.count));
  const money = (amount) => formatMoney(amount, country.currency, { compact: true });

  return (
    <Card className="min-w-0">
      <CardHeader title="Salary distribution" description={`People per annual salary band in ${country.country_name}`} />
      {!bands && <div className="m-5 h-52 animate-pulse rounded-xl bg-zinc-100" />}
      {bands?.length === 0 && <p className="p-5 text-sm text-zinc-400">No salaries yet.</p>}
      {bands?.length > 0 && (
        <div role="img" aria-label={`Salary distribution in ${country.country_name}`} className="p-5">
          <div className="flex h-48 items-end gap-1.5">
            {bands.map((band) => (
              <div key={band.from} className="group flex h-full flex-1 flex-col justify-end"
                title={`${money(band.from)} – ${money(band.to)}: ${band.count.toLocaleString("en-US")} people`}>
                <span className="tabular mb-1 text-center text-[10px] text-zinc-500">{band.count.toLocaleString("en-US")}</span>
                <div className="rounded-t-md bg-brand-500/80 transition-colors group-hover:bg-brand-600"
                  style={{ height: `${Math.max((band.count / peak) * 100, 1.5)}%` }} />
              </div>
            ))}
          </div>
          <div className="mt-2 flex justify-between text-[10px] text-zinc-400">
            <span>{money(bands[0].from)}</span>
            <span>{money(bands.at(-1).to)}</span>
          </div>
        </div>
      )}
    </Card>
  );
}
