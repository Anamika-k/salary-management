import { screen, waitFor, within } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { Route, Routes } from "react-router";
import EmployeesPage from "./EmployeesPage";
import { jsonResponse, mockApi, renderWithProviders } from "@/test/helpers";
import { filters, employeeLite, page } from "@/test/fixtures";

function renderPage(route = "/employees") {
  return renderWithProviders(
    <Routes>
      <Route path="/employees" element={<EmployeesPage />} />
      <Route path="/employees/:id" element={<p>Detail page</p>} />
    </Routes>,
    { route },
  );
}

const lastListUrl = (fetch) =>
  new URL(fetch.mock.calls.map(([url]) => url).filter((url) => url.includes("/employees?") || url.endsWith("/employees")).at(-1));

describe("EmployeesPage", () => {
  it("lists employees with department, status and current salary", async () => {
    mockApi({ "GET /filters": jsonResponse({ data: filters }), "GET /employees": jsonResponse(page([employeeLite])) });
    renderPage();

    const row = (await screen.findByText("Asha Verma")).closest("tr");
    expect(within(row).getByText("EMP000001")).toBeInTheDocument();
    expect(within(row).getByText("Engineering")).toBeInTheDocument();
    expect(within(row).getByText("Active")).toBeInTheDocument();
    expect(within(row).getByText("₹12,00,000")).toBeInTheDocument();
    expect(screen.getByText(/1 employee/)).toBeInTheDocument();
  });

  it("shows a dash when an employee has no salary yet", async () => {
    mockApi({
      "GET /filters": jsonResponse({ data: filters }),
      "GET /employees": jsonResponse(page([{ ...employeeLite, current_salary: null }])),
    });
    renderPage();
    const row = (await screen.findByText("Asha Verma")).closest("tr");
    expect(within(row).getByText("—")).toBeInTheDocument();
  });

  it("searches as you type (debounced) and resets to page 1", async () => {
    const fetch = mockApi({ "GET /filters": jsonResponse({ data: filters }), "GET /employees": () => jsonResponse(page([employeeLite])) });
    renderPage("/employees?page=3");
    await screen.findByText("Asha Verma");

    await userEvent.type(screen.getByPlaceholderText(/Search/), "asha");
    await waitFor(() => expect(lastListUrl(fetch).searchParams.get("q")).toBe("asha"));
    expect(lastListUrl(fetch).searchParams.get("page")).toBe("1");
  });

  it("filters by department", async () => {
    const fetch = mockApi({ "GET /filters": jsonResponse({ data: filters }), "GET /employees": () => jsonResponse(page([employeeLite])) });
    renderPage();
    await screen.findByText("Asha Verma");

    await userEvent.selectOptions(screen.getByLabelText("Department"), "Engineering");
    await waitFor(() => expect(lastListUrl(fetch).searchParams.get("department_id")).toBe("1"));
  });

  it("shows an empty state when nothing matches", async () => {
    mockApi({ "GET /filters": jsonResponse({ data: filters }), "GET /employees": jsonResponse(page([])) });
    renderPage("/employees?q=zzz");
    expect(await screen.findByText("No employees found")).toBeInTheDocument();
  });

  it("pages through results", async () => {
    const fetch = mockApi({
      "GET /filters": jsonResponse({ data: filters }),
      "GET /employees": () => jsonResponse(page([employeeLite], { total_pages: 3, total_count: 60 })),
    });
    renderPage();
    await screen.findByText("Asha Verma");
    await userEvent.click(screen.getByRole("button", { name: "Next page" }));
    await waitFor(() => expect(lastListUrl(fetch).searchParams.get("page")).toBe("2"));
  });

  it("opens the detail page when a row is clicked", async () => {
    mockApi({ "GET /filters": jsonResponse({ data: filters }), "GET /employees": jsonResponse(page([employeeLite])) });
    renderPage();
    await userEvent.click(await screen.findByText("Asha Verma"));
    expect(await screen.findByText("Detail page")).toBeInTheDocument();
  });

  it("adds an employee and shows field errors from the API", async () => {
    const fetch = mockApi({
      "GET /filters": jsonResponse({ data: filters }),
      "GET /employees": jsonResponse(page([employeeLite])),
      "POST /employees": jsonResponse(
        { error: "Validation failed", code: "record_invalid", details: { email: ["has already been taken"] } },
        { status: 422 },
      ),
    });
    renderPage();
    await userEvent.click(await screen.findByRole("button", { name: /Add employee/ }));
    const dialog = screen.getByRole("dialog");
    await userEvent.type(within(dialog).getByLabelText("First name"), "Ravi");
    await userEvent.type(within(dialog).getByLabelText("Email"), "asha@acme.com");
    await userEvent.click(within(dialog).getByRole("button", { name: "Create employee" }));

    expect(await within(dialog).findByText("has already been taken")).toBeInTheDocument();
    const body = JSON.parse(fetch.mock.calls.find(([, o]) => o?.method === "POST")[1].body);
    expect(body.employee).toMatchObject({ first_name: "Ravi", email: "asha@acme.com", employment_status: "active" });
  });
});
