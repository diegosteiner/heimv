import OccupancyOverviewCalendar from "../occupancies/OccupancyOverviewCalendar";
import OrganisationProvider from "../organisation/OrganisationProvider";
import * as React from "react";
import { ViewType } from "../calendar/Calendar";
import { OccupancyWindowProvider } from "../occupancies/OccupancyWindowContext";

type OccupiableCalendarProps = {
  org: string;
  months?: number;
  occupiableIds: number[];
  defaultView: ViewType;
  occupancyAtUrl: string;
};

export default function OccupiableCalendar({
  org,
  occupiableIds,
  months,
  defaultView,
  occupancyAtUrl,
}: OccupiableCalendarProps) {
  return (
    <React.StrictMode>
      <OrganisationProvider org={org}>
        <OccupancyWindowProvider occupiableIds={occupiableIds}>
          <OccupancyOverviewCalendar
            defaultView={defaultView}
            months={months}
            occupancyAtUrl={occupancyAtUrl}
          ></OccupancyOverviewCalendar>
        </OccupancyWindowProvider>
      </OrganisationProvider>
    </React.StrictMode>
  );
}
