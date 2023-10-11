import { Dispatch, SetStateAction, createContext, useState } from "react";
import MonthsCalendar from "./MonthsCalendar";
import YearCalendar from "./YearCalendar";
import * as React from "react";
import { DateElementFactory } from "./CalendarDate";
import { CalendarNav } from "./CalendarNav";
import getYear from "date-fns/getYear";
import { parseDate } from "./functions";
import addMonths from "date-fns/addMonths";
import subMonths from "date-fns/subMonths";

interface CalendarProps {
  initialFirstDate?: string;
  dateElementFactory: DateElementFactory;
  defaultView?: ViewType;
}

export type ViewType = "months" | "year";
type CalendarViewContextType = {
  view: ViewType;
  setView?: Dispatch<SetStateAction<ViewType>>;
};
export const CalendarViewContext = createContext<CalendarViewContextType>({ view: "months" });

function Calendar({ initialFirstDate, defaultView, dateElementFactory }: CalendarProps) {
  const [view, setView] = useState<ViewType>(defaultView || "months");
  const [firstDate, setFirstDate] = useState<Date>(parseDate(initialFirstDate));
  const nextMonth = () => setFirstDate((prevFirstDate) => addMonths(prevFirstDate, 1));
  const prevMonth = () => setFirstDate((prevFirstDate) => subMonths(prevFirstDate, 1));

  return (
    <React.StrictMode>
      <CalendarViewContext.Provider value={{ view, setView }}>
        <div className="calendar">
          <CalendarNav onNext={nextMonth} onPrev={prevMonth}>
            {getYear(firstDate)}
          </CalendarNav>
          {({ months: MonthsCalendar, year: YearCalendar }[view] || MonthsCalendar)({
            firstDate,
            dateElementFactory,
          })}
          <CalendarNav onNext={nextMonth} onPrev={prevMonth}>
            {getYear(firstDate)}
          </CalendarNav>
          ;
        </div>
      </CalendarViewContext.Provider>
    </React.StrictMode>
  );
}

export default Calendar;
