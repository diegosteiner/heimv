import { MouseEventHandler, useCallback, useEffect, useState } from "react";
import { DateElementFactory } from "./CalendarDate";
import MonthsCalendar from "./MonthsCalendar";
import { OccupancyCalendarDate } from "./OccupancyCalendarDate";
import * as React from "react";
import { OccupancyPopover } from "./OccupancyPopover";
import { fromJson, OccupancyWindow } from "../../models/OccupancyWindow";
import { isAfter, isBefore } from "date-fns/esm";
import { OverlayTrigger } from "react-bootstrap";

interface OccupancyCalendarProps {
  start?: string;
  occupancyAtUrl?: string;
  calendarUrl?: string;
  onClick?: MouseEventHandler;
  classNameCallback?: (date: Date) => string;
  disabledCallback?: (date: Date) => boolean;
}

// type ViewType = "months" | "year";

function OccupancyCalendar({
  start,
  calendarUrl,
  occupancyAtUrl,
  classNameCallback,
  disabledCallback,
  onClick,
}: OccupancyCalendarProps) {
  // const [view, setView] = useState<ViewType>("months");
  const [occupancyWindow, setOccupancyWindow] = useState<OccupancyWindow | undefined>();

  useEffect(() => {
    (async () => {
      if (!calendarUrl) return;
      const result = await fetch(calendarUrl);
      if (result.status == 200) setOccupancyWindow(fromJson(await result.json()));
    })();
  }, [calendarUrl]);

  onClick ??= useCallback<MouseEventHandler>(
    (event) => {
      event.preventDefault();
      if (!occupancyAtUrl) return;
      const target = event.currentTarget as HTMLButtonElement;
      if (!target.value || !window.top) return;
      window.top.location.href = occupancyAtUrl.replace("__DATE__", target.value);
    },
    [occupancyAtUrl]
  );

  disabledCallback ??= useCallback(
    (date: Date) => !occupancyWindow || isBefore(date, occupancyWindow.start) || isAfter(date, occupancyWindow.end),
    [occupancyWindow]
  );

  const dateElementFactory: DateElementFactory = useCallback(
    (dateString: string, labelCallback: (date: Date) => string) => (
      <OverlayTrigger
        trigger={["focus", "hover"]}
        overlay={<OccupancyPopover occupancyWindow={occupancyWindow} dateString={dateString}></OccupancyPopover>}
      >
        <OccupancyCalendarDate
          dateString={dateString}
          labelCallback={labelCallback}
          occupancyWindow={occupancyWindow}
          disabledCallback={disabledCallback}
          classNameCallback={classNameCallback}
          onClick={onClick}
        ></OccupancyCalendarDate>
      </OverlayTrigger>
    ),
    [occupancyWindow]
  );

  return (
    <React.StrictMode>
      <div className="calendar">
        <MonthsCalendar initialFirstDate={start} dateElementFactory={dateElementFactory}></MonthsCalendar>
        {/* <YearCalendar start={start} dayElement={dayElement}></YearCalendar> */}
      </div>
    </React.StrictMode>
  );
}

export default OccupancyCalendar;
