import { screen } from "@testing-library/react";
import { Route, Routes, useLocation } from "react-router";
import RequireAuth from "./RequireAuth";
import { tokenStore } from "@/lib/api";
import { jsonResponse, mockApi, renderWithProviders } from "@/test/helpers";

function SignInProbe() {
  const location = useLocation();
  return <p>Sign in page {location.search}</p>;
}

function renderGuarded(route = "/employees") {
  return renderWithProviders(
    <Routes>
      <Route path="/sign-in" element={<SignInProbe />} />
      <Route element={<RequireAuth />}>
        <Route path="/employees" element={<p>Secret list</p>} />
      </Route>
    </Routes>,
    { route },
  );
}

describe("RequireAuth", () => {
  it("sends signed-out visitors to sign in, remembering where they were going", async () => {
    renderGuarded("/employees?page=2");
    expect(await screen.findByText(/Sign in page/)).toHaveTextContent(
      "?next=%2Femployees%3Fpage%3D2",
    );
  });

  it("shows the page when the stored token is valid", async () => {
    tokenStore.set("Bearer ok");
    mockApi({ "GET /auth/me": jsonResponse({ user: { id: 1, name: "Hana", email: "hr@acme.com" } }) });
    renderGuarded();
    expect(await screen.findByText("Secret list")).toBeInTheDocument();
  });

  it("shows a loader while checking the token", () => {
    tokenStore.set("Bearer ok");
    mockApi({ "GET /auth/me": () => new Promise(() => {}) });
    renderGuarded();
    expect(screen.getByRole("status")).toBeInTheDocument();
  });

  it("sends the user to sign in when the token has expired", async () => {
    tokenStore.set("Bearer expired");
    mockApi({ "GET /auth/me": jsonResponse({ error: "Expired" }, { status: 401 }) });
    renderGuarded();
    expect(await screen.findByText(/Sign in page/)).toBeInTheDocument();
    expect(tokenStore.get()).toBeNull();
  });
});
