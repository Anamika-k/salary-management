import { screen } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { Route, Routes } from "react-router";
import AppShell from "./AppShell";
import { tokenStore } from "@/lib/api";
import { jsonResponse, mockApi, renderWithProviders } from "@/test/helpers";

const me = { id: 1, name: "Hana Ray", email: "hr@acme.com" };

function renderShell() {
  return renderWithProviders(
    <Routes>
      <Route path="/sign-in" element={<p>Sign in page</p>} />
      <Route element={<AppShell />}>
        <Route path="/" element={<p>Dashboard body</p>} />
      </Route>
    </Routes>,
  );
}

describe("AppShell", () => {
  beforeEach(() => tokenStore.set("Bearer ok"));

  it("shows navigation, the page and the signed-in user", async () => {
    mockApi({ "GET /auth/me": jsonResponse({ user: me }) });
    renderShell();

    expect(await screen.findByText("Hana Ray")).toBeInTheDocument();
    expect(screen.getByText("Dashboard body")).toBeInTheDocument();
    for (const name of ["Dashboard", "Employees", "Departments", "Salary structures"]) {
      expect(screen.getByRole("link", { name })).toBeInTheDocument();
    }
  });

  it("signs out: revokes the token on the API and returns to sign in", async () => {
    const fetch = mockApi({
      "GET /auth/me": jsonResponse({ user: me }),
      "DELETE /auth/sign_out": jsonResponse(null, { status: 204 }),
    });
    renderShell();
    await userEvent.click(await screen.findByRole("button", { name: "Sign out" }));

    expect(await screen.findByText("Sign in page")).toBeInTheDocument();
    expect(tokenStore.get()).toBeNull();
    expect(fetch.mock.calls.some(([, o]) => o?.method === "DELETE")).toBe(true);
  });
});
