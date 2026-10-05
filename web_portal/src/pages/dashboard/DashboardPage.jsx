// HR's home: headline numbers, pay per country, a drill-down into the selected
// country (departments, distribution, designations) and recent salary changes.
// Amounts stay in each country's own currency; the selected country is in the URL.
import { useSearchParams } from "react-router";
import { useAuth } from "@/lib/auth";
import { useByCountry, useByDepartment, useByDesignation, useSummary } from "@/lib/queries";
import { errorMessage } from "@/lib/errors";
import PageHeader from "@/components/ui/PageHeader";
import Alert from "@/components/ui/Alert";
import SummaryCards from "./SummaryCards";
import CountryCards from "./CountryCards";
import PayTable from "./PayTable";
import DistributionChart from "./DistributionChart";
import RecentChanges from "./RecentChanges";

function greeting() {
  const hour = new Date().getHours();
  if (hour < 12) return "Good morning";
  return hour < 18 ? "Good afternoon" : "Good evening";
}

function CountryDetail({ country }) {
  const departments = useByDepartment(country.country_code);
  const designations = useByDesignation(country.country_code);
  const departmentRows = departments.data?.groups.map((g) => ({ key: g.department.id, label: g.department.name, ...g }));
  const designationRows = designations.data?.groups.map((g) => ({ key: g.designation, label: g.designation, ...g }));

  return (
    <div className="grid gap-6 lg:grid-cols-3">
      <PayTable className="lg:col-span-2" title={`Departments in ${country.country_name}`}
        description="Annual cost, median and range per department" rows={departmentRows} currency={country.currency} />
      <DistributionChart country={country} />
      <PayTable className="self-start lg:col-span-2" title="Pay by designation" description="Highest total cost first"
        rows={designationRows} currency={country.currency} limit={8} />
      <RecentChanges />
    </div>
  );
}

export default function DashboardPage() {
  const { user } = useAuth() ?? {};
  const summary = useSummary();
  const countries = useByCountry();
  const [params, setParams] = useSearchParams();
  const selectedCode = params.get("country") ?? countries.data?.[0]?.country_code;
  const selected = countries.data?.find((c) => c.country_code === selectedCode);

  return (
    <>
      <PageHeader
        title={user ? `${greeting()}, ${user.name.split(" ")[0]}` : "Dashboard"}
        description="Headcount and pay across ACME. Amounts are in each country's own currency."
      />
      <div className="space-y-8">
        <SummaryCards summary={summary} />
        <section>
          <h2 className="mb-3 text-sm font-semibold text-zinc-900">Pay by country</h2>
          {countries.error && <Alert>{errorMessage(countries.error)}</Alert>}
          <CountryCards countries={countries.data} selected={selectedCode}
            onSelect={(code) => setParams({ country: code }, { replace: true })} />
        </section>
        {selected && <CountryDetail country={selected} />}
      </div>
    </>
  );
}
