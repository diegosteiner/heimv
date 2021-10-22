import * as React from "react";
import {
  eachDayOfInterval,
  startOfMonth,
  endOfMonth,
  getDay,
  getMonth,
  eachMonthOfInterval,
  addMonths,
  getYear,
  subMonths,
} from "date-fns";

import * as styles from "./Calendar.module.scss";
const { useState, cloneElement } = React;

interface CalendarMonthProps {
  date: Date;
  locale: Locale;
}

type MonthNames = [
  string,
  string,
  string,
  string,
  string,
  string,
  string,
  string,
  string,
  string,
  string,
  string
];
type WeekdayNames = [string, string, string, string, string, string, string];

type Locale = {
  weekdayNames: WeekdayNames;
  monthNames: MonthNames;
};

const CalendarMonth: React.FC<CalendarMonthProps> = ({
  date,
  locale,
  children,
}) => {
  const daysOfMonth = eachDayOfInterval({
    start: startOfMonth(date),
    end: endOfMonth(date),
  });
  const monthName = locale.monthNames[getMonth(date)];
  const monthStartsAfter = (getDay(startOfMonth(date)) + 6) % 7;

  return (
    <div className={styles.calendarMonth}>
      <header>{monthName}</header>
      <div className={styles.calendarDays}>
        {locale.weekdayNames.map((weekday) => (
          <div key={weekday} className={styles.calendarWeekday}>
            {weekday}
          </div>
        ))}
        {[...Array(monthStartsAfter)].map((e, i) => (
          <div key={i} className="calendar-day spacer"></div>
        ))}
        {daysOfMonth.map((day) => (
          <time
            className={styles.calendarDay}
            dateTime={day.toISOString()}
            key={`day-${day.toISOString()}`}
          >
            {cloneElement(children as React.ReactElement, { date: day })}
          </time>
        ))}
      </div>
    </div>
  );
};

const calendarYearName = (months: Date[]): string => {
  return [
    ...Array.from(new Set<number>(months.map((month) => getYear(month)))),
  ].join("/");
};

const monthsInWindow = (firstDate: Date, length: number) => {
  return eachMonthOfInterval({
    start: firstDate,
    end: addMonths(startOfMonth(firstDate), length - 1),
  });
};

const locale: Locale = {
  weekdayNames: ["Mo", "Di", "Mi", "Do", "Fr", "Sa", "So"],
  monthNames: [
    "Januar",
    "Februar",
    "März",
    "April",
    "Mai",
    "Juni",
    "Juli",
    "August",
    "September",
    "Oktober",
    "November",
    "Dezember",
  ],
};

interface CalendarProps {
  firstMonth?: Date;
  displayMonths?: number;
}

const Calendar: React.FC<CalendarProps> = ({
  firstMonth = null,
  displayMonths = 8,
  children,
}) => {
  firstMonth = startOfMonth(firstMonth || new Date());
  const [months, setMonths] = useState<Date[]>(
    monthsInWindow(firstMonth, displayMonths)
  );
  const [touchStart, setTouchStart] = useState<{ x: number; y: number } | null>(
    null
  );
  const prev = () =>
    setMonths(monthsInWindow(subMonths(months[0], 1), displayMonths));
  const next = () =>
    setMonths(monthsInWindow(addMonths(months[0], 1), displayMonths));
  const handleTouchStart = ({ changedTouches }: React.TouchEvent) => {
    setTouchStart({
      x: changedTouches[0].screenX,
      y: changedTouches[0].screenY,
    });
  };
  const handleTouchEnd = (event: React.TouchEvent) => {
    if (!touchStart) return;
    const diff = touchStart.x - event.changedTouches[0].screenX;

    if (Math.abs(diff) < 100) return;
    if (diff > 0) return next();
    if (diff < 0) return prev();
  };

  return (
    <div
      className={styles.calendarMain}
      onTouchStart={handleTouchStart}
      onTouchEnd={handleTouchEnd}
    >
      <nav className={styles.calendarNav}>
        <button onClick={prev}>←</button>
        <header>{calendarYearName(months)}</header>
        <button onClick={next}>→</button>
      </nav>
      <div className={styles.calendarMonths}>
        {months.map((month) => (
          <CalendarMonth
            date={month}
            key={`month-${month.toISOString()}`}
            locale={locale}
          >
            {children}
          </CalendarMonth>
        ))}
      </div>
      <nav className={styles.calendarNav}>
        <button onClick={prev}>←</button>
        <button onClick={next}>→</button>
      </nav>
    </div>
  );
};

export default Calendar;
