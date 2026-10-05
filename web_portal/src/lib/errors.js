// Turns an ApiError into what forms show: a readable message and per-field errors.
// Validation errors arrive as { code: "record_invalid", details: { field: [msgs] } }.
export function errorMessage(error) {
  if (!error) return null;
  return error.message.replace(/^Validation failed: /, "");
}

export function fieldError(error, field) {
  return error?.code === "record_invalid" ? error.details?.[field]?.[0] : undefined;
}

// A message for the top of a form, only when no field shows the problem.
export function formLevelError(error, fields) {
  if (!error) return null;
  const shownOnField = fields.some((field) => fieldError(error, field));
  return shownOnField ? null : errorMessage(error);
}
