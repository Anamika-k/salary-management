// Loading indicators: an inline spinner and a centred full-page variant.
import clsx from "clsx";

export default function Spinner({ className }) {
  return (
    <span
      className={clsx("inline-block h-4 w-4 animate-spin rounded-full border-2 border-current border-r-transparent", className)}
      aria-hidden="true"
    />
  );
}

export function PageLoader() {
  return (
    <div role="status" aria-label="Loading" className="flex min-h-[50vh] items-center justify-center text-zinc-400">
      <Spinner className="h-5 w-5" />
    </div>
  );
}
