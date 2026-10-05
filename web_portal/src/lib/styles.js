// Shared Tailwind class strings for form controls (inputs, selects, textareas).
import clsx from "clsx";

export const inputClass = clsx(
  "block w-full rounded-lg bg-white px-3 text-sm text-zinc-900 shadow-card",
  "ring-1 ring-inset ring-zinc-200 placeholder:text-zinc-400",
  "focus:outline-none focus:ring-2 focus:ring-brand-500 transition-shadow",
  "disabled:bg-zinc-50 disabled:text-zinc-500",
);
