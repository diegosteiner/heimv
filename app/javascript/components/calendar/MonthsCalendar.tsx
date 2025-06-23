import {
  addMonths,
  eachDayOfInterval,
  eachMonthOfInterval,
  endOfMonth,
  formatISO,
  getDate,
  getDay,
  startOfMonth,
} from "date-fns";
import { memo } from "react";
import { materializedWeekdays, monthNameFormatter, parseDate } from "../../services/date";
import type { DateElementFactory } from "./CalendarDate";

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
        {Array.from(Array(monthStartsAfter)).map((_e, i) => (
          // biome-ignore lint/suspicious/noArrayIndexKey: placeholder
          <div key={i} className="date spacer" />
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

function MonthsCalendar({ firstDate, months, dateElementFactory }: MonthsCalendarProps) {
  return (
    <div className="months-calendar">
      <div className="months">
        {eachMonthOfInterval({ start: firstDate, end: addMonths(firstDate, (months || 8) - 1) }).map((date) => {
          const dateString = formatISO(date, { representation: "date" });
          return <CalendarMonth dateString={dateString} key={dateString} dateElementFactory={dateElementFactory} />;
        })}
      </div>
    </div>
  );
}

export default MonthsCalendar;
