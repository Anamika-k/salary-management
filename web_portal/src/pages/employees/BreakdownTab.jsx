// The employee's monthly pay breakdown on any date (today by default),
// so HR can see what someone was paid in the past as well as now.
import { useState } from "react";
import { CalendarX } from "lucide-react";
import { useBreakdown } from "@/lib/queries";
import { errorMessage } from "@/lib/errors";
import { formatDate, todayIso } from "@/lib/format";
import Card from "@/components/ui/Card";
import Field from "@/components/ui/Field";
import EmptyState from "@/components/ui/EmptyState";
import Alert from "@/components/ui/Alert";
import BreakdownCard from "@/components/BreakdownCard";
import { PageLoader } from "@/components/ui/Spinner";

export default function BreakdownTab({ employeeId }) {
  const [on, setOn] = useState(todayIso());
  const breakdown = useBreakdown(employeeId, on);
  const notFound = breakdown.error?.status === 404;

  return (
    <Card className="p-5">
      <div className="mb-5 flex flex-wrap items-end justify-between gap-4">
        <div>
          <h2 className="text-sm font-semibold text-zinc-900">Monthly breakdown</h2>
          {breakdown.data && !notFound && (
            <p className="mt-0.5 text-xs text-zinc-500">
              Salary effective {formatDate(breakdown.data.effective_from)}
              {breakdown.data.effective_to ? ` – ${formatDate(breakdown.data.effective_to)}` : " – present"}
            </p>
          )}
        </div>
        <Field label="Breakdown on" type="date" value={on} onChange={(e) => setOn(e.target.value)} className="w-44" />
      </div>

      {notFound && <EmptyState icon={CalendarX} title="No salary on this date" description="Pick a date after the employee's first salary." />}
      {breakdown.error && !notFound && <Alert>{errorMessage(breakdown.error)}</Alert>}
      {!breakdown.error && breakdown.isPending && <PageLoader />}
      {!breakdown.error && breakdown.data && <BreakdownCard breakdown={breakdown.data} />}
    </Card>
  );
}
