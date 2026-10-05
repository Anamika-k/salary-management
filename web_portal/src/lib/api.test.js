import { api, ApiError, tokenStore, setUnauthorizedHandler } from "./api";
import { jsonResponse } from "@/test/helpers";

const fetchMock = () => vi.spyOn(globalThis, "fetch");

describe("api client", () => {
  it("sends the stored token as the Authorization header", async () => {
    tokenStore.set("Bearer abc");
    const fetch = fetchMock().mockResolvedValue(jsonResponse({ ok: true }));

    await api.get("/employees");

    expect(fetch.mock.calls[0][1].headers.Authorization).toBe("Bearer abc");
  });

  it("omits the Authorization header when signed out", async () => {
    const fetch = fetchMock().mockResolvedValue(jsonResponse({}));
    await api.get("/employees");
    expect(fetch.mock.calls[0][1].headers.Authorization).toBeUndefined();
  });

  it("stores a token returned in the Authorization response header", async () => {
    fetchMock().mockResolvedValue(jsonResponse({}, { headers: { Authorization: "Bearer new" } }));
    await api.post("/auth/sign_in", {});
    expect(tokenStore.get()).toBe("Bearer new");
  });

  it("builds query strings and skips empty values", async () => {
    const fetch = fetchMock().mockResolvedValue(jsonResponse({}));
    await api.get("/employees", { q: "ann", page: 2, department_id: "", status: null });
    const url = new URL(fetch.mock.calls[0][0]);
    expect(url.pathname).toBe("/api/v1/employees");
    expect([...url.searchParams]).toEqual([["q", "ann"], ["page", "2"]]);
  });

  it("sends JSON bodies", async () => {
    const fetch = fetchMock().mockResolvedValue(jsonResponse({}));
    await api.patch("/departments/1", { department: { name: "Ops" } });
    const options = fetch.mock.calls[0][1];
    expect(options.method).toBe("PATCH");
    expect(options.headers["Content-Type"]).toBe("application/json");
    expect(JSON.parse(options.body)).toEqual({ department: { name: "Ops" } });
  });

  it("returns null for 204 No Content", async () => {
    fetchMock().mockResolvedValue(jsonResponse(null, { status: 204 }));
    await expect(api.delete("/departments/1")).resolves.toBeNull();
  });

  it("raises ApiError with the API's message, code and details", async () => {
    fetchMock().mockResolvedValue(
      jsonResponse({ error: "In use", code: "department_in_use", details: { employee_count: 3 } }, { status: 409 }),
    );
    const error = await api.delete("/departments/1").catch((e) => e);
    expect(error).toBeInstanceOf(ApiError);
    expect(error).toMatchObject({ message: "In use", status: 409, code: "department_in_use", details: { employee_count: 3 } });
  });

  it("falls back to a generic message when the error body is not JSON", async () => {
    fetchMock().mockResolvedValue(new Response("<html>", { status: 502 }));
    const error = await api.get("/employees").catch((e) => e);
    expect(error).toMatchObject({ status: 502, code: "http_error", message: "Request failed (502)" });
  });

  it("raises a network_error ApiError when the server is unreachable", async () => {
    fetchMock().mockRejectedValue(new TypeError("Failed to fetch"));
    const error = await api.get("/employees").catch((e) => e);
    expect(error).toMatchObject({ status: 0, code: "network_error" });
  });

  it("clears the token and notifies the app on 401", async () => {
    tokenStore.set("Bearer expired");
    const onUnauthorized = vi.fn();
    setUnauthorizedHandler(onUnauthorized);
    fetchMock().mockResolvedValue(jsonResponse({ error: "Expired" }, { status: 401 }));

    await expect(api.get("/auth/me")).rejects.toMatchObject({ status: 401 });
    expect(tokenStore.get()).toBeNull();
    expect(onUnauthorized).toHaveBeenCalled();
  });
});
