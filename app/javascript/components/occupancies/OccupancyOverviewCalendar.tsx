import { useCallback, useContext } from "react";
import { CalendarDate, DateElementFactory } from "../calendar/CalendarDate";
import { isAfter, isBefore } from "date-fns";
import * as React from "react";
import { parseISO } from "date-fns";
import Calendar, { ViewType } from "../calendar/Calendar";
import { OccupiedCalendarDate } from "./OccupiedCalendarDate";
import { OccupancyWindowContext } from "./OccupancyWindowContext";

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
            ></OccupiedCalendarDate>
          </a>
        </CalendarDate>
      );
    },
    [occupancyWindow],
  );

  return <Calendar defaultView={defaultView} months={months} dateElementFactory={dateElementFactory}></Calendar>;
}

export default OccupancyOverviewCalendar;
