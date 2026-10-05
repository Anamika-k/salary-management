// Left navigation: logo, main sections and the signed-in user with sign out.
import { NavLink, useNavigate } from "react-router";
import { Building2, LayoutDashboard, LogOut, Layers, Users } from "lucide-react";
import clsx from "clsx";
import { useAuth } from "@/lib/auth";
import Logo from "@/components/ui/Logo";

const NAV = [
  { to: "/", label: "Dashboard", icon: LayoutDashboard, end: true },
  { to: "/employees", label: "Employees", icon: Users },
  { to: "/departments", label: "Departments", icon: Building2 },
  { to: "/salary-structures", label: "Salary structures", icon: Layers },
];

function initials(name = "") {
  return name.split(" ").map((part) => part[0]).slice(0, 2).join("").toUpperCase();
}

export default function Sidebar({ onNavigate }) {
  const { user, signOut } = useAuth();
  const navigate = useNavigate();

  async function handleSignOut() {
    await signOut();
    navigate("/sign-in", { replace: true });
  }

  return (
    <div className="flex h-full flex-col px-3 py-4">
      <Logo className="px-2" />

      <nav className="mt-8 space-y-0.5">
        <p className="px-2 pb-2 text-[11px] font-medium uppercase tracking-wider text-zinc-400">Workspace</p>
        {NAV.map(({ to, label, icon: Icon, end }) => (
          <NavLink
            key={to}
            to={to}
            end={end}
            onClick={onNavigate}
            className={({ isActive }) =>
              clsx(
                "group flex items-center gap-2.5 rounded-lg px-2 py-1.5 text-sm transition-colors",
                isActive
                  ? "bg-white font-medium text-zinc-900 shadow-card ring-1 ring-zinc-200/70"
                  : "text-zinc-600 hover:bg-zinc-200/50 hover:text-zinc-900",
              )
            }
          >
            {({ isActive }) => (
              <>
                <Icon className={clsx("h-4 w-4", isActive ? "text-brand-600" : "text-zinc-400 group-hover:text-zinc-600")} />
                {label}
              </>
            )}
          </NavLink>
        ))}
      </nav>

      <div className="mt-auto flex items-center gap-2.5 rounded-xl px-2 py-2">
        <div className="flex h-8 w-8 shrink-0 items-center justify-center rounded-full bg-gradient-to-br from-brand-500 to-fuchsia-500 text-xs font-semibold text-white">
          {initials(user?.name)}
        </div>
        <div className="min-w-0 flex-1">
          <p className="truncate text-sm font-medium text-zinc-900">{user?.name}</p>
          <p className="truncate text-xs text-zinc-500">{user?.email}</p>
        </div>
        <button
          type="button"
          onClick={handleSignOut}
          aria-label="Sign out"
          title="Sign out"
          className="rounded-md p-1.5 text-zinc-400 hover:bg-zinc-200/60 hover:text-zinc-700"
        >
          <LogOut className="h-4 w-4" />
        </button>
      </div>
    </div>
  );
}
