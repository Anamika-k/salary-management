// Small coloured labels: employment status, change type, component type.
import clsx from "clsx";
import { humanize } from "@/lib/format";

const TONES = {
  green: "bg-emerald-50 text-emerald-700 ring-emerald-600/15",
  amber: "bg-amber-50 text-amber-700 ring-amber-600/20",
  grey: "bg-zinc-100 text-zinc-600 ring-zinc-500/15",
  brand: "bg-brand-50 text-brand-700 ring-brand-600/15",
  red: "bg-red-50 text-red-700 ring-red-600/15",
  blue: "bg-sky-50 text-sky-700 ring-sky-600/15",
};

const VALUE_TONES = {
  active: "green", on_leave: "amber", terminated: "grey",
  joining: "blue", increment: "green", promotion: "brand", adjustment: "amber", correction: "red",
  earning: "green", deduction: "red",
  created: "green", updated: "blue", deleted: "red", restored: "amber",
};

export default function Badge({ tone = "grey", dot = false, className, children }) {
  return (
    <span className={clsx("inline-flex items-center gap-1.5 whitespace-nowrap rounded-full px-2 py-0.5 text-xs font-medium ring-1 ring-inset", TONES[tone], className)}>
      {dot && <span className="h-1.5 w-1.5 rounded-full bg-current" />}
      {children}
    </span>
  );
}

// A badge for an enum value from the API, coloured and labelled consistently.
export function ValueBadge({ value, dot }) {
  return <Badge tone={VALUE_TONES[value]} dot={dot}>{humanize(value)}</Badge>;
}
