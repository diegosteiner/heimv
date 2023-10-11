import {
  addMonths,
  getDate,
  startOfMonth,
  getDay,
  eachDayOfInterval,
  endOfMonth,
  formatISO,
  eachMonthOfInterval,
} from "date-fns";
import { parseDate, materializedWeekdays, monthNameFormatter } from "./functions";
import { memo } from "react";
import { DateElementFactory } from "./CalendarDate";

interface CalendarMonthProps {
  dateString: string;
  dateElementFactory: DateElementFactory;
}
const CalendarMonth = memo(function CalendarMonth({ dateString, dateElementFactory }: CalendarMonthProps) {
  const date = startOfMonth(parseDate(dateString));
  const monthStartsAfter = (getDay(date) + 6) % 7;

  return (
    <div className="month">
      <header>
        <h3>{monthNameFormatter.format(date)}</h3>
        <div className="weekdays">
          {materializedWeekdays.map((weekdayName) => (
            <div key={`weekday-${weekdayName}`}>{weekdayName}</div>
          ))}
        </div>
      </header>
      <div className="dates">
        {Array.from(Array(monthStartsAfter)).map((e, i) => (
          <div key={i} className="date spacer"></div>
        ))}
        {eachDayOfInterval({ start: date, end: endOfMonth(date) }).map((date) => {
          const dateString = formatISO(date, { representation: "date" });

          return dateElementFactory(dateString, (date) => getDate(date).toString());
        })}
      </div>
    </div>
  );
});

interface MonthsCalendarProps {
  firstDate: Date;
  dateElementFactory: DateElementFactory;
  months?: number;
}

function MonthsCalendar({ firstDate, dateElementFactory }: MonthsCalendarProps) {
  return (
    <div className="months-calendar">
      <div className="months">
        {eachMonthOfInterval({ start: firstDate, end: addMonths(firstDate, 7) }).map((date) => {
          const dateString = formatISO(date, { representation: "date" });
          return (
            <CalendarMonth
              dateString={dateString}
              key={dateString}
              dateElementFactory={dateElementFactory}
            ></CalendarMonth>
          );
        })}
      </div>
    </div>
  );
}

export default MonthsCalendar;
