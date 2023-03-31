import { css } from "@emotion/react";
import { eachMonthOfInterval, endOfYear } from "date-fns";
import { getYear, getDay, parseISO, formatISO, isValid, eachDayOfInterval, endOfMonth } from "date-fns/esm";
import startOfYear from "date-fns/startOfYear";
import * as React from "react";
import { initializeDate, monthNameFormatter } from "./calendar_functions";

interface YearCalendarProps {
  start?: string | Date;
  dayElement(dateString: string): React.ReactElement;
}

const style = css`
  .year-calendar-month {
    display: grid;
    grid-template-columns: minmax(5rem, auto) repeat(31, 2rem);
    height: 1.5rem;
  }

  .calendarDay {
    font-size: 0.8em;
    text-align: center;
  }

  .dayOfMonth {
    text-align: center;
    font-weight: bold;
  }
`;

export default function YearCalendar({ start, dayElement }: YearCalendarProps) {
  const firstDateOfYear = startOfYear(initializeDate(start));

  return (
    <div css={style}>
      <div className="year-calendar-month">
        <div></div>
        {Array.from({ length: 31 }, (_, i) => i + 1).map((n) => (
          <div className="dayOfMonth" key={n}>
            {n}.
          </div>
        ))}
      </div>
      {eachMonthOfInterval({ start: firstDateOfYear, end: endOfYear(firstDateOfYear) }).map((firstDateOfMonth) => (
        <YearCalendarMonth
          key={formatISO(firstDateOfMonth)}
          firstDateOfMonth={firstDateOfMonth}
          dayElement={dayElement}
        ></YearCalendarMonth>
      ))}
    </div>
  );
}

interface YearCalendarMonthProps {
  firstDateOfMonth: Date;
  dayElement(dateString: string): React.ReactElement;
}

export function YearCalendarMonth({ firstDateOfMonth, dayElement }: YearCalendarMonthProps) {
  return (
    <div className="year-calendar-month">
      <div>{monthNameFormatter.format(firstDateOfMonth)}</div>

      {eachDayOfInterval({ start: firstDateOfMonth, end: endOfMonth(firstDateOfMonth) }).map((date) => {
        const dateString = formatISO(date, { representation: "date" });
        return (
          <time className="calendarDay" dateTime={dateString} key={`day-${dateString}`}>
            {dayElement(dateString)}
          </time>
        );
      })}
    </div>
  );
}
