import {
  getYear,
  getDay,
  parseISO,
  formatISO,
  isValid,
  eachDayOfInterval,
  endOfMonth,
} from "date-fns/esm";
import * as React from "react";
import styled from "@emotion/styled";
import { getMonth } from "date-fns";

const StyledCalendar = styled.div`
  .calendarNav {
    display: flex;
    font-size: 2em;
    header,
    footer {
      flex: 2 1;
      text-align: center;
    }
    button {
      display: block;
      flex: 1 1;
      text-align: center;
      background: transparent;
      border: none;
    }
  }

  .calendarDay {
    display: block;
    aspect-ratio: 1 / 1;
    text-align: center;
    padding: 0;
  }

  .calendarMonths {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(256px, 1fr));
  }

  .calendarMonth {
    aspect-ratio: 1 / 1;
    margin: 1.5em;
    box-sizing: border-box;

    header {
      font-weight: bold;
      font-size: 1.25em;
      text-align: center;
      padding: 0.25em 0;
    }
    .calendarWeekday {
      font-weight: bold;
      text-align: center;
      padding: 0.25em;
      font-size: 0.75em;
    }
    .calendarDays {
      display: grid;
      grid-template-columns: repeat(7, 1fr);
      gap: 1px;
    }
  }

  .slide-in > * {
    animation: slide-in 0.25s forwards;
  }

  @keyframes slide-in {
    0% {
      transform: translateX(10%);
      opacity: 0;
    }
    100% {
      transform: translateX(0%);
      opacity: 1;
    }
  }
`;

const monthNameFormatter = new Intl.DateTimeFormat(undefined, {
  month: "long",
});
const weekdayNameFormatter = new Intl.DateTimeFormat(undefined, {
  weekday: "short",
});
const materializedWeekdays = [1, 2, 3, 4, 5, 6, 7].map((i) =>
  weekdayNameFormatter.format(new Date(2021, 2, i))
);

function materializedMonths(startDate: Date, monthsCount: number) {
  const startYearMonth = new YearMonth(getYear(startDate), getMonth(startDate));
  const months: YearMonth[] = [];

  for (let i = 0; i < monthsCount; i++) {
    months.push(startYearMonth.addMonths(i));
  }

  return months;
}

class YearMonth {
  constructor(public year: number, public month: number) {}

  firstDate(): Date {
    return new Date(this.year, this.month, 1);
  }

  addMonths(months: number): YearMonth {
    const resultYear = Math.floor((this.year * 12 + this.month + months) / 12);
    const resultMonth = (this.year * 12 + this.month + months) % 12;

    return new YearMonth(resultYear, resultMonth);
  }

  subMonths(months: number): YearMonth {
    return this.addMonths(months * -1);
  }

  toString(): string {
    return `${this.year}/${this.month + 1}`;
  }
}

interface CalendarMonthProps {
  month: YearMonth;
  dayElement(date: Date): React.ReactElement;
}

function CalendarMonth({ month, dayElement }: CalendarMonthProps) {
  const date = month.firstDate();
  const monthStartsAfter = (getDay(date) + 6) % 7;
  const daysOfMonth = eachDayOfInterval({
    start: date,
    end: endOfMonth(date),
  });
  return (
    <div className="calendarMonth">
      <header>{monthNameFormatter.format(date)}</header>
      <div className="calendarDays">
        {materializedWeekdays.map((weekdayName) => (
          <div key={`weekday-${weekdayName}`} className="calendarWeekday">
            {weekdayName}
          </div>
        ))}
        {Array.from(Array(monthStartsAfter)).map((e, i) => (
          <div key={i} className="calendarDay spacer"></div>
        ))}
        {daysOfMonth.map((day) => {
          const dateString = formatISO(day, { representation: "date" });
          return (
            <time
              className="calendarDay"
              dateTime={dateString}
              key={`day-${dateString}`}
            >
              {dayElement(day)}
            </time>
          );
        })}
      </div>
    </div>
  );
}

interface CalendarNavProps {
  onPrev(): void;
  onNext(): void;
  children?: React.ReactNode;
}

function CalendarNav({ onPrev, onNext, children }: CalendarNavProps) {
  return (
    <nav className="calendarNav">
      <button onClick={onPrev} className="prev" type="button">
        ←
      </button>
      {children}
      <button onClick={onNext} className="next" type="button">
        →
      </button>
    </nav>
  );
}

const CalendarMonthMemo = React.memo(CalendarMonth);
interface CalendarProps {
  start?: string | Date;
  monthsCount?: number | string;
  dayElement(date: Date): React.ReactElement;
}

function Calendar({ start, dayElement, monthsCount = 12 }: CalendarProps) {
  const monthsCountNumber: number = Number.isInteger(monthsCount)
    ? (monthsCount as number)
    : parseInt(monthsCount.toString());

  let startDate = typeof start === "string" ? parseISO(start) : start;
  if (!isValid(startDate)) startDate = new Date();

  const [visibleMonths, setVisibleMonths] = React.useState<YearMonth[]>(() =>
    materializedMonths(startDate as Date, monthsCountNumber)
  );
  const year = Array.from(
    new Set(visibleMonths.map((month) => month.year))
  ).join("/");
  const [touchStart, setTouchStart] = React.useState<{
    x: number;
    y: number;
  } | null>(null);
  const prevMonth = () =>
    setVisibleMonths((visibleMonthsWas) => {
      const repealed = visibleMonthsWas.pop();
      return repealed
        ? [repealed.subMonths(monthsCountNumber), ...visibleMonthsWas]
        : visibleMonthsWas;
    });
  const nextMonth = () =>
    setVisibleMonths((visibleMonthsWas) => {
      const repealed = visibleMonthsWas.shift();
      return repealed
        ? [...visibleMonthsWas, repealed.addMonths(monthsCountNumber)]
        : visibleMonthsWas;
    });
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
    if (diff > 0) return nextMonth();
    if (diff < 0) return prevMonth();
  };

  return (
    <StyledCalendar onTouchStart={handleTouchStart} onTouchEnd={handleTouchEnd}>
      <CalendarNav onNext={nextMonth} onPrev={prevMonth}>
        <header>{year}</header>
      </CalendarNav>
      <div className="calendarMonths">
        {visibleMonths.map((month) => (
          <CalendarMonthMemo
            key={`month-${month.toString()}`}
            month={month}
            dayElement={dayElement}
          ></CalendarMonthMemo>
        ))}
      </div>
      <CalendarNav onNext={nextMonth} onPrev={prevMonth}></CalendarNav>
    </StyledCalendar>
  );
}

export default Calendar;
