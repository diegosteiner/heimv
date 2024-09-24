import { cx } from "@emotion/css";
import { isAfter, isBefore } from "date-fns";
import { formatISO, isSameDay, parseISO } from "date-fns";
import { useCallback, useContext, useRef, useState } from "react";
import * as React from "react";
import { OccupancyWindow } from "../../models/OccupancyWindow";
import { isBetweenDates, parseISOorUndefined, toInterval } from "../../services/date";
import Calendar, { ViewType } from "../calendar/Calendar";
import { CalendarDate, DateElementFactory } from "../calendar/CalendarDate";
import { OccupancyWindowContext } from "./OccupancyWindowContext";
import { OccupiedCalendarDate } from "./OccupiedCalendarDate";

function highlight(
  date: Date,
  beginsAt: Date | undefined,
  endsAt: Date | undefined,
  hovering: Date | undefined,
): boolean {
  if (!date) return false;
  const { start, end } = toInterval([beginsAt, endsAt]);
  if (!start) return !!hovering && isSameDay(date, hovering);
  if (isSameDay(date, start)) return true;
  if (!end) return !!hovering && (isSameDay(date, hovering) || isBetweenDates(date, [start, hovering]));
  return (hovering && isSameDay(date, hovering)) || isBetweenDates(date, [start, end]);
}

function disable(date: Date, occupancyWindow?: OccupancyWindow) {
  if (!occupancyWindow) return false;
  return isBefore(date, occupancyWindow.start) || isAfter(date, occupancyWindow.end);
}

interface OccupancyIntervalCalendarProps {
  defaultView?: ViewType;
  months?: number;
  beginsAtString?: string | undefined;
  endsAtString?: string | undefined;
  onChange?: (value: { endsAt?: Date | undefined; beginsAt?: Date | undefined }) => void;
}

function OccupancyIntervalCalendar({
  beginsAtString,
  endsAtString,
  defaultView,
  months,
  onChange,
}: OccupancyIntervalCalendarProps) {
  const occupancyWindow = useContext(OccupancyWindowContext);
  const beginsAt = parseISOorUndefined(beginsAtString),
    endsAt = parseISOorUndefined(endsAtString);
  const [hovering, setHovering] = useState<Date | undefined>();
  const setHoveringTimeout = useRef<ReturnType<typeof setTimeout> | undefined>();

  const handleClick = useCallback(
    (date: Date) => {
      if (!onChange || !date) return;
      if ((beginsAt && endsAt) || (!beginsAt && !endsAt)) {
        onChange({ beginsAt: date, endsAt: undefined });
        return;
      }
      const interval = toInterval([beginsAt, endsAt, date]);
      onChange({ beginsAt: interval.start, endsAt: interval.end });
    },
    [beginsAt, endsAt],
  );
  const handleHover = (date: Date | undefined) => {
    if (setHoveringTimeout.current) {
      clearTimeout(setHoveringTimeout.current);
      setHoveringTimeout.current = undefined;
    }

    date ? setHovering(date) : (setHoveringTimeout.current = setTimeout(() => setHovering(undefined), 100));
  };

  const dateElementFactory: DateElementFactory = useCallback(
    (dateString: string, labelCallback: (date: Date) => string) => {
      const date = parseISO(dateString);
      const disabled = disable(date, occupancyWindow);
      const highlighted = highlight(date, beginsAt, endsAt, hovering);

      return (
        <CalendarDate dateString={dateString} key={dateString}>
          <button
            disabled={disabled}
            className={cx({ "date-action": true, highlighted })}
            onClick={() => handleClick(date)}
            onMouseEnter={() => handleHover(date)}
            onMouseLeave={() => handleHover(undefined)}
          >
            <OccupiedCalendarDate
              dateString={dateString}
              label={labelCallback(date)}
              occupancyWindow={occupancyWindow}
            ></OccupiedCalendarDate>
          </button>
        </CalendarDate>
      );
    },
    [occupancyWindow, beginsAt, endsAt, hovering],
  );

  return (
    <Calendar
      initialFirstDate={formatISO(beginsAt || new Date())}
      months={months}
      defaultView={defaultView}
      dateElementFactory={dateElementFactory}
    ></Calendar>
  );
}

export default OccupancyIntervalCalendar;
