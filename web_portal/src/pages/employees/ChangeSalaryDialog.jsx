// Records a salary change (or the first salary). The API closes the current
// salary the day before and enforces the history rules; its message shows here.
import { useState } from "react";
import { useChangeSalary, useStructures } from "@/lib/queries";
import { fieldError, formLevelError } from "@/lib/errors";
import { formatMoney, humanize, todayIso } from "@/lib/format";
import { inputClass } from "@/lib/styles";
import Dialog from "@/components/ui/Dialog";
import Button from "@/components/ui/Button";
import Field from "@/components/ui/Field";
import Alert from "@/components/ui/Alert";
import { SelectField } from "@/components/ui/Select";

const CHANGE_TYPES = ["increment", "promotion", "adjustment", "correction", "joining"];
const FIELDS = ["annual_salary", "salary_structure", "effective_from", "change_type", "notes"];

export default function ChangeSalaryDialog({ employee, onClose }) {
  const current = employee.current_salary;
  const structures = (useStructures().data ?? []).filter((s) => s.country_code === employee.country_code);
  const save = useChangeSalary(String(employee.id));
  const [values, setValues] = useState({
    annual_salary: "",
    salary_structure_id: current?.salary_structure.id ?? "",
    effective_from: todayIso(),
    change_type: current ? "increment" : "joining",
    notes: "",
  });
  const structureId = values.salary_structure_id || structures[0]?.id || "";
  const set = (name) => (event) => setValues((v) => ({ ...v, [name]: event.target.value }));
  const error = save.error;

  function handleSubmit(event) {
    event.preventDefault();
    save.mutate({ ...values, salary_structure_id: Number(structureId) }, { onSuccess: onClose });
  }

  return (
    <Dialog
      title={current ? "Change salary" : "Add salary"}
      description={current ? `Currently ${formatMoney(current.annual_salary, current.currency)} a year.` : "Record this employee's first salary."}
      onClose={onClose}
      footer={
        <>
          <Button variant="secondary" onClick={onClose}>Cancel</Button>
          <Button type="submit" form="salary-form" disabled={save.isPending}>Save change</Button>
        </>
      }
    >
      <form id="salary-form" onSubmit={handleSubmit} className="space-y-4" noValidate>
        {formLevelError(error, FIELDS) && <Alert>{formLevelError(error, FIELDS)}</Alert>}
        <Field label="New annual salary" type="number" min="1" step="1000" inputMode="decimal"
          hint={`Gross per year in ${employee.country.currency}`}
          value={values.annual_salary} onChange={set("annual_salary")} error={fieldError(error, "annual_salary")} />
        <div className="grid gap-4 sm:grid-cols-2">
          <Field label="Effective from" type="date" value={values.effective_from} onChange={set("effective_from")}
            error={fieldError(error, "effective_from")} />
          <SelectField label="Reason" value={values.change_type} onChange={set("change_type")}>
            {CHANGE_TYPES.map((type) => <option key={type} value={type}>{humanize(type)}</option>)}
          </SelectField>
        </div>
        <SelectField label="Salary structure" value={structureId} onChange={set("salary_structure_id")}>
          {structures.map((s) => <option key={s.id} value={s.id}>{s.name}</option>)}
        </SelectField>
        <div>
          <label htmlFor="salary-notes" className="mb-1.5 block text-[13px] font-medium text-zinc-700">Notes <span className="font-normal text-zinc-400">(optional)</span></label>
          <textarea id="salary-notes" rows={2} value={values.notes} onChange={set("notes")} className={`${inputClass} py-2`} placeholder="e.g. Annual review 2026" />
        </div>
      </form>
    </Dialog>
  );
}
