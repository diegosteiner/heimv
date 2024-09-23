import { max } from "date-fns";
import { PropsWithChildren, createContext, useContext, useEffect, useState } from "react";
import { OccupancyWindowWithOccupiedDates, calculateOccupiedDates } from "../../models/OccupancyWindow";
import { ApiClient } from "../../services/api_client";
import { Occupiable } from "../../types";
import { OrganisationContext } from "../organisation/OrganisationProvider";

export const OccupancyWindowContext = createContext<OccupancyWindowWithOccupiedDates | undefined>(undefined);

type OccupancyWindowProviderProps = PropsWithChildren<{
  occupiableIds?: Occupiable["id"][];
}>;

export function OccupancyWindowProvider({ occupiableIds, children }: OccupancyWindowProviderProps) {
  const organisation = useContext(OrganisationContext);
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
        occupiableIds.map((occupiableId) => api.getOccupiableOccupancyWindow(occupiableId)),
      );
      const mergedOccupancyWindow = occupancyWindows.reduce((memo, occupancyWindow) => ({
        start: max([memo?.start, occupancyWindow.start]),
        end: max([memo?.end, occupancyWindow.end]),
        occupancies: [...(memo?.occupancies || []), ...occupancyWindow.occupancies],
      }));
      setOccupancyWindow(calculateOccupiedDates(mergedOccupancyWindow));
    })();
  }, [organisation, occupiableIds]);

  return <OccupancyWindowContext.Provider value={occupancyWindow}>{children}</OccupancyWindowContext.Provider>;
}
