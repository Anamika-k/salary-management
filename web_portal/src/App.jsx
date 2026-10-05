// All routes: public sign in, everything else behind RequireAuth inside the app shell.
import { Navigate, Route, Routes } from "react-router";
import RequireAuth from "@/components/RequireAuth";
import AppShell from "@/components/layout/AppShell";
import PageHeader from "@/components/ui/PageHeader";
import SignInPage from "@/pages/SignInPage";
import EmployeesPage from "@/pages/employees/EmployeesPage";
import EmployeeDetailPage from "@/pages/employees/EmployeeDetailPage";

export default function App() {
  return (
    <Routes>
      <Route path="/sign-in" element={<SignInPage />} />
      <Route element={<RequireAuth />}>
        <Route element={<AppShell />}>
          <Route index element={<PageHeader title="Dashboard" description="Pay insights will appear here." />} />
          <Route path="employees" element={<EmployeesPage />} />
          <Route path="employees/:id" element={<EmployeeDetailPage />} />
        </Route>
      </Route>
      <Route path="*" element={<Navigate to="/" replace />} />
    </Routes>
  );
}
