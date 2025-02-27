import { max } from "date-fns";
import { type PropsWithChildren, createContext, use, useEffect, useState } from "react";
import { type OccupancyWindowWithOccupiedDates, calculateOccupiedDates } from "../../models/OccupancyWindow";
import { ApiClient } from "../../services/api_client";
import type { Occupiable, Organisation } from "../../types";
import { OrganisationContext } from "../rails/OrganisationProvider";

export const OccupancyWindowContext = createContext<OccupancyWindowWithOccupiedDates | undefined>(undefined);

type OccupancyWindowProviderProps = PropsWithChildren<{
  occupiableIds?: Occupiable["id"][];
  manage?: boolean;
}>;

export function OccupancyWindowProvider({ occupiableIds, manage = false, children }: OccupancyWindowProviderProps) {
  const organisation = use(OrganisationContext) as Organisation;
  const [occupancyWindow, setOccupancyWindow] = useState<OccupancyWindowWithOccupiedDates | undefined>();

  useEffect(() => {
    (async () => {
      if (!organisation || !occupiableIds) return;
      if (occupiableIds.length === 0) {
        setOccupancyWindow(undefined);
        return;
      }
      const api = new ApiClient(organisation.slug);
      const occupancyWindows = await Promise.all(
        occupiableIds.map((occupiableId) => {
          return manage
            ? api.getManageOccupiableOccupancyWindow(occupiableId)
            : api.getOccupiableOccupancyWindow(occupiableId);
        }),
      );
      const mergedOccupancyWindow = occupancyWindows.reduce((memo, occupancyWindow) => ({
        start: max([memo?.start, occupancyWindow.start]),
        end: max([memo?.end, occupancyWindow.end]),
        occupancies: [...(memo?.occupancies || []), ...occupancyWindow.occupancies],
      }));
      setOccupancyWindow(calculateOccupiedDates(mergedOccupancyWindow));
    })();
  }, [organisation, occupiableIds, manage]);

  return <OccupancyWindowContext.Provider value={occupancyWindow}>{children}</OccupancyWindowContext.Provider>;
}
