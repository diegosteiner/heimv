import * as React from "react";
import type { ViewType } from "../calendar/Calendar";
import OccupancyOverviewCalendar from "../occupancies/OccupancyOverviewCalendar";
import { OccupancyWindowProvider } from "../occupancies/OccupancyWindowContext";
import OrganisationProvider from "../organisation/OrganisationProvider";

type OccupiableCalendarProps = {
  org: string;
  months?: number;
  occupiableIds: number[];
  defaultView: ViewType;
  occupancyAtUrl: string;
  manage?: boolean;
};

export default function OccupiableCalendar({
  org,
  occupiableIds,
  months,
  defaultView,
  occupancyAtUrl,
  manage,
}: OccupiableCalendarProps) {
  return (
    <React.StrictMode>
      <OrganisationProvider org={org}>
        <OccupancyWindowProvider occupiableIds={occupiableIds} manage={manage}>
          <OccupancyOverviewCalendar defaultView={defaultView} months={months} occupancyAtUrl={occupancyAtUrl} />
        </OccupancyWindowProvider>
      </OrganisationProvider>
    </React.StrictMode>
  );
}
