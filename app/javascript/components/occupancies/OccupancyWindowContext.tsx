import { createContext, ReactElement, useEffect, useState } from "react";
import { fromJson, OccupancyWindow } from "../../models/OccupancyWindow";

export const OccupancyWindowContext = createContext<OccupancyWindow | undefined>(undefined);

interface OccupancyWindowProviderProps {
  url: string;
  children?: ReactElement;
}

export function OccupancyWindowProvider({ url, children }: OccupancyWindowProviderProps) {
  const [occupancyWindow, setOccupancyWindow] = useState<OccupancyWindow | undefined>();

  OccupancyWindowContext.Provider;

  useEffect(() => {
    (async () => {
      const result = await fetch(url);
      if (result.status == 200) setOccupancyWindow(fromJson(await result.json()));
    })();
  }, []);

  return <OccupancyWindowContext.Provider value={occupancyWindow}>{children}</OccupancyWindowContext.Provider>;
}
