import { MouseEventHandler, useCallback, useEffect, useState } from "react";
import { CalendarDate, DateElementFactory } from "../calendar/CalendarDate";
import { fromJson, OccupancyWindow } from "../../models/OccupancyWindow";
import { isAfter, isBefore } from "date-fns/esm";
import * as React from "react";
import { parseISO } from "date-fns";
import Calendar, { ViewType } from "../calendar/Calendar";
import { DateWithOccupancies } from "./DateWithOccupancies";

interface OccupancyOverviewCalendarProps {
  start?: string;
  occupancyAtUrl?: string;
  calendarUrl?: string;
  onClick?: MouseEventHandler;
  classNameCallback?: (date: Date) => string;
  disabledCallback?: (date: Date) => boolean;
  defaultView?: ViewType;
}

function OccupancyOverviewCalendar({
  start,
  calendarUrl,
  occupancyAtUrl,
  defaultView,
}: OccupancyOverviewCalendarProps) {
  const [occupancyWindow, setOccupancyWindow] = useState<OccupancyWindow | undefined>();
  const initialFirstDate = start;

  useEffect(() => {
    (async () => {
      if (!calendarUrl) return;
      const result = await fetch(calendarUrl);
      if (result.status == 200) setOccupancyWindow(fromJson(await result.json()));
    })();
  }, [calendarUrl]);

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
        <CalendarDate dateString={dateString}>
          <a className="date-action" href={disabled ? undefined : href} aria-disabled={disabled}>
            <DateWithOccupancies dateString={dateString} occupancyWindow={occupancyWindow}></DateWithOccupancies>
            <div className="label">{labelCallback(date)}</div>
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
