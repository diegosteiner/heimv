import {
  addMonths,
  eachDayOfInterval,
  eachMonthOfInterval,
  endOfMonth,
  formatISO,
  getDay,
  startOfMonth,
} from "date-fns";
import { materializedWeekdays, monthNameFormatter, parseDate } from "../../services/date";
import type { DateElementFactory } from "./CalendarDate";

interface YearCalendarProps {
  firstDate: Date;
  dateElementFactory: DateElementFactory;
  months?: number;
}

export default function YearCalendar({ firstDate, dateElementFactory }: YearCalendarProps) {
  return (
    <div className="year-calendar">
      <div className="months">
        <header className="month">
          <div />
          {Array.from({ length: 31 }, (_, i) => i + 1).map((n) => (
            <div className="day-of-month" key={n}>
              {n}.
            </div>
          ))}
        </header>
        {eachMonthOfInterval({ start: firstDate, end: addMonths(firstDate, 11) }).map((date) => {
          const dateString = formatISO(date, { representation: "date" });
          return <YearCalendarMonth dateString={dateString} key={dateString} dateElementFactory={dateElementFactory} />;
        })}
      </div>
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

        return dateElementFactory(dateString, () => weekdayName);
      })}
    </div>
  );
}
