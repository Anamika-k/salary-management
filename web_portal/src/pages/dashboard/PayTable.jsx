// Pay figures per group (department or designation) for one country:
// headcount, annual cost with a share-of-cost bar, median and min-max range.
import { useState } from "react";
import clsx from "clsx";
import { formatMoney } from "@/lib/format";
import Card, { CardHeader } from "@/components/ui/Card";

export default function PayTable({ title, description, rows, currency, limit, className }) {
  const [showAll, setShowAll] = useState(false);
  const money = (amount) => formatMoney(amount, currency, { compact: true });
  const totalCost = rows?.reduce((sum, row) => sum + Number(row.total_cost), 0) ?? 0;
  const visible = limit && !showAll ? rows?.slice(0, limit) : rows;

  return (
    <Card className={clsx("min-w-0", className)}>
      <CardHeader title={title} description={description} />
      {!rows && <div className="m-5 h-40 animate-pulse rounded-xl bg-zinc-100" />}
      {rows && (
        <div className="overflow-x-auto">
          <table className="w-full text-sm">
            <thead>
              <tr className="text-left text-xs text-zinc-500 [&>th]:px-5 [&>th]:py-2.5 [&>th]:font-medium">
                <th>Name</th><th className="text-right">People</th><th>Annual cost</th>
                <th className="text-right">Median</th><th className="text-right">Range</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-zinc-100">
              {visible.map((row) => {
                const share = totalCost ? (Number(row.total_cost) / totalCost) * 100 : 0;
                return (
                  <tr key={row.key} className="[&>td]:px-5 [&>td]:py-2.5">
                    <td className="font-medium text-zinc-900">{row.label}</td>
                    <td className="tabular text-right text-zinc-600">{row.headcount.toLocaleString("en-US")}</td>
                    <td className="min-w-40">
                      <div className="flex items-center gap-2">
                        <div className="h-1.5 flex-1 overflow-hidden rounded-full bg-zinc-100">
                          <div className="h-full rounded-full bg-brand-500" style={{ width: `${share}%` }} />
                        </div>
                        <span className="tabular w-16 text-right text-zinc-700">{money(row.total_cost)}</span>
                      </div>
                    </td>
                    <td className="tabular text-right font-medium text-zinc-900">{money(row.median)}</td>
                    <td className="tabular whitespace-nowrap text-right text-xs text-zinc-500">
                      {money(row.minimum)} – {money(row.maximum)}
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </table>
          {limit && rows.length > limit && (
            <button type="button" onClick={() => setShowAll((s) => !s)}
              className="w-full border-t border-zinc-100 py-2.5 text-xs font-medium text-zinc-500 hover:text-zinc-900">
              {showAll ? "Show fewer" : `Show all ${rows.length}`}
            </button>
          )}
        </div>
      )}
    </Card>
  );
}
