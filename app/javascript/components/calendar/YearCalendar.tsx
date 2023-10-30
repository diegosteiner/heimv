import { addMonths, eachMonthOfInterval, subMonths } from "date-fns";
import { getYear, formatISO, eachDayOfInterval, endOfMonth, startOfMonth, getDay } from "date-fns/esm";
import { useState } from "react";
import { CalendarDate, DateElementFactory } from "./CalendarDate";
import { CalendarNav } from "./CalendarNav";
import { parseDate, materializedWeekdays } from "./calendar_functions";

interface YearCalendarProps {
  initialFirstDate?: string | Date;
  dateElementFactory: DateElementFactory;
  months?: number;
}

const monthNameFormatter = new Intl.DateTimeFormat(document.documentElement.lang, {
  month: "long",
  year: "numeric",
});

export default function YearCalendar({ initialFirstDate, dateElementFactory, months }: YearCalendarProps) {
  const [firstDate, setFirstDate] = useState<Date>(startOfMonth(parseDate(initialFirstDate)));
  const nextMonth = () => setFirstDate((prevFirstDate) => addMonths(prevFirstDate, 1));
  const prevMonth = () => setFirstDate((prevFirstDate) => subMonths(prevFirstDate, 1));
  const interval = { start: firstDate, end: addMonths(firstDate, Math.max(months || 12, 12) - 1) };

  return (
    <div className="year-calendar">
      <CalendarNav onNext={nextMonth} onPrev={prevMonth}>
        {getYear(firstDate)}
      </CalendarNav>
      <div className="months">
        <header className="month">
          <div></div>
          {Array.from({ length: 31 }, (_, i) => i + 1).map((n) => (
            <div className="day-of-month" key={n}>
              {n}.
            </div>
          ))}
        </header>
        {eachMonthOfInterval(interval).map((date) => {
          const dateString = formatISO(date, { representation: "date" });
          return (
            <YearCalendarMonth
              dateString={dateString}
              key={dateString}
              dateElementFactory={dateElementFactory}
            ></YearCalendarMonth>
          );
        })}
      </div>
      <CalendarNav onNext={nextMonth} onPrev={prevMonth}>
        {getYear(firstDate)}
      </CalendarNav>
    </div>
  );
}

interface YearCalendarMonthProps {
  dateString: string;
  dateElementFactory: DateElementFactory;
}

export function YearCalendarMonth({ dateString, dateElementFactory }: YearCalendarMonthProps) {
  const date = startOfMonth(parseDate(dateString));

  return (
    <div className="month">
      <div>{monthNameFormatter.format(date)}</div>

      {eachDayOfInterval({ start: date, end: endOfMonth(date) }).map((date) => {
        const dateString = formatISO(date, { representation: "date" });
        const weekdayName = materializedWeekdays[(getDay(date) + 6) % materializedWeekdays.length];
        return (
          <CalendarDate key={dateString} dateString={dateString}>
            {dateElementFactory(dateString, () => weekdayName)}
          </CalendarDate>
        );
      })}
    </div>
  );
}
