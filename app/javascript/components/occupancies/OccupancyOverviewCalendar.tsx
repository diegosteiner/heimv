import { MouseEventHandler, useCallback } from "react";
import { CalendarDate, DateElementFactory } from "../calendar/CalendarDate";
import { isAfter, isBefore } from "date-fns/esm";
import * as React from "react";
import { parseISO } from "date-fns";
import Calendar, { ViewType } from "../calendar/Calendar";
import { DateWithOccupancies } from "./DateWithOccupancies";
import { OccupancyWindowContext } from "./OccupancyWindowContext";

interface OccupancyOverviewCalendarProps {
  start?: string;
  occupancyAtUrl?: string;
  calendarUrl?: string;
  onClick?: MouseEventHandler;
  classNameCallback?: (date: Date) => string;
  disabledCallback?: (date: Date) => boolean;
  defaultView?: ViewType;
}

function OccupancyOverviewCalendar({ start, occupancyAtUrl, defaultView }: OccupancyOverviewCalendarProps) {
  const occupancyWindow = React.useContext(OccupancyWindowContext);
  console.log(occupancyWindow);
  const initialFirstDate = start;

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
          <a className="date-action" href={disabled ? undefined : href} aria-disabled={disabled}>
            <DateWithOccupancies
              dateString={dateString}
              label={labelCallback(date)}
              occupancyWindow={occupancyWindow}
            ></DateWithOccupancies>
          </a>
        </CalendarDate>
      );
    },
    [occupancyWindow],
  );

  return (
    <Calendar
      initialFirstDate={initialFirstDate}
      defaultView={defaultView}
      dateElementFactory={dateElementFactory}
    ></Calendar>
  );
}

export default OccupancyOverviewCalendar;
