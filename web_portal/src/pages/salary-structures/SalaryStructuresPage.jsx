// Salary structures per country: pick one, see its rules in calculation order,
// tweak a rule's value, and preview the breakdown for any annual salary.
import { useSearchParams } from "react-router";
import clsx from "clsx";
import { useStructure, useStructures } from "@/lib/queries";
import { errorMessage } from "@/lib/errors";
import { flag } from "@/lib/format";
import PageHeader from "@/components/ui/PageHeader";
import Card, { CardHeader } from "@/components/ui/Card";
import Alert from "@/components/ui/Alert";
import { PageLoader } from "@/components/ui/Spinner";
import RulesTable from "./RulesTable";
import PreviewPanel from "./PreviewPanel";

export default function SalaryStructuresPage() {
  const [params, setParams] = useSearchParams();
  const structures = useStructures();
  const selectedId = params.get("structure") ?? structures.data?.[0]?.id;
  const structure = useStructure(selectedId && String(selectedId));

  return (
    <>
      <PageHeader title="Salary structures" description="How each country's annual salary splits into monthly earnings and deductions." />
      {structures.error && <Alert>{errorMessage(structures.error)}</Alert>}

      <div className="grid gap-6 lg:grid-cols-[240px_1fr]">
        <nav className="space-y-1" aria-label="Salary structures">
          {structures.data?.map((s) => {
            const active = String(s.id) === String(selectedId);
            return (
              <button
                key={s.id}
                type="button"
                onClick={() => setParams({ structure: s.id })}
                className={clsx(
                  "flex w-full items-center gap-3 rounded-xl px-3 py-2.5 text-left transition-colors",
                  active ? "bg-white shadow-card ring-1 ring-zinc-200/70" : "hover:bg-zinc-100",
                )}
              >
                <span className="text-xl leading-none">{flag(s.country_code)}</span>
                <span className="min-w-0 flex-1">
                  <span className={clsx("block truncate text-sm", active ? "font-medium text-zinc-900" : "text-zinc-700")}>{s.name}</span>
                  <span className="block text-xs text-zinc-400">{s.code} · {s.currency}</span>
                </span>
              </button>
            );
          })}
        </nav>

        <div className="min-w-0 space-y-6">
          {structure.isPending && selectedId && <PageLoader />}
          {structure.error && <Alert>{errorMessage(structure.error)}</Alert>}
          {structure.data && (
            <>
              <Card>
                <CardHeader title={`${structure.data.name} rules`} description="Applied top to bottom; a percentage can use any earlier line. Values are editable." />
                <RulesTable structure={structure.data} />
              </Card>
              <PreviewPanel key={structure.data.id} structure={structure.data} />
            </>
          )}
        </div>
      </div>
    </>
  );
}
