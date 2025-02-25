import { isAfter, isBefore } from "date-fns";
import { parseISO } from "date-fns";
import { useCallback, useContext } from "react";
import * as React from "react";
import Calendar, { type ViewType } from "../calendar/Calendar";
import { CalendarDate, type DateElementFactory } from "../calendar/CalendarDate";
import { OccupancyWindowContext } from "./OccupancyWindowContext";
import { OccupiedCalendarDate } from "./OccupiedCalendarDate";

interface OccupancyOverviewCalendarProps {
  occupancyAtUrl?: string;
  months?: number;
  defaultView?: ViewType;
}

function OccupancyOverviewCalendar({ occupancyAtUrl, months, defaultView }: OccupancyOverviewCalendarProps) {
  const occupancyWindow = useContext(OccupancyWindowContext);

  const disabledCallback = useCallback(
    (date: Date) => !occupancyWindow || isBefore(date, occupancyWindow.start) || isAfter(date, occupancyWindow.end),
    [occupancyWindow],
  );

  const dateElementFactory: DateElementFactory = useCallback(
    (dateString: string, labelCallback: (date: Date) => string) => {
      const date = parseISO(dateString);
      const disabled = !occupancyAtUrl || disabledCallback(date);
      const href = occupancyAtUrl?.replace("__DATE__", dateString);

      return (
        <CalendarDate dateString={dateString} key={dateString}>
          <a className="date-action" target="_top" href={disabled ? undefined : href} aria-disabled={disabled}>
            <OccupiedCalendarDate
              dateString={dateString}
              label={labelCallback(date)}
              occupancyWindow={occupancyWindow}
            />
          </a>
        </CalendarDate>
      );
    },
    [occupancyWindow, occupancyAtUrl],
  );

  return <Calendar defaultView={defaultView} months={months} dateElementFactory={dateElementFactory} />;
}

export default OccupancyOverviewCalendar;
