import { Dispatch, MouseEventHandler, SetStateAction, createContext, useCallback, useEffect, useState } from "react";
import { DateElementFactory } from "./CalendarDate";
import MonthsCalendar from "./MonthsCalendar";
import { OccupancyCalendarDate } from "./OccupancyCalendarDate";
import { fromJson, OccupancyWindow } from "../../models/OccupancyWindow";
import { isAfter, isBefore } from "date-fns/esm";
import YearCalendar from "./YearCalendar";
import * as React from "react";

interface OccupancyCalendarProps {
  start?: string;
  occupancyAtUrl?: string;
  calendarUrl?: string;
  onClick?: MouseEventHandler;
  classNameCallback?: (date: Date) => string;
  disabledCallback?: (date: Date) => boolean;
  defaultView?: ViewType;
}

type ViewType = "months" | "year";
type CalendarViewContextType = {
  view: ViewType;
  setView?: Dispatch<SetStateAction<ViewType>>;
};
export const CalendarViewContext = createContext<CalendarViewContextType>({ view: "months" });

function OccupancyCalendar({
  start,
  calendarUrl,
  occupancyAtUrl,
  classNameCallback,
  disabledCallback,
  onClick,
  defaultView,
}: OccupancyCalendarProps) {
  const [view, setView] = useState<ViewType>(defaultView || "months");
  const [occupancyWindow, setOccupancyWindow] = useState<OccupancyWindow | undefined>();
  const initialFirstDate = start;

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
    [occupancyAtUrl],
  );

  disabledCallback ??= useCallback(
    (date: Date) => !occupancyWindow || isBefore(date, occupancyWindow.start) || isAfter(date, occupancyWindow.end),
    [occupancyWindow],
  );

  const dateElementFactory: DateElementFactory = useCallback(
    (dateString: string, labelCallback: (date: Date) => string) => (
      <OccupancyCalendarDate
        dateString={dateString}
        labelCallback={labelCallback}
        occupancyWindow={occupancyWindow}
        disabledCallback={disabledCallback}
        classNameCallback={classNameCallback}
        onClick={onClick}
      ></OccupancyCalendarDate>
    ),
    [occupancyWindow],
  );

  return (
    <React.StrictMode>
      <CalendarViewContext.Provider value={{ view, setView }}>
        <div className="calendar">
          {({ months: MonthsCalendar, year: YearCalendar }[view] || MonthsCalendar)({
            initialFirstDate,
            dateElementFactory,
          })}
        </div>
      </CalendarViewContext.Provider>
    </React.StrictMode>
  );
}

export default OccupancyCalendar;
