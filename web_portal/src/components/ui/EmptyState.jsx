// Friendly placeholder when a list or panel has nothing to show.
import clsx from "clsx";

export default function EmptyState({ icon: Icon, title, description, action, className }) {
  return (
    <div className={clsx("flex flex-col items-center justify-center px-6 py-14 text-center", className)}>
      {Icon && (
        <div className="flex h-10 w-10 items-center justify-center rounded-full bg-zinc-100 text-zinc-500">
          <Icon className="h-5 w-5" />
        </div>
      )}
      <p className="mt-4 text-sm font-medium text-zinc-900">{title}</p>
      {description && <p className="mt-1 max-w-sm text-sm text-zinc-500">{description}</p>}
      {action && <div className="mt-4">{action}</div>}
    </div>
  );
}
