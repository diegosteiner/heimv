import * as React from "react";
import type { Organisation } from "../../types";
import type { ViewType } from "../calendar/Calendar";
import OccupancyOverviewCalendar from "../occupancies/OccupancyOverviewCalendar";
import { OccupancyWindowProvider } from "../occupancies/OccupancyWindowContext";
import OrganisationProvider from "./OrganisationProvider";

type OccupiableCalendarProps = {
  org: string;
  months?: number;
  occupiableIds: number[];
  defaultView: ViewType;
  occupancyAtUrl: string;
  manage?: boolean;
  organisation: Organisation;
};

export default function OccupiableCalendar({
  organisation,
  occupiableIds,
  months,
  defaultView,
  occupancyAtUrl,
  manage,
}: OccupiableCalendarProps) {
  return (
    <React.StrictMode>
      <OrganisationProvider organisation={organisation}>
        <OccupancyWindowProvider occupiableIds={occupiableIds} manage={manage}>
          <OccupancyOverviewCalendar defaultView={defaultView} months={months} occupancyAtUrl={occupancyAtUrl} />
        </OccupancyWindowProvider>
      </OrganisationProvider>
    </React.StrictMode>
  );
}
