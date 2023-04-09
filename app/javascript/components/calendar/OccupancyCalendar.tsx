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
  monthsCount?: number;
  occupancyAtUrl: string;
  calendarUrl: string;
}

// type ViewType = "months" | "year";

function OccupancyCalendar({ start, calendarUrl, occupancyAtUrl }: OccupancyCalendarProps) {
  // const [view, setView] = useState<ViewType>("months");
  const [occupancyWindow, setOccupancyWindow] = useState<OccupancyWindow | undefined>();

  useEffect(() => {
    (async () => {
      const result = await fetch(calendarUrl);
      if (result.status == 200) setOccupancyWindow(fromJson(await result.json()));
    })();
  }, []);

  const handleClick: MouseEventHandler = useCallback(
    (event) => {
      event.preventDefault();
      const target = event.currentTarget as HTMLButtonElement;
      if (!target.value || !window.top) return;
      window.top.location.href = occupancyAtUrl.replace("__DATE__", target.value);
    },
    [occupancyAtUrl]
  );

  const disabledCallback = useCallback(
    (date: Date) => !occupancyWindow || isBefore(date, occupancyWindow.start) || isAfter(date, occupancyWindow.end),
    [occupancyWindow]
  );

  const classNameCallback = useCallback(() => "occupancy-calendar-date", []);

  const dateElementFactory: DateElementFactory = useCallback(
    (dateString: string, labelCallback: (date: Date) => string) => (
      <OverlayTrigger
        trigger={["focus", "hover"]}
        overlay={<div>Test</div>}
        // overlay={<OccupancyPopover occupancyWindow={occupancyWindow} dateString={dateString}></OccupancyPopover>}
      >
        <OccupancyCalendarDate
          dateString={dateString}
          labelCallback={labelCallback}
          occupancyWindow={occupancyWindow}
          disabledCallback={disabledCallback}
          classNameCallback={classNameCallback}
          onClick={handleClick}
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
