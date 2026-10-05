// Headline numbers across the company, plus a warning when someone we pay has no salary.
import { ArrowLeftRight, LogIn, LogOut, Users } from "lucide-react";
import Card from "@/components/ui/Card";
import Alert from "@/components/ui/Alert";
import { errorMessage } from "@/lib/errors";
import { pluralize } from "@/lib/format";

const number = (value) => value.toLocaleString("en-US");

function StatCard({ icon: Icon, label, value, hint }) {
  return (
    <Card className="p-5">
      <div className="flex items-center justify-between">
        <p className="text-xs font-medium text-zinc-500">{label}</p>
        <Icon className="h-4 w-4 text-zinc-300" />
      </div>
      <p className="tabular mt-2 text-2xl font-semibold tracking-tight text-zinc-900">{value}</p>
      <p className="mt-1 text-xs text-zinc-400">{hint}</p>
    </Card>
  );
}

function Skeleton() {
  return (
    <div className="grid grid-cols-2 gap-3 lg:grid-cols-4">
      {[1, 2, 3, 4].map((i) => <div key={i} className="h-[106px] animate-pulse rounded-2xl bg-zinc-100" />)}
    </div>
  );
}

export default function SummaryCards({ summary }) {
  if (summary.error) return <Alert>{errorMessage(summary.error)}</Alert>;
  if (!summary.data) return <Skeleton />;
  const s = summary.data;

  return (
    <div className="space-y-3">
      {s.paid_without_salary > 0 && (
        <Alert>{pluralize(s.paid_without_salary, "employee")} {s.paid_without_salary === 1 ? "has" : "have"} no salary yet. Add one from their profile so pay figures are complete.</Alert>
      )}
      <div className="grid grid-cols-2 gap-3 lg:grid-cols-4">
        <StatCard icon={Users} label="Employees" value={number(s.headcount.total)}
          hint={`${number(s.headcount.active)} active · ${number(s.headcount.on_leave)} on leave`} />
        <StatCard icon={LogIn} label="Joined this year" value={number(s.joiners_this_year)} hint={`Across ${s.countries} countries`} />
        <StatCard icon={LogOut} label="Left this year" value={number(s.leavers_this_year)} hint={`${number(s.headcount.terminated)} former employees in total`} />
        <StatCard icon={ArrowLeftRight} label="Salary changes" value={number(s.salary_changes_last_30_days)} hint="In the last 30 days" />
      </div>
    </div>
  );
}
