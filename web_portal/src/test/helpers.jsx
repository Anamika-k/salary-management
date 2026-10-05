// Test helpers: fake fetch responses and render inside the app's providers.
import { render } from "@testing-library/react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { MemoryRouter } from "react-router";
import { AuthProvider } from "@/lib/auth";

export function jsonResponse(body, { status = 200, headers = {} } = {}) {
  return new Response(status === 204 ? null : JSON.stringify(body), {
    status,
    headers: { "Content-Type": "application/json", ...headers },
  });
}

// Routes fetch calls by "METHOD /path" to canned responses.
export function mockApi(routes) {
  return vi.spyOn(globalThis, "fetch").mockImplementation(async (url, options = {}) => {
    const key = `${options.method ?? "GET"} ${new URL(url).pathname.replace("/api/v1", "")}`;
    const handler = routes[key];
    if (!handler) throw new Error(`Unmocked request: ${key}`);
    return typeof handler === "function" ? handler(url, options) : handler.clone();
  });
}

export function renderWithProviders(ui, { route = "/" } = {}) {
  const queryClient = new QueryClient({ defaultOptions: { queries: { retry: false } } });
  return render(
    <QueryClientProvider client={queryClient}>
      <MemoryRouter initialEntries={[route]}>
        <AuthProvider>{ui}</AuthProvider>
      </MemoryRouter>
    </QueryClientProvider>,
  );
}
