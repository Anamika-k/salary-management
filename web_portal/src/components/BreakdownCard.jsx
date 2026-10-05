// A monthly pay breakdown (earnings, deductions, net pay) as returned by the
// calculator. Shared by the employee page and the salary structure preview.
import { formatMoney } from "@/lib/format";

function Lines({ title, lines, total, currency, negative }) {
  return (
    <div>
      <div className="flex items-baseline justify-between pb-2">
        <p className="text-xs font-medium uppercase tracking-wider text-zinc-400">{title}</p>
        <p className="tabular text-xs font-medium text-zinc-500">{formatMoney(total, currency, { decimals: 2 })}</p>
      </div>
      <ul className="divide-y divide-zinc-100">
        {lines.map((line) => (
          <li key={line.code} className="flex items-center justify-between py-2 text-sm">
            <span className="text-zinc-600">{line.name}</span>
            <span className={`tabular ${negative ? "text-zinc-500" : "text-zinc-900"}`}>
              {negative && "− "}{formatMoney(line.amount, currency, { decimals: 2 })}
            </span>
          </li>
        ))}
        {lines.length === 0 && <li className="py-2 text-sm text-zinc-400">None</li>}
      </ul>
    </div>
  );
}

export default function BreakdownCard({ breakdown }) {
  const { currency, monthly_gross: gross, net_pay: net, total_deductions: deducted } = breakdown;
  const netShare = Number(gross) > 0 ? (Number(net) / Number(gross)) * 100 : 0;

  return (
    <div className="space-y-6">
      <div className="rounded-xl bg-zinc-950 p-5 text-white">
        <div className="flex items-end justify-between gap-4">
          <div>
            <p className="text-xs text-zinc-400">Net pay per month</p>
            <p className="tabular mt-1 text-3xl font-semibold tracking-tight">{formatMoney(net, currency, { decimals: 2 })}</p>
          </div>
          <div className="text-right text-xs text-zinc-400">
            <p>Gross <span className="tabular text-zinc-200">{formatMoney(gross, currency, { decimals: 2 })}</span></p>
            <p className="mt-0.5">Deductions <span className="tabular text-zinc-200">{formatMoney(deducted, currency, { decimals: 2 })}</span></p>
          </div>
        </div>
        <div className="mt-4 flex h-1.5 overflow-hidden rounded-full bg-rose-400/70" aria-hidden="true">
          <div className="bg-brand-400" style={{ width: `${netShare}%` }} />
        </div>
        <div className="mt-2 flex justify-between text-[11px] text-zinc-400">
          <span>Take home {netShare.toFixed(0)}%</span>
          <span>Deductions {(100 - netShare).toFixed(0)}%</span>
        </div>
      </div>

      <div className="grid gap-6 sm:grid-cols-2">
        <Lines title="Earnings" lines={breakdown.earnings} total={breakdown.total_earnings} currency={currency} />
        <Lines title="Deductions" lines={breakdown.deductions} total={deducted} currency={currency} negative />
      </div>
    </div>
  );
}
