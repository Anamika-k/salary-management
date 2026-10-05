import { screen, waitFor, within } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { Route, Routes } from "react-router";
import EmployeeDetailPage from "./EmployeeDetailPage";
import { jsonResponse, mockApi, renderWithProviders } from "@/test/helpers";
import { breakdown, employee, filters, page, salaries, structuresList } from "@/test/fixtures";

const baseRoutes = {
  "GET /employees/1": jsonResponse({ data: employee }),
  "GET /employees/1/salaries/breakdown": jsonResponse({ data: breakdown }),
  "GET /employees/1/salaries": jsonResponse(page(salaries)),
  "GET /employees/1/audit_logs": jsonResponse(page([])),
  "GET /salary_structures": jsonResponse(page(structuresList)),
  "GET /filters": jsonResponse({ data: filters }),
};

function renderPage(routes = {}) {
  const fetch = mockApi({ ...baseRoutes, ...routes });
  renderWithProviders(
    <Routes>
      <Route path="/employees" element={<p>Employees list</p>} />
      <Route path="/employees/:id" element={<EmployeeDetailPage />} />
    </Routes>,
    { route: "/employees/1" },
  );
  return fetch;
}

describe("EmployeeDetailPage", () => {
  it("shows the employee, current salary and this month's breakdown", async () => {
    renderPage();
    expect(await screen.findByRole("heading", { name: "Asha Verma" })).toBeInTheDocument();
    expect(screen.getByText("₹12,00,000")).toBeInTheDocument();
    expect(await screen.findByText("Provident Fund")).toBeInTheDocument();
    expect(screen.getAllByText("₹94,000.00").length).toBeGreaterThan(0);
  });

  it("asks for the breakdown on the chosen date", async () => {
    const fetch = renderPage();
    const dateInput = await screen.findByLabelText("Breakdown on");
    await userEvent.clear(dateInput);
    await userEvent.type(dateInput, "2024-06-01");
    await waitFor(() =>
      expect(fetch.mock.calls.some(([url]) => url.includes("breakdown?on=2024-06-01"))).toBe(true),
    );
  });

  it("explains when there was no salary on that date", async () => {
    renderPage({
      "GET /employees/1/salaries/breakdown": jsonResponse({ error: "Not found", code: "not_found" }, { status: 404 }),
    });
    expect(await screen.findByText("No salary on this date")).toBeInTheDocument();
  });

  it("shows salary history with change types", async () => {
    renderPage();
    await userEvent.click(await screen.findByRole("tab", { name: "Salary history" }));
    expect(screen.getByText("Increment")).toBeInTheDocument();
    expect(screen.getByText("Joining")).toBeInTheDocument();
    expect(screen.getByText("Annual review")).toBeInTheDocument();
  });

  it("records a salary change and shows a rule error from the API", async () => {
    const fetch = renderPage({
      "POST /employees/1/salaries": jsonResponse(
        { error: "Must start after the current salary", code: "invalid_salary_change", details: {} },
        { status: 422 },
      ),
    });
    await userEvent.click(await screen.findByRole("button", { name: /Change salary/ }));
    const dialog = screen.getByRole("dialog");
    await userEvent.type(within(dialog).getByLabelText("New annual salary"), "1300000");
    await userEvent.click(within(dialog).getByRole("button", { name: "Save change" }));

    expect(await within(dialog).findByRole("alert")).toHaveTextContent("Must start after the current salary");
    const body = JSON.parse(fetch.mock.calls.find(([, o]) => o?.method === "POST")[1].body);
    expect(body.salary).toMatchObject({ annual_salary: "1300000", salary_structure_id: 1, change_type: "increment" });
  });

  it("deletes the employee after confirmation and returns to the list", async () => {
    renderPage({ "DELETE /employees/1": jsonResponse(null, { status: 204 }) });
    await userEvent.click(await screen.findByRole("button", { name: "Delete" }));
    await userEvent.click(within(screen.getByRole("dialog")).getByRole("button", { name: "Delete employee" }));
    expect(await screen.findByText("Employees list")).toBeInTheDocument();
  });

  it("shows not found for a deleted or unknown employee", async () => {
    renderPage({ "GET /employees/1": jsonResponse({ error: "Couldn't find Employee", code: "not_found" }, { status: 404 }) });
    expect(await screen.findByText("Couldn't find Employee")).toBeInTheDocument();
  });
});
