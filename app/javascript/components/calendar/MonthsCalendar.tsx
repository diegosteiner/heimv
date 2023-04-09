import { getYear, getDay, formatISO, eachDayOfInterval, endOfMonth, eachMonthOfInterval } from "date-fns/esm";
import { addMonths, getDate, startOfMonth, subMonths } from "date-fns";
import { parseDate, materializedWeekdays, monthNameFormatter } from "./calendar_functions";
import { CalendarNav } from "./CalendarNav";
import { useSwipeable } from "react-swipeable";
import { memo, useState } from "react";
import { CalendarDate, DateElementFactory } from "./CalendarDate";

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
          return (
            <CalendarDate key={dateString} dateString={dateString}>
              {dateElementFactory(dateString, (date) => getDate(date).toString())}
            </CalendarDate>
          );
        })}
      </div>
    </div>
  );
});

interface MonthsCalendarProps {
  initialFirstDate?: string | Date;
  dateElementFactory: DateElementFactory;
}

function MonthsCalendar({ initialFirstDate, dateElementFactory }: MonthsCalendarProps) {
  const [firstDate, setFirstDate] = useState<Date>(parseDate(initialFirstDate));
  const nextMonth = () => setFirstDate((prevFirstDate) => addMonths(prevFirstDate, 1));
  const prevMonth = () => setFirstDate((prevFirstDate) => subMonths(prevFirstDate, 1));
  const interval = { start: firstDate, end: addMonths(firstDate, 11) };
  const swipeHandlers = useSwipeable({
    onSwipedLeft: prevMonth,
    onSwipedRight: nextMonth,
  });

  return (
    <div className="months-calendar" {...swipeHandlers}>
      <CalendarNav onNext={nextMonth} onPrev={prevMonth}>
        <header>{getYear(firstDate)}</header>
      </CalendarNav>
      <div className="months">
        {eachMonthOfInterval(interval).map((date) => {
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
      <CalendarNav onNext={nextMonth} onPrev={prevMonth}>
        <footer>{getYear(firstDate)}</footer>
      </CalendarNav>
    </div>
  );
}

export default MonthsCalendar;
