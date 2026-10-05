// Sample API payloads shaped exactly like the Rails serializers return them.
export const filters = {
  departments: [{ id: 1, name: "Engineering" }, { id: 2, name: "Finance" }],
  countries: [
    { code: "IN", name: "India", currency: "INR" },
    { code: "GB", name: "United Kingdom", currency: "GBP" },
  ],
  designations: ["Software Engineer", "Accountant"],
  employment_statuses: ["active", "on_leave", "terminated"],
};

export const employeeLite = {
  id: 1,
  employee_code: "EMP000001",
  full_name: "Asha Verma",
  email: "asha@acme.com",
  designation: "Software Engineer",
  country_code: "IN",
  employment_status: "active",
  department: { id: 1, name: "Engineering" },
  current_salary: { annual_salary: "1200000.0", currency: "INR" },
};

export const employee = {
  ...employeeLite,
  first_name: "Asha",
  last_name: "Verma",
  joining_date: "2024-04-01",
  exit_date: null,
  country: { code: "IN", name: "India", currency: "INR" },
  current_salary: {
    annual_salary: "1200000.0",
    currency: "INR",
    effective_from: "2025-04-01",
    salary_structure: { id: 1, name: "India Standard" },
  },
};

export const breakdown = {
  annual_salary: "1200000.0",
  currency: "INR",
  monthly_gross: "100000.0",
  earnings: [
    { code: "BASIC", name: "Basic Salary", amount: "50000.0" },
    { code: "SPECIAL", name: "Special Allowance", amount: "50000.0" },
  ],
  deductions: [{ code: "PF", name: "Provident Fund", amount: "6000.0" }],
  total_earnings: "100000.0",
  total_deductions: "6000.0",
  net_pay: "94000.0",
  effective_from: "2025-04-01",
  effective_to: null,
};

export const salaries = [
  {
    id: 2, annual_salary: "1200000.0", currency: "INR", effective_from: "2025-04-01", effective_to: null,
    change_type: "increment", notes: "Annual review", created_at: "2025-03-20T10:00:00Z",
    salary_structure: { id: 1, name: "India Standard" }, created_by: { id: 1, name: "HR Manager" },
  },
  {
    id: 1, annual_salary: "1000000.0", currency: "INR", effective_from: "2024-04-01", effective_to: "2025-03-31",
    change_type: "joining", notes: null, created_at: "2024-03-20T10:00:00Z",
    salary_structure: { id: 1, name: "India Standard" }, created_by: { id: 1, name: "HR Manager" },
  },
];

export const structuresList = [
  { id: 1, code: "IN_STD", name: "India Standard", country_code: "IN", description: "Standard pay structure for India", currency: "INR" },
  { id: 3, code: "GB_STD", name: "United Kingdom Standard", country_code: "GB", description: "Standard pay structure for the UK", currency: "GBP" },
];

export const structure = {
  ...structuresList[0],
  components: [
    { id: 1, position: 1, calculation_method: "percentage_of_gross", value: "50.0",
      component: { id: 1, code: "BASIC", name: "Basic Salary", component_type: "earning" }, base_component: null },
    { id: 3, position: 2, calculation_method: "remainder", value: null,
      component: { id: 3, code: "SPECIAL", name: "Special Allowance", component_type: "earning" }, base_component: null },
    { id: 4, position: 3, calculation_method: "percentage_of_component", value: "12.0",
      component: { id: 4, code: "PF", name: "Provident Fund", component_type: "deduction" },
      base_component: { id: 1, code: "BASIC", name: "Basic Salary" } },
    { id: 5, position: 4, calculation_method: "fixed", value: "200.0",
      component: { id: 5, code: "PROF_TAX", name: "Professional Tax", component_type: "deduction" }, base_component: null },
  ],
};

export const insights = {
  summary: {
    headcount: { total: 10000, active: 8513, on_leave: 485, terminated: 1002 },
    joiners_this_year: 714, leavers_this_year: 264, salary_changes_last_30_days: 640,
    paid_without_salary: 0, countries: 6,
  },
  byCountry: [
    { country_code: "IN", country_name: "India", currency: "INR", headcount: 4624, total_cost: "6730797000.0",
      average: "1455622.19", median: "1332500.0", minimum: "511000.0", maximum: "4633000.0" },
    { country_code: "US", country_name: "United States", currency: "USD", headcount: 1714, total_cost: "295329000.0",
      average: "172303.97", median: "160500.0", minimum: "60000.0", maximum: "511000.0" },
  ],
  byDepartment: (code, currency) => ({
    country: { code, name: code === "IN" ? "India" : "United States", currency },
    groups: [
      { department: { id: 1, name: code === "IN" ? "Engineering" : "Sales" }, headcount: 1361, total_cost: "2231445000.0",
        average: "1639562.82", median: "1531000.0", minimum: "516000.0", maximum: "4633000.0" },
    ],
  }),
  byDesignation: {
    country: { code: "IN", name: "India", currency: "INR" },
    groups: [
      { designation: "Engineering Manager", headcount: 328, total_cost: "803680000.0", average: "2450243.9",
        median: "2347500.0", minimum: "1429000.0", maximum: "4633000.0" },
    ],
  },
  distribution: {
    country: { code: "IN", name: "India", currency: "INR" }, currency: "INR", headcount: 2733,
    bands: [
      { from: "500000.0", to: "1000000.0", count: 1253 },
      { from: "1000000.0", to: "1500000.0", count: 1480 },
    ],
  },
  recentChanges: [
    { id: 9, change_type: "promotion", effective_from: "2026-09-30", annual_salary: "139000.0", currency: "EUR",
      previous_salary: "120000.0", change_percent: "15.8",
      employee: { id: 7, full_name: "Hannah Meyer", employee_code: "EMP008879", designation: "Account Manager", department: "Sales" } },
  ],
};

export function page(data, meta = {}) {
  return {
    data,
    meta: { current_page: 1, total_pages: data.length ? 1 : 0, total_count: data.length, per_page: 25, ...meta },
  };
}
