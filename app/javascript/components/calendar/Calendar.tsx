import addMonths from "date-fns/addMonths";
import getYear from "date-fns/getYear";
import subMonths from "date-fns/subMonths";
import { type Dispatch, type SetStateAction, createContext, useState } from "react";
import * as React from "react";
import { parseDate } from "../../services/date";
import type { DateElementFactory } from "./CalendarDate";
import { CalendarNav } from "./CalendarNav";
import MonthsCalendar from "./MonthsCalendar";
import YearCalendar from "./YearCalendar";

type CalendarProps = {
  initialFirstDate?: string;
  dateElementFactory: DateElementFactory;
  defaultView?: ViewType;
  months?: number;
};

export type ViewType = "months" | "year";
type CalendarViewContextType = {
  view: ViewType;
  setView?: Dispatch<SetStateAction<ViewType>>;
};
export const CalendarViewContext = createContext<CalendarViewContextType>({ view: "months" });

function Calendar({ initialFirstDate, defaultView, months, dateElementFactory }: CalendarProps) {
  const [view, setView] = useState<ViewType>(defaultView || "months");
  const [firstDate, setFirstDate] = useState<Date>(parseDate(initialFirstDate));
  const gotoNextMonth = () => setFirstDate((prevFirstDate) => addMonths(prevFirstDate, 1));
  const gotoPrevMonth = () => setFirstDate((prevFirstDate) => subMonths(prevFirstDate, 1));
  const gotoToday = () => setFirstDate(new Date());

  return (
    <CalendarViewContext.Provider value={{ view, setView }}>
      <div className="calendar">
        <CalendarNav onNext={gotoNextMonth} onPrev={gotoPrevMonth} onToday={gotoToday}>
          {getYear(firstDate)}
        </CalendarNav>
        {({ months: MonthsCalendar, year: YearCalendar }[view] || MonthsCalendar)({
          firstDate,
          months,
          dateElementFactory,
        })}
        <CalendarNav onNext={gotoNextMonth} onPrev={gotoPrevMonth} onToday={gotoToday}>
          {getYear(firstDate)}
        </CalendarNav>
      </div>
    </CalendarViewContext.Provider>
  );
}

export default Calendar;
