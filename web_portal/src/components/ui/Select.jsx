// Native <select> styled to match inputs: a labelled form field and a compact
// toolbar variant. Native keeps keyboard and mobile behaviour for free.
import { useId } from "react";
import clsx from "clsx";
import { ChevronDown } from "lucide-react";
import { inputClass } from "@/lib/styles";

function SelectBox({ className, children, ...props }) {
  return (
    <div className={clsx("relative", className)}>
      <select className={clsx(inputClass, "h-10 appearance-none pr-9")} {...props}>
        {children}
      </select>
      <ChevronDown className="pointer-events-none absolute right-3 top-1/2 h-4 w-4 -translate-y-1/2 text-zinc-400" />
    </div>
  );
}

export function SelectField({ label, error, className, children, ...props }) {
  const id = useId();
  return (
    <div className={className}>
      <label htmlFor={id} className="mb-1.5 block text-[13px] font-medium text-zinc-700">{label}</label>
      <SelectBox id={id} aria-invalid={Boolean(error)} {...props}>{children}</SelectBox>
      {error && <p className="mt-1.5 text-xs text-red-600">{error}</p>}
    </div>
  );
}

// Toolbar filter: the label is for screen readers; the first option says what it filters.
export function FilterSelect({ label, className, children, ...props }) {
  return (
    <SelectBox aria-label={label} className={clsx("min-w-36", className)} {...props}>
      {children}
    </SelectBox>
  );
}
