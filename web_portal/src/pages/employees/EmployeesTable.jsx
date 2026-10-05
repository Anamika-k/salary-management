// The employee list table with sortable headers, loading skeleton and empty state.
import { Link } from "react-router";
import { ArrowDown, ArrowUp, ChevronsUpDown, SearchX } from "lucide-react";
import clsx from "clsx";
import { flag, formatMoney } from "@/lib/format";
import { errorMessage } from "@/lib/errors";
import Avatar from "@/components/ui/Avatar";
import { ValueBadge } from "@/components/ui/Badge";
import EmptyState from "@/components/ui/EmptyState";
import Alert from "@/components/ui/Alert";

function SortHeader({ label, column, sort, direction, onSort, className }) {
  const active = sort === column;
  const Icon = active ? (direction === "asc" ? ArrowUp : ArrowDown) : ChevronsUpDown;
  return (
    <th className={className}>
      <button
        type="button"
        onClick={() => onSort(column, active && direction === "asc" ? "desc" : "asc")}
        className="inline-flex items-center gap-1 hover:text-zinc-900"
      >
        {label} <Icon className={clsx("h-3.5 w-3.5", !active && "text-zinc-300")} />
      </button>
    </th>
  );
}

function SkeletonRows() {
  return Array.from({ length: 8 }, (_, i) => (
    <tr key={i}>
      <td colSpan={6} className="px-4 py-3">
        <div className="h-8 animate-pulse rounded-lg bg-zinc-100" />
      </td>
    </tr>
  ));
}

export default function EmployeesTable({ result, sort, direction, onSort, onOpen }) {
  if (result.error) return <Alert className="m-4">{errorMessage(result.error)}</Alert>;
  const rows = result.data?.data;
  if (rows?.length === 0) {
    return <EmptyState icon={SearchX} title="No employees found" description="Try a different search or clear the filters." />;
  }

  const headerProps = { sort, direction, onSort };
  return (
    <div className="overflow-x-auto">
      <table className={clsx("w-full text-sm transition-opacity", result.isPlaceholderData && "opacity-60")}>
        <thead>
          <tr className="text-left text-xs font-medium text-zinc-500 [&>th]:px-4 [&>th]:py-2.5 [&>th]:font-medium">
            <SortHeader label="Employee" column="first_name" {...headerProps} />
            <SortHeader label="Code" column="employee_code" {...headerProps} />
            <th>Department</th>
            <th>Country</th>
            <th>Status</th>
            <th className="text-right">Annual salary</th>
          </tr>
        </thead>
        <tbody className="divide-y divide-zinc-100">
          {!rows && <SkeletonRows />}
          {rows?.map((employee) => (
            <tr key={employee.id} onClick={() => onOpen(employee.id)} className="cursor-pointer transition-colors hover:bg-zinc-50/80 [&>td]:px-4 [&>td]:py-2.5">
              <td>
                <div className="flex items-center gap-3">
                  <Avatar name={employee.full_name} />
                  <div className="min-w-0">
                    <Link to={`/employees/${employee.id}`} onClick={(e) => e.stopPropagation()} className="font-medium text-zinc-900 hover:underline">
                      {employee.full_name}
                    </Link>
                    <p className="truncate text-xs text-zinc-500">{employee.designation}</p>
                  </div>
                </div>
              </td>
              <td className="tabular text-zinc-500">{employee.employee_code}</td>
              <td className="text-zinc-700">{employee.department.name}</td>
              <td className="text-zinc-700"><span className="mr-1.5">{flag(employee.country_code)}</span>{employee.country_code}</td>
              <td><ValueBadge value={employee.employment_status} dot /></td>
              <td className="tabular text-right font-medium text-zinc-900">
                {employee.current_salary ? formatMoney(employee.current_salary.annual_salary, employee.current_salary.currency) : <span className="text-zinc-400">—</span>}
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}
