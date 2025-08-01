import { cx } from "@emotion/css";
import { formatISO, isAfter, isBefore, isSameDay, parseISO } from "date-fns";
import { use, useCallback, useRef, useState } from "react";
import type { OccupancyWindow } from "../../models/OccupancyWindow";
import { isBetweenDates, parseISOorUndefined, toInterval } from "../../services/date";
import Calendar, { type ViewType } from "../calendar/Calendar";
import { CalendarDate, type DateElementFactory } from "../calendar/CalendarDate";
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

export default function OccupancyIntervalCalendar({
  beginsAtString,
  endsAtString,
  defaultView,
  months,
  onChange,
}: OccupancyIntervalCalendarProps) {
  const occupancyWindow = use(OccupancyWindowContext);
  const beginsAt = parseISOorUndefined(beginsAtString);
  const endsAt = parseISOorUndefined(endsAtString);
  const [hovering, setHovering] = useState<Date | undefined>();
  const setHoveringTimeout = useRef<ReturnType<typeof setTimeout> | undefined>(undefined);

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
    [beginsAt, endsAt, onChange],
  );
  const handleHover = useCallback((date: Date | undefined) => {
    if (setHoveringTimeout.current) {
      clearTimeout(setHoveringTimeout.current);
      setHoveringTimeout.current = undefined;
    }

    if (date) return setHovering(date);

    setHoveringTimeout.current = setTimeout(() => setHovering(undefined), 100);
  }, []);

  const dateElementFactory: DateElementFactory = useCallback(
    (dateString: string, labelCallback: (date: Date) => string) => {
      const date = parseISO(dateString);
      const disabled = disable(date, occupancyWindow);
      const highlighted = highlight(date, beginsAt, endsAt, hovering);

      return (
        <CalendarDate dateString={dateString} key={dateString}>
          <button
            type="button"
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
            />
          </button>
        </CalendarDate>
      );
    },
    [occupancyWindow, beginsAt, endsAt, hovering, handleClick, handleHover],
  );

  return (
    <Calendar
      initialFirstDate={formatISO(beginsAt || new Date())}
      months={months}
      defaultView={defaultView}
      dateElementFactory={dateElementFactory}
    />
  );
}
