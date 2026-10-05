// Departments: add, rename inline and delete. Deleting is refused by the API
// while employees still belong to the department; we explain how to fix that.
import { useState } from "react";
import { Link } from "react-router";
import { ArrowUpRight, Building2, Check, Pencil, Plus, Trash2, X } from "lucide-react";
import { useDeleteDepartment, useDepartments, useSaveDepartment } from "@/lib/queries";
import { errorMessage } from "@/lib/errors";
import { pluralize } from "@/lib/format";
import { inputClass } from "@/lib/styles";
import PageHeader from "@/components/ui/PageHeader";
import Card from "@/components/ui/Card";
import Button from "@/components/ui/Button";
import Alert from "@/components/ui/Alert";
import EmptyState from "@/components/ui/EmptyState";
import { ConfirmDialog } from "@/components/ui/Dialog";
import { PageLoader } from "@/components/ui/Spinner";

function deleteError(error, department) {
  if (error?.code !== "department_in_use") return errorMessage(error);
  const count = error.details.employee_count;
  return `${department.name} still has ${pluralize(count, "employee")}. Move them to another department first.`;
}

function DepartmentRow({ department, onDelete }) {
  const [editing, setEditing] = useState(false);
  const [name, setName] = useState(department.name);
  const save = useSaveDepartment();

  function submit(event) {
    event.preventDefault();
    save.mutate({ id: department.id, name }, { onSuccess: () => setEditing(false) });
  }
  function cancel() {
    setEditing(false);
    setName(department.name);
    save.reset();
  }

  return (
    <li className="group flex flex-wrap items-center gap-3 px-5 py-3">
      <div className="flex h-8 w-8 items-center justify-center rounded-lg bg-zinc-100 text-zinc-500">
        <Building2 className="h-4 w-4" />
      </div>
      {editing ? (
        <form onSubmit={submit} className="flex flex-1 items-center gap-2">
          <input aria-label="Department name" value={name} onChange={(e) => setName(e.target.value)} autoFocus
            onKeyDown={(e) => e.key === "Escape" && cancel()} className={`${inputClass} h-9 max-w-xs`} />
          <Button type="submit" size="icon" aria-label="Save name" disabled={save.isPending}><Check className="h-4 w-4" /></Button>
          <Button variant="ghost" size="icon" aria-label="Cancel" onClick={cancel}><X className="h-4 w-4" /></Button>
        </form>
      ) : (
        <p className="flex-1 text-sm font-medium text-zinc-900">{department.name}</p>
      )}
      {!editing && (
        <div className="flex items-center gap-1">
          <Link to={`/employees?department_id=${department.id}`} className="mr-2 inline-flex items-center gap-1 text-xs font-medium text-zinc-500 hover:text-brand-600">
            View employees <ArrowUpRight className="h-3.5 w-3.5" />
          </Link>
          <Button variant="ghost" size="icon" aria-label={`Rename ${department.name}`} onClick={() => setEditing(true)}><Pencil className="h-3.5 w-3.5" /></Button>
          <Button variant="ghost" size="icon" aria-label={`Delete ${department.name}`} onClick={() => onDelete(department)}><Trash2 className="h-3.5 w-3.5" /></Button>
        </div>
      )}
      {save.error && <p className="w-full pl-11 text-xs text-red-600">{errorMessage(save.error)}</p>}
    </li>
  );
}

export default function DepartmentsPage() {
  const departments = useDepartments();
  const create = useSaveDepartment();
  const remove = useDeleteDepartment();
  const [name, setName] = useState("");
  const [deleting, setDeleting] = useState(null);

  function add(event) {
    event.preventDefault();
    create.mutate({ name }, { onSuccess: () => setName("") });
  }
  function closeDelete() {
    setDeleting(null);
    remove.reset();
  }

  return (
    <>
      <PageHeader title="Departments" description={departments.data ? pluralize(departments.data.length, "department") : "Teams at ACME"} />
      <Card className="max-w-3xl">
        <form onSubmit={add} className="border-b border-zinc-100 p-4">
          <div className="flex gap-2">
            <input value={name} onChange={(e) => setName(e.target.value)} placeholder="New department name"
              aria-label="New department name" className={`${inputClass} h-9 flex-1`} />
            <Button type="submit" disabled={!name.trim() || create.isPending}><Plus className="h-4 w-4" /> Add</Button>
          </div>
          {create.error && <p className="mt-2 text-xs text-red-600">{errorMessage(create.error)}</p>}
        </form>

        {departments.isPending && <PageLoader />}
        {departments.error && <Alert className="m-4">{errorMessage(departments.error)}</Alert>}
        {departments.data?.length === 0 && <EmptyState icon={Building2} title="No departments yet" description="Add the first one above." />}
        <ul className="divide-y divide-zinc-100">
          {departments.data?.map((department) => (
            <DepartmentRow key={`${department.id}-${department.name}`} department={department} onDelete={setDeleting} />
          ))}
        </ul>
      </Card>

      {deleting && (
        <ConfirmDialog
          title={`Delete ${deleting.name}?`}
          description="Deleted departments can be brought back by adding one with the same name."
          confirmLabel="Delete department"
          pending={remove.isPending}
          error={remove.error && deleteError(remove.error, deleting)}
          onClose={closeDelete}
          onConfirm={() => remove.mutate(deleting.id, { onSuccess: closeDelete })}
        />
      )}
    </>
  );
}
