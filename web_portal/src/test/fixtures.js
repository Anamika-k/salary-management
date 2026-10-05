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

export function page(data, meta = {}) {
  return {
    data,
    meta: { current_page: 1, total_pages: data.length ? 1 : 0, total_count: data.length, per_page: 25, ...meta },
  };
}
