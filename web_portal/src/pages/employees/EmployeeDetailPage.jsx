// One employee: profile, current pay, and tabs for the monthly breakdown,
// salary history and audit trail. HR can edit, change salary or delete here.
import { useState } from "react";
import { Link, useNavigate, useParams } from "react-router";
import { ArrowLeft, Pencil, Trash2, TrendingUp, UserX } from "lucide-react";
import { useDeleteEmployee, useEmployee, useSalaries } from "@/lib/queries";
import { errorMessage } from "@/lib/errors";
import { flag, formatDate, formatMoney } from "@/lib/format";
import Avatar from "@/components/ui/Avatar";
import { ValueBadge } from "@/components/ui/Badge";
import Button from "@/components/ui/Button";
import Card from "@/components/ui/Card";
import EmptyState from "@/components/ui/EmptyState";
import Tabs from "@/components/ui/Tabs";
import { ConfirmDialog } from "@/components/ui/Dialog";
import { PageLoader } from "@/components/ui/Spinner";
import EmployeeFormDialog from "./EmployeeFormDialog";
import ChangeSalaryDialog from "./ChangeSalaryDialog";
import BreakdownTab from "./BreakdownTab";
import SalaryHistory from "./SalaryHistory";
import AuditTrail from "./AuditTrail";

function Stat({ label, value, hint }) {
  return (
    <Card className="px-5 py-4">
      <p className="text-xs font-medium text-zinc-500">{label}</p>
      <p className="tabular mt-1.5 truncate text-lg font-semibold tracking-tight text-zinc-900">{value}</p>
      {hint && <p className="mt-0.5 truncate text-xs text-zinc-400">{hint}</p>}
    </Card>
  );
}

export default function EmployeeDetailPage() {
  const { id } = useParams();
  const navigate = useNavigate();
  const employee = useEmployee(id);
  const salaries = useSalaries(id);
  const remove = useDeleteEmployee();
  const [tab, setTab] = useState("breakdown");
  const [dialog, setDialog] = useState(null);

  if (employee.isPending) return <PageLoader />;
  if (employee.error) {
    return (
      <EmptyState icon={UserX} title={errorMessage(employee.error)} description="The employee may have been deleted."
        action={<Link to="/employees" className="text-sm font-medium text-brand-600">Back to employees</Link>} />
    );
  }

  const person = employee.data;
  const salary = person.current_salary;
  const close = () => setDialog(null);

  return (
    <>
      <Link to="/employees" className="mb-5 inline-flex items-center gap-1.5 text-sm text-zinc-500 hover:text-zinc-900">
        <ArrowLeft className="h-4 w-4" /> Employees
      </Link>

      <div className="mb-6 flex flex-wrap items-center justify-between gap-4">
        <div className="flex items-center gap-4">
          <Avatar name={person.full_name} size="lg" />
          <div>
            <div className="flex items-center gap-2.5">
              <h1 className="text-xl font-semibold tracking-tight">{person.full_name}</h1>
              <ValueBadge value={person.employment_status} dot />
            </div>
            <p className="mt-1 text-sm text-zinc-500">
              {person.designation} · {person.department.name} · <span className="tabular">{person.employee_code}</span>
            </p>
            <p className="text-sm text-zinc-400">{person.email}</p>
          </div>
        </div>
        <div className="flex gap-2">
          <Button variant="ghost" onClick={() => setDialog("delete")}><Trash2 className="h-4 w-4" /> Delete</Button>
          <Button variant="secondary" onClick={() => setDialog("edit")}><Pencil className="h-4 w-4" /> Edit</Button>
          <Button onClick={() => setDialog("salary")}><TrendingUp className="h-4 w-4" /> {salary ? "Change salary" : "Add salary"}</Button>
        </div>
      </div>

      <div className="mb-8 grid grid-cols-2 gap-3 lg:grid-cols-4">
        <Stat label="Annual salary" value={salary ? formatMoney(salary.annual_salary, salary.currency) : "Not set"}
          hint={salary && `Since ${formatDate(salary.effective_from)}`} />
        <Stat label="Salary structure" value={salary?.salary_structure.name ?? "—"} hint={salary && salary.currency} />
        <Stat label="Joined" value={formatDate(person.joining_date)} hint={person.exit_date && `Left ${formatDate(person.exit_date)}`} />
        <Stat label="Country" value={`${flag(person.country.code)} ${person.country.name}`} hint={`Paid in ${person.country.currency}`} />
      </div>

      <Tabs
        active={tab}
        onChange={setTab}
        tabs={[
          { id: "breakdown", label: "Pay breakdown" },
          { id: "history", label: "Salary history", count: salaries.data?.length },
          { id: "audit", label: "Audit trail" },
        ]}
      />
      <div className="pt-6">
        {tab === "breakdown" && <BreakdownTab employeeId={id} />}
        {tab === "history" && <SalaryHistory salaries={salaries} />}
        {tab === "audit" && <AuditTrail employeeId={id} />}
      </div>

      {dialog === "edit" && <EmployeeFormDialog employee={person} onClose={close} />}
      {dialog === "salary" && <ChangeSalaryDialog employee={person} onClose={close} />}
      {dialog === "delete" && (
        <ConfirmDialog
          title={`Delete ${person.full_name}?`}
          description="Use this only for records created by mistake. Leavers should be marked as terminated instead."
          confirmLabel="Delete employee"
          pending={remove.isPending}
          error={errorMessage(remove.error)}
          onClose={close}
          onConfirm={() => remove.mutate(id, { onSuccess: () => navigate("/employees", { replace: true }) })}
        />
      )}
    </>
  );
}
