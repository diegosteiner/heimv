import { createContext, MouseEventHandler, useCallback } from "react";
import { DateElementFactory } from "./CalendarDate";
import MonthsCalendar from "./MonthsCalendar";
import { OccupancyWindowProvider } from "./OccupancyWindowContext";
import { OccupancyCalendarDate } from "./OccupancyCalendarDate";
import * as React from "react";
import { OccupancyPopover } from "./OccupancyPopover";

interface OccupancyCalendarProps {
  start?: string;
  monthsCount?: number;
  occupancyAtUrl: string;
  calendarUrl: string;
}

// type ViewType = "months" | "year";

export const CalendarBehaviorContext = createContext<{
  onClick?: MouseEventHandler;
  onMouseOver?: MouseEventHandler;
  onMouseLeave?: MouseEventHandler;
}>({});

function OccupancyCalendar({ start, calendarUrl, occupancyAtUrl }: OccupancyCalendarProps) {
  // const [view, setView] = useState<ViewType>("months");

  const handleClick: MouseEventHandler = useCallback(
    (event) => {
      event.preventDefault();
      const target = event.currentTarget as HTMLButtonElement;
      if (!target.value || !window.top) return;
      window.top.location.href = occupancyAtUrl.replace("__DATE__", target.value);
    },
    [occupancyAtUrl]
  );

  const dateElementFactory: DateElementFactory = useCallback(
    (dateString: string, labelCallback: (date: Date) => string) => (
      <OccupancyPopover dateString={dateString}>
        <OccupancyCalendarDate dateString={dateString} labelCallback={labelCallback}></OccupancyCalendarDate>
      </OccupancyPopover>
    ),
    []
  );

  return (
    <React.StrictMode>
      <div className="calendar">
        <OccupancyWindowProvider url={calendarUrl}>
          <CalendarBehaviorContext.Provider value={{ onClick: handleClick }}>
            <MonthsCalendar initialFirstDate={start} dateElementFactory={dateElementFactory}></MonthsCalendar>
            {/* <YearCalendar start={start} dayElement={dayElement}></YearCalendar> */}
          </CalendarBehaviorContext.Provider>
        </OccupancyWindowProvider>
      </div>
    </React.StrictMode>
  );
}

export default OccupancyCalendar;
