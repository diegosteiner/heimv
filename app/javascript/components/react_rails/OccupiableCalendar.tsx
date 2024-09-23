import * as React from "react";
import { ViewType } from "../calendar/Calendar";
import OccupancyOverviewCalendar from "../occupancies/OccupancyOverviewCalendar";
import { OccupancyWindowProvider } from "../occupancies/OccupancyWindowContext";
import OrganisationProvider from "../organisation/OrganisationProvider";

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
