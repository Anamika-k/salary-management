import { screen, waitFor } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { Route, Routes } from "react-router";
import SignInPage from "./SignInPage";
import { tokenStore } from "@/lib/api";
import { jsonResponse, mockApi, renderWithProviders } from "@/test/helpers";

const user = { id: 1, name: "Hana Ray", email: "hr@acme.com" };

function renderPage(route = "/sign-in") {
  return renderWithProviders(
    <Routes>
      <Route path="/sign-in" element={<SignInPage />} />
      <Route path="/" element={<p>Home page</p>} />
      <Route path="/employees" element={<p>Employees page</p>} />
    </Routes>,
    { route },
  );
}

async function fillAndSubmit(email = "hr@acme.com", password = "Secret123!") {
  await userEvent.type(screen.getByLabelText("Email"), email);
  await userEvent.type(screen.getByLabelText("Password"), password);
  await userEvent.click(screen.getByRole("button", { name: "Sign in" }));
}

describe("SignInPage", () => {
  it("signs in, stores the token and goes to the home page", async () => {
    const fetch = mockApi({
      "POST /auth/sign_in": jsonResponse({ user }, { headers: { Authorization: "Bearer t1" } }),
    });
    renderPage();
    await fillAndSubmit();

    expect(await screen.findByText("Home page")).toBeInTheDocument();
    expect(tokenStore.get()).toBe("Bearer t1");
    expect(JSON.parse(fetch.mock.calls[0][1].body)).toEqual({
      user: { email: "hr@acme.com", password: "Secret123!" },
    });
  });

  it("returns to the page the user originally asked for", async () => {
    mockApi({ "POST /auth/sign_in": jsonResponse({ user }, { headers: { Authorization: "Bearer t1" } }) });
    renderPage("/sign-in?next=/employees");
    await fillAndSubmit();
    expect(await screen.findByText("Employees page")).toBeInTheDocument();
  });

  it("ignores an external next URL", async () => {
    mockApi({ "POST /auth/sign_in": jsonResponse({ user }, { headers: { Authorization: "Bearer t1" } }) });
    renderPage("/sign-in?next=//evil.com");
    await fillAndSubmit();
    expect(await screen.findByText("Home page")).toBeInTheDocument();
  });

  it("shows the API error for wrong credentials and stays on the page", async () => {
    mockApi({ "POST /auth/sign_in": jsonResponse({ error: "Invalid Email or password." }, { status: 401 }) });
    renderPage();
    await fillAndSubmit("hr@acme.com", "wrong");

    expect(await screen.findByRole("alert")).toHaveTextContent("Invalid Email or password.");
    expect(screen.getByLabelText("Password")).toBeInTheDocument();
  });

  it("disables the button while signing in", async () => {
    let resolve;
    mockApi({ "POST /auth/sign_in": () => new Promise((r) => (resolve = r)) });
    renderPage();
    await fillAndSubmit();

    expect(screen.getByRole("button", { name: /Signing in/ })).toBeDisabled();
    resolve(jsonResponse({ user }, { headers: { Authorization: "Bearer t1" } }));
    await screen.findByText("Home page");
  });

  it("redirects away when already signed in", async () => {
    tokenStore.set("Bearer t1");
    mockApi({ "GET /auth/me": jsonResponse({ user }) });
    renderPage();
    await waitFor(() => expect(screen.getByText("Home page")).toBeInTheDocument());
  });
});
