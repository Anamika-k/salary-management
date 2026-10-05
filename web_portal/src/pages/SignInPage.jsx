// Sign in for the HR Manager. After success, returns to the page they asked for
// (?next=/path, same-site paths only) or the dashboard.
import { useState } from "react";
import { Navigate, useSearchParams } from "react-router";
import { ArrowRight, Eye, EyeOff } from "lucide-react";
import { useAuth } from "@/lib/auth";
import Button from "@/components/ui/Button";
import Field from "@/components/ui/Field";
import Logo from "@/components/ui/Logo";
import Spinner from "@/components/ui/Spinner";
import AuthShowcase from "@/components/AuthShowcase";

function safeNext(next) {
  return next?.startsWith("/") && !next.startsWith("//") ? next : "/";
}

export default function SignInPage() {
  const { user, signIn } = useAuth();
  const [params] = useSearchParams();
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [showPassword, setShowPassword] = useState(false);
  const [error, setError] = useState(null);
  const [submitting, setSubmitting] = useState(false);

  if (user) return <Navigate to={safeNext(params.get("next"))} replace />;

  async function handleSubmit(event) {
    event.preventDefault();
    setError(null);
    setSubmitting(true);
    try {
      await signIn(email, password);
    } catch (err) {
      setError(err.message);
    } finally {
      setSubmitting(false);
    }
  }

  const toggle = (
    <button
      type="button"
      onClick={() => setShowPassword((s) => !s)}
      aria-label={showPassword ? "Hide password" : "Show password"}
      className="rounded-md p-2 text-zinc-400 hover:text-zinc-700"
    >
      {showPassword ? <EyeOff className="h-4 w-4" /> : <Eye className="h-4 w-4" />}
    </button>
  );

  return (
    <div className="grid min-h-screen bg-white lg:grid-cols-[1fr_1.1fr]">
      <div className="flex flex-col px-6 py-8 sm:px-12">
        <Logo />
        <div className="mx-auto flex w-full max-w-sm flex-1 flex-col justify-center py-12">
          <h1 className="text-2xl font-semibold tracking-tight">Welcome back</h1>
          <p className="mt-2 text-sm text-zinc-500">Sign in to manage people and pay across ACME.</p>

          <form onSubmit={handleSubmit} className="mt-8 space-y-4" noValidate>
            {error && (
              <div role="alert" className="rounded-lg bg-red-50 px-3 py-2.5 text-sm text-red-700 ring-1 ring-inset ring-red-100">
                {error}
              </div>
            )}
            <Field label="Email" type="email" autoComplete="email" placeholder="you@acme.com" required
              value={email} onChange={(e) => setEmail(e.target.value)} />
            <Field label="Password" type={showPassword ? "text" : "password"} autoComplete="current-password"
              placeholder="••••••••" required trailing={toggle}
              value={password} onChange={(e) => setPassword(e.target.value)} />
            <Button type="submit" size="lg" className="w-full" disabled={submitting}>
              {submitting ? <><Spinner /> Signing in…</> : <>Sign in <ArrowRight className="h-4 w-4" /></>}
            </Button>
          </form>
        </div>
        <p className="text-xs text-zinc-400">© {new Date().getFullYear()} ACME Inc. · HR only</p>
      </div>
      <AuthShowcase />
    </div>
  );
}
