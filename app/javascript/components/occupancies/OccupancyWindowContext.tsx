import { createContext, PropsWithChildren, useEffect, useState } from "react";
import { fromJson, OccupancyWindow } from "../../models/OccupancyWindow";

export const OccupancyWindowContext = createContext<OccupancyWindow | undefined>(undefined);

type OccupancyWindowProviderProps = PropsWithChildren<{
  url: string;
}>;

export function OccupancyWindowProvider({ url, children }: OccupancyWindowProviderProps) {
  const [occupancyWindow, setOccupancyWindow] = useState<OccupancyWindow | undefined>();

  useEffect(() => {
    (async () => {
      if (!url) return;
      const result = await fetch(url);
      if (result.status == 200) setOccupancyWindow(fromJson(await result.json()));
    })();
  }, [url]);

  return <OccupancyWindowContext.Provider value={occupancyWindow}>{children}</OccupancyWindowContext.Provider>;
}
