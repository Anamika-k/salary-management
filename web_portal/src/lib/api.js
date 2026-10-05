// The single way the portal talks to the Rails API.
// Adds the JWT, turns error responses into ApiError ({ message, code, details })
// and tells the app when the session is gone (401) so it can return to sign in.
const BASE_URL = import.meta.env.VITE_API_URL ?? "http://localhost:3000";
const TOKEN_KEY = "acme.token";

export class ApiError extends Error {
  constructor(message, { status, code, details = {} }) {
    super(message);
    this.name = "ApiError";
    this.status = status;
    this.code = code;
    this.details = details;
  }
}

export const tokenStore = {
  get: () => localStorage.getItem(TOKEN_KEY),
  set: (token) => localStorage.setItem(TOKEN_KEY, token),
  clear: () => localStorage.removeItem(TOKEN_KEY),
};

let onUnauthorized = () => {};
export function setUnauthorizedHandler(handler) {
  onUnauthorized = handler;
}

function buildUrl(path, params = {}) {
  const url = new URL(`/api/v1${path}`, BASE_URL);
  Object.entries(params).forEach(([key, value]) => {
    if (value !== undefined && value !== null && value !== "") url.searchParams.append(key, value);
  });
  return url.toString();
}

async function parseBody(response) {
  const text = await response.text();
  if (!text) return null;
  try {
    return JSON.parse(text);
  } catch {
    return null; // non-JSON body (e.g. a proxy error page); status still decides
  }
}

async function request(path, { method = "GET", params, body } = {}) {
  const headers = { Accept: "application/json" };
  const token = tokenStore.get();
  if (token) headers.Authorization = token;
  if (body !== undefined) headers["Content-Type"] = "application/json";

  let response;
  try {
    response = await fetch(buildUrl(path, params), {
      method,
      headers,
      body: body === undefined ? undefined : JSON.stringify(body),
    });
  } catch {
    throw new ApiError("Can't reach the server. Is the API running?", { status: 0, code: "network_error" });
  }

  const issuedToken = response.headers.get("Authorization");
  if (issuedToken) tokenStore.set(issuedToken);

  const data = await parseBody(response);
  if (response.ok) return data;

  if (response.status === 401) {
    tokenStore.clear();
    onUnauthorized();
  }
  throw new ApiError(data?.error ?? `Request failed (${response.status})`, {
    status: response.status,
    code: data?.code ?? "http_error",
    details: data?.details ?? {},
  });
}

export const api = {
  get: (path, params) => request(path, { params }),
  post: (path, body) => request(path, { method: "POST", body }),
  patch: (path, body) => request(path, { method: "PATCH", body }),
  delete: (path) => request(path, { method: "DELETE" }),
};
