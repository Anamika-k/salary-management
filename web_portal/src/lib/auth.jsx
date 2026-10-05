// Session state for the whole app: who is signed in, sign in and sign out.
// The token lives in localStorage (via tokenStore); the user comes from /auth/me.
import { createContext, useContext, useEffect, useState } from "react";
import { useQuery, useQueryClient } from "@tanstack/react-query";
import { api, setUnauthorizedHandler, tokenStore } from "./api";

const AuthContext = createContext(null);

export function AuthProvider({ children }) {
  const queryClient = useQueryClient();
  const [token, setToken] = useState(() => tokenStore.get());

  const me = useQuery({
    queryKey: ["me"],
    queryFn: () => api.get("/auth/me").then((data) => data.user),
    enabled: Boolean(token),
    staleTime: Infinity,
    retry: false,
  });

  useEffect(() => {
    setUnauthorizedHandler(() => {
      setToken(null);
      queryClient.clear();
    });
  }, [queryClient]);

  async function signIn(email, password) {
    const { user } = await api.post("/auth/sign_in", { user: { email, password } });
    queryClient.setQueryData(["me"], user);
    setToken(tokenStore.get());
  }

  async function signOut() {
    try {
      await api.delete("/auth/sign_out");
    } finally {
      tokenStore.clear();
      setToken(null);
      queryClient.clear();
    }
  }

  const value = {
    user: token ? me.data : undefined,
    isChecking: Boolean(token) && me.isPending,
    signIn,
    signOut,
  };
  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
}

// eslint-disable-next-line react-refresh/only-export-components -- hook belongs with its provider
export function useAuth() {
  return useContext(AuthContext);
}
