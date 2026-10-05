// Every API read and write the screens use, as React Query hooks.
// Keeping them together means cache keys and invalidation live in one place.
import { keepPreviousData, useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { api } from "./api";

const data = (response) => response.data;

// ---- Reads -----------------------------------------------------------------
export const useFilters = () =>
  useQuery({ queryKey: ["filters"], queryFn: () => api.get("/filters").then(data), staleTime: 5 * 60_000 });

export const useEmployees = (params) =>
  useQuery({ queryKey: ["employees", params], queryFn: () => api.get("/employees", params), placeholderData: keepPreviousData });

export const useEmployee = (id) =>
  useQuery({ queryKey: ["employee", id], queryFn: () => api.get(`/employees/${id}`).then(data) });

export const useSalaries = (id) =>
  useQuery({ queryKey: ["salaries", id], queryFn: () => api.get(`/employees/${id}/salaries`, { per_page: 100 }).then(data) });

export const useBreakdown = (id, on) =>
  useQuery({
    queryKey: ["breakdown", id, on],
    queryFn: () => api.get(`/employees/${id}/salaries/breakdown`, { on }).then(data),
    enabled: Boolean(on),
    placeholderData: keepPreviousData,
  });

export const useAuditLogs = (id) =>
  useQuery({ queryKey: ["audit-logs", id], queryFn: () => api.get(`/employees/${id}/audit_logs`, { per_page: 100 }).then(data) });

export const useDepartments = () =>
  useQuery({ queryKey: ["departments"], queryFn: () => api.get("/departments", { per_page: 100 }).then(data) });

export const useStructures = () =>
  useQuery({ queryKey: ["salary-structures"], queryFn: () => api.get("/salary_structures", { per_page: 100 }).then(data) });

export const useStructure = (id) =>
  useQuery({ queryKey: ["salary-structure", id], queryFn: () => api.get(`/salary_structures/${id}`).then(data), enabled: Boolean(id) });

export const usePreview = (id, annualSalary) =>
  useQuery({
    queryKey: ["preview", id, annualSalary],
    queryFn: () => api.get(`/salary_structures/${id}/preview`, { annual_salary: annualSalary }).then(data),
    enabled: Boolean(id) && Number(annualSalary) > 0,
    placeholderData: keepPreviousData,
    retry: false,
  });

// ---- Writes ----------------------------------------------------------------
function useInvalidatingMutation(mutationFn, keys) {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn,
    onSuccess: () => keys.forEach((queryKey) => queryClient.invalidateQueries({ queryKey })),
  });
}

export const useSaveEmployee = (id) =>
  useInvalidatingMutation(
    (employee) => (id ? api.patch(`/employees/${id}`, { employee }) : api.post("/employees", { employee })).then(data),
    [["employees"], ["employee"], ["filters"]],
  );

export const useDeleteEmployee = () =>
  useInvalidatingMutation((id) => api.delete(`/employees/${id}`), [["employees"]]);

export const useChangeSalary = (id) =>
  useInvalidatingMutation(
    (salary) => api.post(`/employees/${id}/salaries`, { salary }).then(data),
    [["employee", id], ["salaries", id], ["breakdown", id], ["audit-logs", id], ["employees"]],
  );

export const useSaveDepartment = () =>
  useInvalidatingMutation(
    ({ id, name }) =>
      (id ? api.patch(`/departments/${id}`, { department: { name } }) : api.post("/departments", { department: { name } })).then(data),
    [["departments"], ["filters"], ["employees"]],
  );

export const useDeleteDepartment = () =>
  useInvalidatingMutation((id) => api.delete(`/departments/${id}`), [["departments"], ["filters"]]);

export const useUpdateRule = (structureId) =>
  useInvalidatingMutation(
    ({ id, value }) => api.patch(`/salary_structures/${structureId}/components/${id}`, { component: { value } }).then(data),
    [["salary-structure", structureId], ["preview", structureId], ["breakdown"]],
  );
