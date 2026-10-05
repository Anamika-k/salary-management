import { screen, waitFor, within } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { Route, Routes } from "react-router";
import DashboardPage from "./DashboardPage";
import { jsonResponse, mockApi, renderWithProviders } from "@/test/helpers";
import { insights } from "@/test/fixtures";

function renderPage(overrides = {}) {
  const fetch = mockApi({
    "GET /insights/summary": jsonResponse({ data: insights.summary }),
    "GET /insights/by_country": jsonResponse({ data: insights.byCountry }),
    "GET /insights/by_department": (url) => {
      const code = new URL(url).searchParams.get("country");
      return jsonResponse({ data: insights.byDepartment(code, code === "IN" ? "INR" : "USD") });
    },
    "GET /insights/by_designation": jsonResponse({ data: insights.byDesignation }),
    "GET /insights/distribution": jsonResponse({ data: insights.distribution }),
    "GET /insights/recent_changes": jsonResponse({ data: insights.recentChanges }),
    ...overrides,
  });
  renderWithProviders(
    <Routes>
      <Route path="/" element={<DashboardPage />} />
      <Route path="/employees/:id" element={<p>Employee page</p>} />
    </Routes>,
  );
  return fetch;
}

describe("DashboardPage", () => {
  it("shows headline numbers from the summary", async () => {
    renderPage();
    expect(await screen.findByText("10,000")).toBeInTheDocument();
    expect(screen.getByText("714")).toBeInTheDocument();
    expect(screen.getByText("264")).toBeInTheDocument();
    expect(screen.getByText("640")).toBeInTheDocument();
  });

  it("warns when paid employees have no salary", async () => {
    renderPage({ "GET /insights/summary": jsonResponse({ data: { ...insights.summary, paid_without_salary: 3 } }) });
    expect(await screen.findByRole("alert")).toHaveTextContent("3 employees have no salary");
  });

  it("shows each country's cost and median in its own currency", async () => {
    renderPage();
    const india = await screen.findByRole("button", { name: /India/ });
    expect(within(india).getByText("₹673.1Cr")).toBeInTheDocument();
    expect(within(india).getByText("₹13.3L")).toBeInTheDocument();
    expect(within(screen.getByRole("button", { name: /United States/ })).getByText("$295.3M")).toBeInTheDocument();
  });

  it("drills into the largest country first and switches when another is picked", async () => {
    const fetch = renderPage();
    expect(await screen.findByText("Engineering")).toBeInTheDocument();
    expect(screen.getByText("Engineering Manager")).toBeInTheDocument();

    await userEvent.click(screen.getByRole("button", { name: /United States/ }));
    expect(await screen.findByText("Sales")).toBeInTheDocument();
    await waitFor(() =>
      expect(fetch.mock.calls.some(([url]) => url.includes("by_department?country=US"))).toBe(true),
    );
  });

  it("draws the salary distribution with a count per band", async () => {
    renderPage();
    expect(await screen.findByRole("img", { name: /Salary distribution/ })).toBeInTheDocument();
    expect(screen.getByText("1,480")).toBeInTheDocument();
  });

  it("lists recent changes with the % change, linking to the employee", async () => {
    renderPage();
    const link = await screen.findByRole("link", { name: /Hannah Meyer/ });
    expect(link).toHaveAttribute("href", "/employees/7");
    expect(screen.getByText("+15.8%")).toBeInTheDocument();
  });
});
