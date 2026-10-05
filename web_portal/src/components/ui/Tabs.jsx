// Underlined tab bar. The parent owns which tab is active.
import clsx from "clsx";

export default function Tabs({ tabs, active, onChange }) {
  return (
    <div role="tablist" className="flex gap-6 border-b border-zinc-200">
      {tabs.map(({ id, label, count }) => (
        <button
          key={id}
          type="button"
          role="tab"
          aria-selected={active === id}
          onClick={() => onChange(id)}
          className={clsx(
            "-mb-px flex items-center gap-2 border-b-2 pb-3 text-sm font-medium transition-colors",
            active === id ? "border-zinc-900 text-zinc-900" : "border-transparent text-zinc-500 hover:text-zinc-800",
          )}
        >
          {label}
          {count !== undefined && <span aria-hidden="true" className="rounded-full bg-zinc-100 px-1.5 text-xs text-zinc-500">{count}</span>}
        </button>
      ))}
    </div>
  );
}
