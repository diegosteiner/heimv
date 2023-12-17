import { Dispatch, SetStateAction, createContext, useState } from "react";
import MonthsCalendar from "./MonthsCalendar";
import YearCalendar from "./YearCalendar";
import * as React from "react";
import { DateElementFactory } from "./CalendarDate";
import { CalendarNav } from "./CalendarNav";
import getYear from "date-fns/getYear";
import addMonths from "date-fns/addMonths";
import subMonths from "date-fns/subMonths";
import { parseDate } from "../../services/date";

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
