// Who changed this employee's salary records, when, and the before → after values.
import { ShieldCheck } from "lucide-react";
import { useAuditLogs } from "@/lib/queries";
import { errorMessage } from "@/lib/errors";
import { formatDateTime, humanize } from "@/lib/format";
import Card from "@/components/ui/Card";
import { ValueBadge } from "@/components/ui/Badge";
import EmptyState from "@/components/ui/EmptyState";
import Alert from "@/components/ui/Alert";
import { PageLoader } from "@/components/ui/Spinner";

const show = (value) => (value === null || value === undefined || value === "" ? "empty" : String(value));

export default function AuditTrail({ employeeId }) {
  const logs = useAuditLogs(employeeId);

  if (logs.isPending) return <PageLoader />;
  if (logs.error) return <Alert>{errorMessage(logs.error)}</Alert>;
  if (logs.data.length === 0) {
    return <Card><EmptyState icon={ShieldCheck} title="No changes recorded yet" description="Salary changes made in the portal appear here." /></Card>;
  }

  return (
    <Card className="divide-y divide-zinc-100">
      {logs.data.map((log) => (
        <div key={log.id} className="px-5 py-4">
          <div className="flex flex-wrap items-center justify-between gap-2">
            <div className="flex items-center gap-2 text-sm">
              <ValueBadge value={log.action} />
              <span className="font-medium text-zinc-900">Salary record #{log.auditable_id}</span>
              <span className="text-zinc-500">by {log.user.name}</span>
            </div>
            <time className="text-xs text-zinc-400">{formatDateTime(log.created_at)}</time>
          </div>
          <dl className="mt-3 grid gap-1.5 text-sm sm:grid-cols-2">
            {Object.entries(log.change_set).map(([field, [before, after]]) => (
              <div key={field} className="flex gap-2">
                <dt className="w-32 shrink-0 text-zinc-500">{humanize(field)}</dt>
                <dd className="tabular min-w-0 truncate text-zinc-700">
                  <span className="text-zinc-400 line-through decoration-zinc-300">{show(before)}</span> → {show(after)}
                </dd>
              </div>
            ))}
          </dl>
        </div>
      ))}
    </Card>
  );
}
