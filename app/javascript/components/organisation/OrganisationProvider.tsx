import { createContext, PropsWithChildren, useEffect, useState } from "react";
import { Organisation } from "../../types";
import { ApiClient } from "../../services/api_client";

export const OrganisationContext = createContext<Organisation | undefined>(undefined);

type OrganisationProviderProps = PropsWithChildren<{
  org: string;
}>;

export default function OrganisationProvider({ org, children }: OrganisationProviderProps) {
  const [organisation, setOrganisation] = useState<Organisation | undefined>();

  useEffect(() => {
    (async () => {
      const api = new ApiClient(org);
      setOrganisation(await api.getOrganisation());
    })();
  }, [org]);

  return <OrganisationContext.Provider value={organisation}>{children}</OrganisationContext.Provider>;
}
