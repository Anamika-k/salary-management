// "What would someone earning X take home?" Type an annual salary and see the
// monthly breakdown under the selected structure, recalculated by the API.
import { useState } from "react";
import { usePreview } from "@/lib/queries";
import { useDebouncedValue } from "@/lib/hooks";
import { errorMessage } from "@/lib/errors";
import Card, { CardHeader } from "@/components/ui/Card";
import Field from "@/components/ui/Field";
import Alert from "@/components/ui/Alert";
import BreakdownCard from "@/components/BreakdownCard";

// A typical salary per currency so the preview is useful straight away.
const SAMPLE_SALARY = { INR: 1200000, USD: 90000, GBP: 60000, EUR: 65000, SGD: 84000, AED: 240000 };

export default function PreviewPanel({ structure }) {
  const [amount, setAmount] = useState(String(SAMPLE_SALARY[structure.currency] ?? 100000));
  const debounced = useDebouncedValue(amount);
  const preview = usePreview(String(structure.id), debounced);

  return (
    <Card>
      <CardHeader title="Preview" description="Monthly breakdown for an annual salary under these rules." />
      <div className="grid gap-6 p-5 md:grid-cols-[220px_1fr]">
        <Field label="Annual salary" type="number" min="1" step="1000" value={amount}
          onChange={(e) => setAmount(e.target.value)} hint={`Gross per year in ${structure.currency}`} />
        <div className="min-w-0">
          {preview.error && <Alert>{errorMessage(preview.error)}</Alert>}
          {!preview.error && preview.data && <BreakdownCard breakdown={preview.data} />}
          {!preview.data && !preview.error && <p className="text-sm text-zinc-400">Enter an amount above zero.</p>}
        </div>
      </div>
    </Card>
  );
}
