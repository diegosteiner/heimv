import React, { useState, cloneElement } from 'react';
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
} from 'date-fns/esm';
import styles from './Calendar.module.scss';

const Month = ({ date, locale, children }) => {
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
            date={day.toISOString()}
            key={`day-${day.toISOString()}`}
          >
            {cloneElement(children, { date: day })}
          </time>
        ))}
      </div>
    </div>
  );
};

const calendarYearName = (months) => {
  return [...new Set(months.map((month) => getYear(month)))].join('/');
};

const monthsInWindow = (firstDate, length) => {
  return eachMonthOfInterval({
    start: firstDate,
    end: addMonths(startOfMonth(firstDate), length - 1),
  });
};

const locale = {
  weekdayNames: ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'],
  monthNames: [
    'Januar',
    'Februar',
    'März',
    'April',
    'Mai',
    'Juni',
    'Juli',
    'August',
    'September',
    'Oktober',
    'November',
    'Dezember',
  ],
};

const Calendar = ({ firstMonth = null, displayMonths = 8, children }) => {
  firstMonth = startOfMonth(firstMonth || new Date());
  const [months, setMonths] = useState(
    monthsInWindow(firstMonth, displayMonths),
  );
  const [touchStart, setTouchStart] = useState({});
  const prev = () =>
    setMonths(monthsInWindow(subMonths(months[0], 1), displayMonths));
  const next = () =>
    setMonths(monthsInWindow(addMonths(months[0], 1), displayMonths));
  const handleTouchStart = ({ changedTouches }) => {
    setTouchStart({
      x: changedTouches[0].screenX,
      y: changedTouches[0].screenY,
    });
  };
  const handleTouchEnd = (event) => {
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
          <Month
            date={month}
            key={`month-${month.toISOString()}`}
            locale={locale}
          >
            {children}
          </Month>
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
