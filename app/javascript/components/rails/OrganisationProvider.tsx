import { type PropsWithChildren, createContext, useEffect, useState } from "react";
import type { Organisation } from "../../types";

export const OrganisationContext = createContext<Organisation | null>(null);

type Props = PropsWithChildren<{
  organisation: Organisation;
}>;

export default function OrganisationProvider({ organisation, children }: Props) {
  return <OrganisationContext.Provider value={organisation}>{children}</OrganisationContext.Provider>;
}
