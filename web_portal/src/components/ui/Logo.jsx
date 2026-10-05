// ACME People wordmark, used in the sidebar and on sign in.
import clsx from "clsx";

export default function Logo({ className, inverted = false }) {
  return (
    <div className={clsx("flex items-center gap-2.5", className)}>
      <svg viewBox="0 0 32 32" className="h-7 w-7" aria-hidden="true">
        <rect width="32" height="32" rx="8" className={inverted ? "fill-white" : "fill-zinc-900"} />
        <path
          d="M10 22 16 9l6 13M12.5 17h7"
          strokeWidth="2.4"
          fill="none"
          strokeLinecap="round"
          strokeLinejoin="round"
          className={inverted ? "stroke-zinc-900" : "stroke-white"}
        />
      </svg>
      <span className={clsx("text-[15px] font-semibold tracking-tight", inverted ? "text-white" : "text-zinc-900")}>
        ACME <span className={inverted ? "text-white/60" : "text-zinc-400"}>People</span>
      </span>
    </div>
  );
}
