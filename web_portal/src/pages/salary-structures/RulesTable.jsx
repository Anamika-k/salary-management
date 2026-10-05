// A structure's rules in calculation order, each described in plain words
// ("12% of Basic Salary"). Values can be edited inline; the remainder has none.
import { useState } from "react";
import { Check, Pencil, X } from "lucide-react";
import { useUpdateRule } from "@/lib/queries";
import { errorMessage, fieldError } from "@/lib/errors";
import { formatMoney } from "@/lib/format";
import { inputClass } from "@/lib/styles";
import { ValueBadge } from "@/components/ui/Badge";
import Button from "@/components/ui/Button";

function describe(rule, currency) {
  const value = Number(rule.value);
  switch (rule.calculation_method) {
    case "percentage_of_gross": return `${value}% of gross`;
    case "percentage_of_component": return `${value}% of ${rule.base_component.name}`;
    case "fixed": return `${formatMoney(value, currency)} per month`;
    default: return "Remainder of gross";
  }
}

function RuleRow({ rule, structure }) {
  const [editing, setEditing] = useState(false);
  const [value, setValue] = useState("");
  const update = useUpdateRule(String(structure.id));
  const name = rule.component.name;
  const percent = rule.calculation_method !== "fixed";

  function start() {
    setValue(String(Number(rule.value)));
    update.reset();
    setEditing(true);
  }
  function submit(event) {
    event.preventDefault();
    update.mutate({ id: rule.id, value }, { onSuccess: () => setEditing(false) });
  }

  return (
    <tr className="align-top [&>td]:px-5 [&>td]:py-3">
      <td className="tabular w-10 text-zinc-400">{rule.position}</td>
      <td>
        <p className="font-medium text-zinc-900">{name}</p>
        <p className="text-xs text-zinc-400">{rule.component.code}</p>
      </td>
      <td><ValueBadge value={rule.component.component_type} /></td>
      <td className="min-w-56">
        {editing ? (
          <form onSubmit={submit} className="flex items-center gap-1.5">
            <div className="relative">
              <input type="number" min="0" step="0.01" aria-label={`${name} value`} value={value} autoFocus
                onChange={(e) => setValue(e.target.value)} onKeyDown={(e) => e.key === "Escape" && setEditing(false)}
                className={`${inputClass} h-8 w-28 pr-8`} />
              <span className="pointer-events-none absolute right-2.5 top-1/2 -translate-y-1/2 text-xs text-zinc-400">
                {percent ? "%" : structure.currency}
              </span>
            </div>
            <Button type="submit" size="icon" aria-label="Save value" disabled={update.isPending}><Check className="h-4 w-4" /></Button>
            <Button variant="ghost" size="icon" aria-label="Cancel" onClick={() => setEditing(false)}><X className="h-4 w-4" /></Button>
          </form>
        ) : (
          <div className="flex items-center gap-2">
            <span className="text-zinc-700">{describe(rule, structure.currency)}</span>
            {rule.calculation_method !== "remainder" && (
              <button type="button" onClick={start} aria-label={`Edit ${name}`} className="rounded-md p-1 text-zinc-400 hover:bg-zinc-100 hover:text-zinc-700">
                <Pencil className="h-3.5 w-3.5" />
              </button>
            )}
          </div>
        )}
        {update.error && <p className="mt-1.5 text-xs text-red-600">{fieldError(update.error, "value") ?? errorMessage(update.error)}</p>}
      </td>
    </tr>
  );
}

export default function RulesTable({ structure }) {
  return (
    <div className="overflow-x-auto">
      <table className="w-full text-sm">
        <thead>
          <tr className="text-left text-xs text-zinc-500 [&>th]:px-5 [&>th]:py-2.5 [&>th]:font-medium">
            <th>#</th><th>Component</th><th>Type</th><th>Calculation</th>
          </tr>
        </thead>
        <tbody className="divide-y divide-zinc-100">
          {structure.components.map((rule) => <RuleRow key={rule.id} rule={rule} structure={structure} />)}
        </tbody>
      </table>
    </div>
  );
}
