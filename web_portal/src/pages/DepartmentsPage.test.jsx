import { screen, within } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import DepartmentsPage from "./DepartmentsPage";
import { jsonResponse, mockApi, renderWithProviders } from "@/test/helpers";
import { page } from "@/test/fixtures";

const departments = [{ id: 1, name: "Engineering" }, { id: 2, name: "Finance" }];
const sentBody = (fetch, method) => JSON.parse(fetch.mock.calls.find(([, o]) => o?.method === method)[1].body);

describe("DepartmentsPage", () => {
  it("lists departments with a link to their employees", async () => {
    mockApi({ "GET /departments": jsonResponse(page(departments)) });
    renderWithProviders(<DepartmentsPage />);
    const row = (await screen.findByText("Engineering")).closest("li");
    expect(within(row).getByRole("link", { name: /View employees/ })).toHaveAttribute("href", "/employees?department_id=1");
  });

  it("adds a department", async () => {
    const fetch = mockApi({
      "GET /departments": jsonResponse(page(departments)),
      "POST /departments": jsonResponse({ data: { id: 3, name: "Legal" } }, { status: 201 }),
    });
    renderWithProviders(<DepartmentsPage />);
    await userEvent.type(await screen.findByPlaceholderText("New department name"), "Legal");
    await userEvent.click(screen.getByRole("button", { name: "Add" }));
    expect(sentBody(fetch, "POST")).toEqual({ department: { name: "Legal" } });
  });

  it("shows a duplicate-name error", async () => {
    mockApi({
      "GET /departments": jsonResponse(page(departments)),
      "POST /departments": jsonResponse(
        { error: "Validation failed: Name has already been taken", code: "record_invalid", details: { name: ["has already been taken"] } },
        { status: 422 },
      ),
    });
    renderWithProviders(<DepartmentsPage />);
    await userEvent.type(await screen.findByPlaceholderText("New department name"), "Finance");
    await userEvent.click(screen.getByRole("button", { name: "Add" }));
    expect(await screen.findByText("Name has already been taken")).toBeInTheDocument();
  });

  it("renames a department inline", async () => {
    const fetch = mockApi({
      "GET /departments": jsonResponse(page(departments)),
      "PATCH /departments/2": jsonResponse({ data: { id: 2, name: "Finance & Accounts" } }),
    });
    renderWithProviders(<DepartmentsPage />);
    const row = (await screen.findByText("Finance")).closest("li");
    await userEvent.click(within(row).getByRole("button", { name: "Rename Finance" }));
    const input = within(row).getByRole("textbox", { name: "Department name" });
    await userEvent.clear(input);
    await userEvent.type(input, "Finance & Accounts{Enter}");
    expect(sentBody(fetch, "PATCH")).toEqual({ department: { name: "Finance & Accounts" } });
  });

  it("explains why a department in use can't be deleted", async () => {
    mockApi({
      "GET /departments": jsonResponse(page(departments)),
      "DELETE /departments/1": jsonResponse(
        { error: "Department still has employees", code: "department_in_use", details: { employee_count: 42 } },
        { status: 409 },
      ),
    });
    renderWithProviders(<DepartmentsPage />);
    const row = (await screen.findByText("Engineering")).closest("li");
    await userEvent.click(within(row).getByRole("button", { name: "Delete Engineering" }));
    await userEvent.click(within(screen.getByRole("dialog")).getByRole("button", { name: "Delete department" }));
    expect(await screen.findByRole("alert")).toHaveTextContent("42 employees");
  });
});
