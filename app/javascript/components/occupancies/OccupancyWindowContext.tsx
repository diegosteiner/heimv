import { createContext, PropsWithChildren, useContext, useEffect, useState } from "react";
import { getOccupiedDates, OccupancyWindow } from "../../models/OccupancyWindow";
import { Occupiable } from "../../types";
import { OrganisationContext } from "../organisation/OrganisationProvider";
import { ApiClient } from "../../services/api_client";
import { max } from "date-fns";

export const OccupancyWindowContext = createContext<OccupancyWindow | undefined>(undefined);

type OccupancyWindowProviderProps = PropsWithChildren<{
  occupiableIds?: Occupiable["id"][];
}>;

export function OccupancyWindowProvider({ occupiableIds, children }: OccupancyWindowProviderProps) {
  const organisation = useContext(OrganisationContext);
  const [occupancyWindow, setOccupancyWindow] = useState<OccupancyWindow | undefined>();

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
      mergedOccupancyWindow.occupiedDates = getOccupiedDates(mergedOccupancyWindow.occupancies);
      setOccupancyWindow(mergedOccupancyWindow);
    })();
  }, [organisation, occupiableIds]);

  return <OccupancyWindowContext.Provider value={occupancyWindow}>{children}</OccupancyWindowContext.Provider>;
}
