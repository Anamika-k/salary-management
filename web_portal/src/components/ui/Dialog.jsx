// Modal dialog: dimmed backdrop, Escape or backdrop click closes, focus moves inside.
// ConfirmDialog is the yes/no version used before destructive actions.
import { useEffect, useId, useRef } from "react";
import { X } from "lucide-react";
import clsx from "clsx";
import Button from "./Button";
import Alert from "./Alert";

export default function Dialog({ title, description, onClose, children, footer, size = "md" }) {
  const titleId = useId();
  const panel = useRef(null);
  const closeRef = useRef(onClose);
  useEffect(() => {
    closeRef.current = onClose;
  });

  useEffect(() => {
    const onKey = (event) => event.key === "Escape" && closeRef.current();
    document.addEventListener("keydown", onKey);
    panel.current?.querySelector("input, select, textarea, button:not([data-close])")?.focus();
    return () => document.removeEventListener("keydown", onKey);
  }, []);

  return (
    <div className="fixed inset-0 z-50 flex items-end justify-center p-4 sm:items-center">
      <div className="absolute inset-0 bg-zinc-900/30 backdrop-blur-[2px]" onClick={onClose} />
      <div
        ref={panel}
        role="dialog"
        aria-modal="true"
        aria-labelledby={titleId}
        className={clsx("relative flex max-h-[90vh] w-full flex-col rounded-2xl bg-white shadow-pop ring-1 ring-zinc-200", size === "lg" ? "max-w-2xl" : "max-w-md")}
      >
        <div className="flex items-start justify-between gap-4 px-6 pt-5">
          <div>
            <h2 id={titleId} className="text-base font-semibold text-zinc-900">{title}</h2>
            {description && <p className="mt-1 text-sm text-zinc-500">{description}</p>}
          </div>
          <button type="button" data-close onClick={onClose} aria-label="Close" className="-mr-2 rounded-md p-1.5 text-zinc-400 hover:bg-zinc-100 hover:text-zinc-700">
            <X className="h-4 w-4" />
          </button>
        </div>
        <div className="overflow-y-auto px-6 py-5">{children}</div>
        {footer && <div className="flex justify-end gap-2 rounded-b-2xl border-t border-zinc-100 bg-zinc-50/60 px-6 py-3">{footer}</div>}
      </div>
    </div>
  );
}

export function ConfirmDialog({ title, description, confirmLabel, onConfirm, onClose, pending, error }) {
  return (
    <Dialog
      title={title}
      description={description}
      onClose={onClose}
      footer={
        <>
          <Button variant="secondary" onClick={onClose}>Cancel</Button>
          <Button variant="danger" onClick={onConfirm} disabled={pending}>{confirmLabel}</Button>
        </>
      }
    >
      {error ? <Alert>{error}</Alert> : <p className="text-sm text-zinc-600">This can't be undone from the portal.</p>}
    </Dialog>
  );
}
