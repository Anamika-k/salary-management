// The employee directory: search, filters, sort and pagination.
// All list state lives in the URL, so a filtered view can be shared or bookmarked
// and the back button returns to the same page.
import { useEffect, useState } from "react";
import { useNavigate, useSearchParams } from "react-router";
import { Plus, Search, X } from "lucide-react";
import { useEmployees, useFilters } from "@/lib/queries";
import { useDebouncedValue } from "@/lib/hooks";
import { humanize, pluralize } from "@/lib/format";
import { inputClass } from "@/lib/styles";
import PageHeader from "@/components/ui/PageHeader";
import Button from "@/components/ui/Button";
import Card from "@/components/ui/Card";
import Pagination from "@/components/ui/Pagination";
import { FilterSelect } from "@/components/ui/Select";
import EmployeesTable from "./EmployeesTable";
import EmployeeFormDialog from "./EmployeeFormDialog";

const FILTER_KEYS = ["department_id", "country_code", "employment_status"];

export default function EmployeesPage() {
  const navigate = useNavigate();
  const [params, setParams] = useSearchParams();
  const [search, setSearch] = useState(params.get("q") ?? "");
  const [adding, setAdding] = useState(false);
  const debouncedSearch = useDebouncedValue(search.trim());
  const query = { ...Object.fromEntries(params), page: params.get("page") ?? 1 };
  const employees = useEmployees(query);
  const options = useFilters().data;

  // Any change except paging goes back to page 1.
  function update(changes) {
    setParams((current) => {
      const next = new URLSearchParams(current);
      Object.entries(changes).forEach(([key, value]) => (value ? next.set(key, value) : next.delete(key)));
      if (!("page" in changes)) next.delete("page");
      return next;
    });
  }

  useEffect(() => {
    if (debouncedSearch !== (params.get("q") ?? "")) update({ q: debouncedSearch });
    // eslint-disable-next-line react-hooks/exhaustive-deps -- only react to the typed search
  }, [debouncedSearch]);

  const filtered = FILTER_KEYS.some((key) => params.get(key)) || params.get("q");
  const total = employees.data?.meta.total_count;

  return (
    <>
      <PageHeader
        title="Employees"
        description={total === undefined ? "Everyone at ACME" : `${pluralize(total, "employee")}${filtered ? " match" : " across ACME"}`}
        actions={<Button onClick={() => setAdding(true)}><Plus className="h-4 w-4" /> Add employee</Button>}
      />

      <Card>
        <div className="flex flex-wrap items-center gap-2 border-b border-zinc-100 p-3">
          <div className="relative min-w-60 flex-1">
            <Search className="pointer-events-none absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-zinc-400" />
            <input
              type="search"
              value={search}
              onChange={(event) => setSearch(event.target.value)}
              placeholder="Search by name, email or code…"
              aria-label="Search employees"
              className={`${inputClass} h-10 pl-9`}
            />
          </div>
          <FilterSelect label="Department" value={params.get("department_id") ?? ""} onChange={(e) => update({ department_id: e.target.value })}>
            <option value="">All departments</option>
            {options?.departments.map((d) => <option key={d.id} value={d.id}>{d.name}</option>)}
          </FilterSelect>
          <FilterSelect label="Country" value={params.get("country_code") ?? ""} onChange={(e) => update({ country_code: e.target.value })}>
            <option value="">All countries</option>
            {options?.countries.map((c) => <option key={c.code} value={c.code}>{c.name}</option>)}
          </FilterSelect>
          <FilterSelect label="Status" value={params.get("employment_status") ?? ""} onChange={(e) => update({ employment_status: e.target.value })}>
            <option value="">Any status</option>
            {options?.employment_statuses.map((s) => <option key={s} value={s}>{humanize(s)}</option>)}
          </FilterSelect>
          {filtered && (
            <Button variant="ghost" onClick={() => { setSearch(""); setParams({}); }}>
              <X className="h-4 w-4" /> Clear
            </Button>
          )}
        </div>

        <EmployeesTable
          result={employees}
          sort={params.get("sort") ?? "employee_code"}
          direction={params.get("direction") ?? "asc"}
          onSort={(sort, direction) => update({ sort, direction })}
          onOpen={(id) => navigate(`/employees/${id}`)}
        />
        <Pagination meta={employees.data?.meta} onPageChange={(page) => update({ page: String(page) })} />
      </Card>

      {adding && (
        <EmployeeFormDialog onClose={() => setAdding(false)} onSaved={(employee) => navigate(`/employees/${employee.id}`)} />
      )}
    </>
  );
}
