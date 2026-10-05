// Frame for every signed-in page: sidebar on desktop, slide-in menu on mobile,
// and the page content (child route) in a centred column.
import { useState } from "react";
import { Outlet } from "react-router";
import { Menu, X } from "lucide-react";
import Sidebar from "./Sidebar";
import Logo from "@/components/ui/Logo";

export default function AppShell() {
  const [menuOpen, setMenuOpen] = useState(false);

  return (
    <div className="min-h-screen bg-zinc-50">
      <aside className="fixed inset-y-0 left-0 hidden w-60 border-r border-zinc-200/70 bg-zinc-100/60 md:block">
        <Sidebar />
      </aside>

      <header className="sticky top-0 z-20 flex h-14 items-center justify-between border-b border-zinc-200/70 bg-white/80 px-4 backdrop-blur md:hidden">
        <Logo />
        <button type="button" onClick={() => setMenuOpen(true)} aria-label="Open menu" className="rounded-md p-2 text-zinc-600">
          <Menu className="h-5 w-5" />
        </button>
      </header>

      {menuOpen && (
        <div className="fixed inset-0 z-30 md:hidden">
          <div className="absolute inset-0 bg-zinc-900/30 backdrop-blur-sm" onClick={() => setMenuOpen(false)} />
          <aside className="absolute inset-y-0 left-0 w-64 bg-zinc-50 shadow-pop">
            <button type="button" onClick={() => setMenuOpen(false)} aria-label="Close menu"
              className="absolute right-3 top-4 rounded-md p-1.5 text-zinc-500">
              <X className="h-4 w-4" />
            </button>
            <Sidebar onNavigate={() => setMenuOpen(false)} />
          </aside>
        </div>
      )}

      <main className="md:pl-60">
        <div className="mx-auto max-w-6xl px-4 py-8 sm:px-8">
          <Outlet />
        </div>
      </main>
    </div>
  );
}
