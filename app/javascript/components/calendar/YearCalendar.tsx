import { addMonths, addYears, eachMonthOfInterval, startOfYear, subYears } from "date-fns";
import { getYear, formatISO, eachDayOfInterval, endOfMonth, startOfMonth, getDay } from "date-fns/esm";
import { useState } from "react";
import { CalendarDate, DateElementFactory } from "./CalendarDate";
import { CalendarNav } from "./CalendarNav";
import { parseDate, monthNameFormatter, materializedWeekdays } from "./calendar_functions";

interface YearCalendarProps {
  initialFirstDate?: string | Date;
  dateElementFactory: DateElementFactory;
}

export default function YearCalendar({ initialFirstDate, dateElementFactory }: YearCalendarProps) {
  const [firstDate, setFirstDate] = useState<Date>(startOfMonth(parseDate(initialFirstDate)));
  const nextMonth = () => setFirstDate((prevFirstDate) => addYears(prevFirstDate, 1));
  const prevMonth = () => setFirstDate((prevFirstDate) => subYears(prevFirstDate, 1));
  const interval = { start: firstDate, end: addMonths(firstDate, 11) };

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
