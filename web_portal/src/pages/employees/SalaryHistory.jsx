// Every salary period, newest first, as a timeline with the change from the
// previous period (e.g. +8.0%), who recorded it and why.
import { History } from "lucide-react";
import clsx from "clsx";
import { formatDate, formatMoney } from "@/lib/format";
import { errorMessage } from "@/lib/errors";
import Card from "@/components/ui/Card";
import { ValueBadge } from "@/components/ui/Badge";
import EmptyState from "@/components/ui/EmptyState";
import Alert from "@/components/ui/Alert";
import { PageLoader } from "@/components/ui/Spinner";

function change(current, previous) {
  if (!previous || previous.currency !== current.currency) return null;
  return ((Number(current.annual_salary) - Number(previous.annual_salary)) / Number(previous.annual_salary)) * 100;
}

export default function SalaryHistory({ salaries }) {
  if (salaries.isPending) return <PageLoader />;
  if (salaries.error) return <Alert>{errorMessage(salaries.error)}</Alert>;
  if (salaries.data.length === 0) {
    return <Card><EmptyState icon={History} title="No salary yet" description="Use “Add salary” to record the joining salary." /></Card>;
  }

  return (
    <Card className="p-5">
      <ol className="relative space-y-6 border-l border-zinc-200 pl-6">
        {salaries.data.map((salary, index) => {
          const percent = change(salary, salaries.data[index + 1]);
          const current = !salary.effective_to;
          return (
            <li key={salary.id} className="relative">
              <span className={clsx("absolute -left-[31px] top-1.5 h-2.5 w-2.5 rounded-full ring-4 ring-white", current ? "bg-brand-600" : "bg-zinc-300")} />
              <div className="flex flex-wrap items-center gap-x-3 gap-y-1">
                <p className="tabular text-base font-semibold text-zinc-900">{formatMoney(salary.annual_salary, salary.currency)}</p>
                <ValueBadge value={salary.change_type} />
                {percent !== null && (
                  <span className={clsx("tabular text-xs font-medium", percent >= 0 ? "text-emerald-600" : "text-red-600")}>
                    {percent >= 0 ? "+" : ""}{percent.toFixed(1)}%
                  </span>
                )}
                {current && <span className="text-xs font-medium text-brand-600">Current</span>}
              </div>
              <p className="mt-1 text-sm text-zinc-500">
                {formatDate(salary.effective_from)} – {salary.effective_to ? formatDate(salary.effective_to) : "present"} · {salary.salary_structure.name}
              </p>
              {salary.notes && <p className="mt-1 text-sm text-zinc-700">{salary.notes}</p>}
              <p className="mt-1 text-xs text-zinc-400">Recorded by {salary.created_by.name} on {formatDate(salary.created_at)}</p>
            </li>
          );
        })}
      </ol>
    </Card>
  );
}
