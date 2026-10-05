// White rounded surface used for panels, tables and stats.
import clsx from "clsx";

export default function Card({ className, children, ...props }) {
  return (
    <div className={clsx("rounded-2xl bg-white shadow-card ring-1 ring-zinc-200/70", className)} {...props}>
      {children}
    </div>
  );
}

export function CardHeader({ title, description, actions }) {
  return (
    <div className="flex flex-wrap items-center justify-between gap-3 border-b border-zinc-100 px-5 py-4">
      <div>
        <h2 className="text-sm font-semibold text-zinc-900">{title}</h2>
        {description && <p className="mt-0.5 text-xs text-zinc-500">{description}</p>}
      </div>
      {actions}
    </div>
  );
}
