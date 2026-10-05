// Route guard: shows child routes only to a signed-in user. Others go to
// sign in with ?next= so they land back where they were heading.
import { Navigate, Outlet, useLocation } from "react-router";
import { useAuth } from "@/lib/auth";
import { PageLoader } from "@/components/ui/Spinner";

export default function RequireAuth() {
  const { user, isChecking } = useAuth();
  const location = useLocation();

  if (isChecking) return <PageLoader />;
  if (!user) {
    const next = encodeURIComponent(location.pathname + location.search);
    return <Navigate to={`/sign-in?next=${next}`} replace />;
  }
  return <Outlet />;
}
