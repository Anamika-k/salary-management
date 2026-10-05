// A labelled form input with an optional hint/error line underneath.
// The label is wired to the input so screen readers (and tests) can find it.
import { useId } from "react";
import clsx from "clsx";
import { inputClass } from "@/lib/styles";

export default function Field({ label, error, hint, trailing, className, ...inputProps }) {
  const id = useId();
  return (
    <div className={className}>
      <label htmlFor={id} className="mb-1.5 block text-[13px] font-medium text-zinc-700">
        {label}
      </label>
      <div className="relative">
        <input
          id={id}
          aria-invalid={Boolean(error)}
          className={clsx(inputClass, "h-10", trailing && "pr-10", error && "ring-red-300 focus:ring-red-500")}
          {...inputProps}
        />
        {trailing && <div className="absolute inset-y-0 right-1 flex items-center">{trailing}</div>}
      </div>
      {(error || hint) && (
        <p className={clsx("mt-1.5 text-xs", error ? "text-red-600" : "text-zinc-500")}>{error || hint}</p>
      )}
    </div>
  );
}
