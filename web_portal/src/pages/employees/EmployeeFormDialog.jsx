// Add or edit an employee. The API validates; its field errors show under each input.
import { useState } from "react";
import { useFilters, useSaveEmployee } from "@/lib/queries";
import { fieldError, formLevelError } from "@/lib/errors";
import { humanize } from "@/lib/format";
import Dialog from "@/components/ui/Dialog";
import Button from "@/components/ui/Button";
import Field from "@/components/ui/Field";
import Alert from "@/components/ui/Alert";
import { SelectField } from "@/components/ui/Select";

const FIELDS = ["first_name", "last_name", "email", "department", "designation", "country_code", "joining_date", "employment_status", "exit_date"];

function initialValues(employee) {
  return {
    first_name: employee?.first_name ?? "",
    last_name: employee?.last_name ?? "",
    email: employee?.email ?? "",
    department_id: employee?.department.id ?? "",
    designation: employee?.designation ?? "",
    country_code: employee?.country_code ?? "",
    joining_date: employee?.joining_date ?? "",
    employment_status: employee?.employment_status ?? "active",
    exit_date: employee?.exit_date ?? "",
  };
}

export default function EmployeeFormDialog({ employee, onClose, onSaved }) {
  const [values, setValues] = useState(() => initialValues(employee));
  const options = useFilters().data;
  const save = useSaveEmployee(employee?.id);
  const error = save.error;
  const terminated = values.employment_status === "terminated";

  const bind = (name) => ({
    value: values[name],
    onChange: (event) => setValues((v) => ({ ...v, [name]: event.target.value })),
    error: fieldError(error, name),
  });

  function handleSubmit(event) {
    event.preventDefault();
    const payload = { ...values, exit_date: terminated ? values.exit_date : null };
    save.mutate(payload, { onSuccess: (saved) => (onSaved ? onSaved(saved) : onClose()) });
  }

  return (
    <Dialog
      size="lg"
      title={employee ? `Edit ${employee.full_name}` : "Add employee"}
      description={employee ? employee.employee_code : "An employee code is assigned automatically."}
      onClose={onClose}
      footer={
        <>
          <Button variant="secondary" onClick={onClose}>Cancel</Button>
          <Button type="submit" form="employee-form" disabled={save.isPending}>
            {employee ? "Save changes" : "Create employee"}
          </Button>
        </>
      }
    >
      <form id="employee-form" onSubmit={handleSubmit} className="grid gap-4 sm:grid-cols-2" noValidate>
        {formLevelError(error, FIELDS) && <Alert className="sm:col-span-2">{formLevelError(error, FIELDS)}</Alert>}
        <Field label="First name" autoComplete="off" {...bind("first_name")} />
        <Field label="Last name" autoComplete="off" {...bind("last_name")} />
        <Field label="Email" type="email" autoComplete="off" className="sm:col-span-2" {...bind("email")} />
        <SelectField label="Department" {...bind("department_id")} error={fieldError(error, "department")}>
          <option value="">Select…</option>
          {options?.departments.map((d) => <option key={d.id} value={d.id}>{d.name}</option>)}
        </SelectField>
        <Field label="Designation" list="designations" autoComplete="off" {...bind("designation")} />
        <datalist id="designations">
          {options?.designations.map((d) => <option key={d} value={d} />)}
        </datalist>
        <SelectField label="Country" {...bind("country_code")}>
          <option value="">Select…</option>
          {options?.countries.map((c) => <option key={c.code} value={c.code}>{c.name} ({c.currency})</option>)}
        </SelectField>
        <Field label="Joining date" type="date" {...bind("joining_date")} />
        <SelectField label="Status" {...bind("employment_status")}>
          {(options?.employment_statuses ?? ["active"]).map((s) => <option key={s} value={s}>{humanize(s)}</option>)}
        </SelectField>
        {terminated && <Field label="Exit date" type="date" {...bind("exit_date")} />}
      </form>
    </Dialog>
  );
}
