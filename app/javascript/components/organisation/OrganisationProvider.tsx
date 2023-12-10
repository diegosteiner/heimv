import { createContext, PropsWithChildren, useEffect, useState } from "react";
import { Organisation } from "../../types";
import { ApiClient } from "../../services/api_client";

export const OrganisationContext = createContext<Organisation | undefined>(undefined);

type OrganisationProviderProps = PropsWithChildren<{
  id: string;
}>;

export default function OrganisationProvider({ id, children }: OrganisationProviderProps) {
  const [organisation, setOrganisation] = useState<Organisation | undefined>();

  useEffect(() => {
    (async () => {
      const api = new ApiClient(id);
      setOrganisation(await api.getOrganisation());
    })();
  }, [id]);

  return <OrganisationContext.Provider value={organisation}>{children}</OrganisationContext.Provider>;
}
