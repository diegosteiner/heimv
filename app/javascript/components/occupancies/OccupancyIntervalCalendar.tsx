import { useCallback, useContext, useState } from "react";
import { CalendarDate, DateElementFactory } from "../calendar/CalendarDate";
import { isAfter, isBefore } from "date-fns/esm";
import * as React from "react";
import { formatISO, isEqual, isWithinInterval, parseISO } from "date-fns";
import Calendar, { ViewType } from "../calendar/Calendar";
import { DateWithOccupancies } from "./DateWithOccupancies";
import { OccupancyWindowContext } from "./OccupancyWindowContext";
import { parseISOorUndefined, toInterval } from "../../services/date";
import { cx } from "@emotion/css";
import { OccupancyWindow } from "../../models/OccupancyWindow";
import { DateInterval } from "../../types";

function highlight(date: Date, { start, end }: DateInterval, hovering: Date | undefined): boolean {
  if (!date) return false;
  if (start && end) return isWithinInterval(date, { start, end });
  if (!hovering) return false;
  if (!start && !end) return isEqual(date, hovering);
  return isWithinInterval(date, toInterval([(start || end) as Date, hovering]));
}

function disable(date: Date, occupancyWindow?: OccupancyWindow) {
  return !occupancyWindow || isBefore(date, occupancyWindow.start) || isAfter(date, occupancyWindow.end);
}

interface OccupancyIntervalCalendarProps {
  defaultView?: ViewType;
  beginsAtString?: string | undefined;
  endsAtString?: string | undefined;
  onChange?: (interval: DateInterval) => void;
}

function OccupancyIntervalCalendar({
  beginsAtString,
  endsAtString,
  defaultView,
  onChange,
}: OccupancyIntervalCalendarProps) {
  const occupancyWindow = useContext(OccupancyWindowContext);
  const beginsAt = parseISOorUndefined(beginsAtString),
    endsAt = parseISOorUndefined(endsAtString);
  const [hovering, setHoveringDate] = useState<Date | undefined>();
  const handleClick = (date: Date) => {
    if (!onChange || !date) return;
    if ((beginsAt && endsAt) || (!beginsAt && !endsAt)) {
      onChange({ start: date, end: undefined });
      return;
    }
    onChange(toInterval([(beginsAt || endsAt) as Date, date]));
  };

  const dateElementFactory: DateElementFactory = useCallback(
    (dateString: string, labelCallback: (date: Date) => string) => {
      const date = parseISO(dateString);
      const disabled = disable(date, occupancyWindow);
      const highlighted = highlight(date, { start: beginsAt, end: endsAt }, hovering);

      return (
        <CalendarDate dateString={dateString} key={dateString}>
          <button
            disabled={disabled}
            className={cx({ "date-action": true, highlighted })}
            onClick={() => handleClick(date)}
            onMouseEnter={() => setHoveringDate(date)}
            onMouseLeave={() => setHoveringDate(undefined)}
          >
            <DateWithOccupancies
              dateString={dateString}
              label={labelCallback(date)}
              occupancyWindow={occupancyWindow}
            ></DateWithOccupancies>
          </button>
        </CalendarDate>
      );
    },
    [occupancyWindow, beginsAt, endsAt, hovering],
  );

  return (
    <Calendar
      initialFirstDate={formatISO(beginsAt || new Date())}
      defaultView={defaultView}
      dateElementFactory={dateElementFactory}
    ></Calendar>
  );
}

export default OccupancyIntervalCalendar;
