// Initials avatar with a soft colour picked from the name, so people are easy to scan.
import clsx from "clsx";
import { initials } from "@/lib/format";

const COLOURS = [
  "bg-brand-100 text-brand-700",
  "bg-emerald-100 text-emerald-700",
  "bg-amber-100 text-amber-800",
  "bg-sky-100 text-sky-700",
  "bg-rose-100 text-rose-700",
  "bg-violet-100 text-violet-700",
];

function colourFor(name = "") {
  const sum = [...name].reduce((total, char) => total + char.charCodeAt(0), 0);
  return COLOURS[sum % COLOURS.length];
}

export default function Avatar({ name, size = "md" }) {
  return (
    <div
      className={clsx(
        "flex shrink-0 items-center justify-center rounded-full font-semibold",
        size === "lg" ? "h-14 w-14 text-lg" : "h-8 w-8 text-xs",
        colourFor(name),
      )}
      aria-hidden="true"
    >
      {initials(name)}
    </div>
  );
}
