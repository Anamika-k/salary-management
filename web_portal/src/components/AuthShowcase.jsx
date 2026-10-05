// Decorative right-hand panel on sign in: a glimpse of the product
// (a payslip breakdown card) on a soft gradient. Purely visual, hidden on mobile.
import { TrendingUp } from "lucide-react";

const LINES = [
  ["Basic", "62,500"],
  ["House rent allowance", "25,000"],
  ["Special allowance", "37,500"],
  ["Provident fund", "−7,500", true],
  ["Professional tax", "−200", true],
];

export default function AuthShowcase() {
  return (
    <div className="relative m-3 hidden overflow-hidden rounded-3xl bg-zinc-950 lg:block" aria-hidden="true">
      <div className="absolute -left-24 -top-24 h-96 w-96 rounded-full bg-brand-600/40 blur-3xl" />
      <div className="absolute -bottom-32 right-0 h-[28rem] w-[28rem] rounded-full bg-fuchsia-500/20 blur-3xl" />
      <div className="absolute inset-0 bg-[radial-gradient(rgb(255_255_255/0.06)_1px,transparent_1px)] [background-size:22px_22px]" />

      <div className="relative flex h-full flex-col justify-between p-12">
        <div className="max-w-md">
          <p className="text-sm font-medium text-brand-200">Salary management</p>
          <h2 className="mt-3 text-3xl font-semibold leading-tight tracking-tight text-white">
            People, pay and history in one calm place.
          </h2>
        </div>

        <div className="relative mx-auto w-full max-w-sm">
          <div className="absolute -right-6 -top-5 z-10 flex items-center gap-2 rounded-full bg-white px-3 py-1.5 text-xs font-medium text-zinc-800 shadow-pop">
            <TrendingUp className="h-3.5 w-3.5 text-emerald-600" /> Increment applied · +8%
          </div>
          <div className="rounded-2xl bg-white/95 p-5 shadow-pop backdrop-blur">
            <div className="flex items-center gap-3">
              <div className="flex h-9 w-9 items-center justify-center rounded-full bg-brand-100 text-sm font-semibold text-brand-700">PS</div>
              <div>
                <p className="text-sm font-medium text-zinc-900">Priya Sharma</p>
                <p className="text-xs text-zinc-500">Senior Engineer · Bengaluru</p>
              </div>
            </div>
            <div className="mt-4 space-y-2 border-t border-dashed border-zinc-200 pt-4">
              {LINES.map(([label, amount, deduction]) => (
                <div key={label} className="flex justify-between text-[13px]">
                  <span className="text-zinc-500">{label}</span>
                  <span className={`tabular ${deduction ? "text-zinc-400" : "text-zinc-800"}`}>₹{amount}</span>
                </div>
              ))}
            </div>
            <div className="mt-4 flex items-baseline justify-between rounded-xl bg-zinc-50 px-3 py-2.5">
              <span className="text-xs font-medium text-zinc-500">Net pay / month</span>
              <span className="tabular text-lg font-semibold text-zinc-900">₹1,17,300</span>
            </div>
          </div>
        </div>

        <p className="text-sm text-zinc-400">10,000 employees · 6 countries · every change audited</p>
      </div>
    </div>
  );
}
