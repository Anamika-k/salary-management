// Inline error message box, announced to screen readers.
import { AlertCircle } from "lucide-react";
import clsx from "clsx";

export default function Alert({ children, className }) {
  return (
    <div role="alert" className={clsx("flex gap-2 rounded-lg bg-red-50 px-3 py-2.5 text-sm text-red-700 ring-1 ring-inset ring-red-100", className)}>
      <AlertCircle className="mt-0.5 h-4 w-4 shrink-0" />
      <div>{children}</div>
    </div>
  );
}
