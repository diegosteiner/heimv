import { createContext, PropsWithChildren, useEffect, useState } from "react";
import { Organisation } from "../../types";

export const OrganisationContext = createContext<Organisation | undefined>(undefined);

type OrganisationProviderProps = PropsWithChildren<{
  id: string;
}>;

export default function OrganisationProvider({ id, children }: OrganisationProviderProps) {
  const [organisation, setOrganisation] = useState<Organisation | undefined>();
  const url = `${(id && "/" + id) || ""}/organisation.json`;

  useEffect(() => {
    (async () => {
      const result = await fetch(url);
      if (result.status == 200) setOrganisation((await result.json()) as Organisation);
    })();
  }, [id]);

  return <OrganisationContext.Provider value={organisation}>{children}</OrganisationContext.Provider>;
}
