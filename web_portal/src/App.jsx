// All routes: public sign in, everything else behind RequireAuth inside the app shell.
import { Navigate, Route, Routes } from "react-router";
import RequireAuth from "@/components/RequireAuth";
import AppShell from "@/components/layout/AppShell";
import SignInPage from "@/pages/SignInPage";
import DashboardPage from "@/pages/dashboard/DashboardPage";
import EmployeesPage from "@/pages/employees/EmployeesPage";
import EmployeeDetailPage from "@/pages/employees/EmployeeDetailPage";
import DepartmentsPage from "@/pages/DepartmentsPage";
import SalaryStructuresPage from "@/pages/salary-structures/SalaryStructuresPage";

export default function App() {
  return (
    <Routes>
      <Route path="/sign-in" element={<SignInPage />} />
      <Route element={<RequireAuth />}>
        <Route element={<AppShell />}>
          <Route index element={<DashboardPage />} />
          <Route path="employees" element={<EmployeesPage />} />
          <Route path="employees/:id" element={<EmployeeDetailPage />} />
          <Route path="departments" element={<DepartmentsPage />} />
          <Route path="salary-structures" element={<SalaryStructuresPage />} />
        </Route>
      </Route>
      <Route path="*" element={<Navigate to="/" replace />} />
    </Routes>
  );
}
