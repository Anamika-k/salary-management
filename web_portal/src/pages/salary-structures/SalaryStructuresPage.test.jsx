import { screen, waitFor, within } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { Route, Routes } from "react-router";
import SalaryStructuresPage from "./SalaryStructuresPage";
import { jsonResponse, mockApi, renderWithProviders } from "@/test/helpers";
import { breakdown, page, structure, structuresList } from "@/test/fixtures";

function renderPage(routes = {}) {
  const fetch = mockApi({
    "GET /salary_structures": jsonResponse(page(structuresList)),
    "GET /salary_structures/1": jsonResponse({ data: structure }),
    "GET /salary_structures/1/preview": jsonResponse({ data: breakdown }),
    ...routes,
  });
  renderWithProviders(
    <Routes>
      <Route path="/salary-structures" element={<SalaryStructuresPage />} />
    </Routes>,
    { route: "/salary-structures" },
  );
  return fetch;
}

describe("SalaryStructuresPage", () => {
  it("lists structures and shows the first one's rules in order", async () => {
    renderPage();
    expect(await screen.findByRole("button", { name: /United Kingdom Standard/ })).toBeInTheDocument();
    const rows = await screen.findAllByRole("row");
    expect(within(rows[1]).getByText("Basic Salary")).toBeInTheDocument();
    expect(within(rows[1]).getByText("50% of gross")).toBeInTheDocument();
    expect(within(rows[2]).getByText("Remainder of gross")).toBeInTheDocument();
    expect(within(rows[3]).getByText("12% of Basic Salary")).toBeInTheDocument();
    expect(within(rows[4]).getByText("₹200 per month")).toBeInTheDocument();
  });

  it("previews the monthly breakdown for an annual salary", async () => {
    const fetch = renderPage();
    expect(await screen.findByText("₹94,000.00")).toBeInTheDocument();
    expect(fetch.mock.calls.some(([url]) => url.includes("preview?annual_salary="))).toBe(true);
  });

  it("edits a rule value", async () => {
    const fetch = renderPage({
      "PATCH /salary_structures/1/components/4": jsonResponse({ data: { ...structure.components[2], value: "10.0" } }),
    });
    await userEvent.click(await screen.findByRole("button", { name: "Edit Provident Fund" }));
    const input = screen.getByRole("spinbutton", { name: "Provident Fund value" });
    await userEvent.clear(input);
    await userEvent.type(input, "10{Enter}");
    await waitFor(() => {
      const call = fetch.mock.calls.find(([, o]) => o?.method === "PATCH");
      expect(JSON.parse(call[1].body)).toEqual({ component: { value: "10" } });
    });
  });

  it("shows the API error when a rule value is invalid", async () => {
    renderPage({
      "PATCH /salary_structures/1/components/4": jsonResponse(
        { error: "Validation failed: Value must be less than or equal to 100", code: "record_invalid", details: { value: ["must be less than or equal to 100"] } },
        { status: 422 },
      ),
    });
    await userEvent.click(await screen.findByRole("button", { name: "Edit Provident Fund" }));
    const input = screen.getByRole("spinbutton", { name: "Provident Fund value" });
    await userEvent.clear(input);
    await userEvent.type(input, "150{Enter}");
    expect(await screen.findByText("must be less than or equal to 100")).toBeInTheDocument();
  });

  it("does not offer editing for the remainder rule", async () => {
    renderPage();
    await screen.findAllByText("Special Allowance");
    expect(screen.queryByRole("button", { name: "Edit Special Allowance" })).not.toBeInTheDocument();
  });
});
