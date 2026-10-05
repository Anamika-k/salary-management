// The latest raises and promotions across ACME, each linking to the employee.
import { Link } from "react-router";
import { useRecentChanges } from "@/lib/queries";
import { formatDate, formatMoney } from "@/lib/format";
import Card, { CardHeader } from "@/components/ui/Card";
import Avatar from "@/components/ui/Avatar";
import { ValueBadge } from "@/components/ui/Badge";

export default function RecentChanges() {
  const changes = useRecentChanges();

  return (
    <Card className="min-w-0">
      <CardHeader title="Recent salary changes" description="Latest raises and promotions" />
      {!changes.data && <div className="m-5 h-52 animate-pulse rounded-xl bg-zinc-100" />}
      {changes.data?.length === 0 && <p className="p-5 text-sm text-zinc-400">No salary changes yet.</p>}
      <ul className="divide-y divide-zinc-100">
        {changes.data?.map((change) => (
          <li key={change.id} className="flex items-center gap-3 px-5 py-3">
            <Avatar name={change.employee.full_name} />
            <div className="min-w-0 flex-1">
              <Link to={`/employees/${change.employee.id}`} className="block truncate text-sm font-medium text-zinc-900 hover:underline">
                {change.employee.full_name}
              </Link>
              <p className="truncate text-xs text-zinc-500">{`${change.employee.designation} · ${change.employee.department}`}</p>
            </div>
            <div className="text-right">
              <p className="tabular text-sm font-medium text-zinc-900">{formatMoney(change.annual_salary, change.currency)}</p>
              <div className="mt-0.5 flex items-center justify-end gap-1.5">
                {change.change_type !== "increment" && <ValueBadge value={change.change_type} />}
                {change.change_percent !== null && (
                  <span className="tabular text-xs font-medium text-emerald-600">
                    {Number(change.change_percent) >= 0 ? "+" : ""}{Number(change.change_percent).toFixed(1)}%
                  </span>
                )}
                <span className="text-[11px] text-zinc-400">{formatDate(change.effective_from)}</span>
              </div>
            </div>
          </li>
        ))}
      </ul>
    </Card>
  );
}
