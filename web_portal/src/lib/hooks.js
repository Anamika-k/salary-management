// Small reusable React hooks.
import { useEffect, useState } from "react";

// The value, updated only after it has stopped changing for `delay` ms
// (search-as-you-type without a request per keystroke).
export function useDebouncedValue(value, delay = 300) {
  const [debounced, setDebounced] = useState(value);
  useEffect(() => {
    const timer = setTimeout(() => setDebounced(value), delay);
    return () => clearTimeout(timer);
  }, [value, delay]);
  return debounced;
}
