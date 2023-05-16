import { isWithinInterval } from "date-fns";
import { addHours, endOfDay, isBefore, startOfDay } from "date-fns/esm";
import { isAfter } from "date-fns/esm";
import { MouseEventHandler, useMemo } from "react";
import { findMostRelevantOccupancy, Occupancy } from "../../models/Occupancy";
import { OccupancyWindow } from "../../models/OccupancyWindow";
import { parseDate } from "./calendar_functions";
import { OccupancyPopover } from "./OccupancyPopover";

interface OccupancyCalendarDateProps {
  dateString: string;
  labelCallback: (date: Date) => string;
  disabledCallback?: (date: Date) => boolean;
  classNameCallback?: (date: Date) => string;
  onClick?: MouseEventHandler;
  occupancyWindow?: OccupancyWindow;
}

export function OccupancyCalendarDate({
  dateString,
  labelCallback,
  occupancyWindow,
  classNameCallback,
  disabledCallback,
  onClick,
}: OccupancyCalendarDateProps) {
  const date = startOfDay(parseDate(dateString));
  const occupancies = occupancyWindow?.occupiedDates?.get(dateString) || new Set<Occupancy>();
  const slots = useMemo(() => splitSlots(date, occupancies), [date, occupancies]);
  const classNames = [
    "occupancy-calendar-date",
    occupancies.size > 0 && "has-occupancies",
    classNameCallback && classNameCallback(date),
  ].filter((className) => className);

  return useMemo(
    () => (
      <button
        type="submit"
        name="date"
        disabled={disabledCallback && disabledCallback(date)}
        className={classNames.join(" ")}
        onClick={onClick}
        value={dateString}
      >
        <OccupancyPopover dateString={dateString} occupancyWindow={occupancyWindow}></OccupancyPopover>
        <div className="wrapper">
          <div className="label">{labelCallback(date)}</div>
          <div className="slots" style={{ backgroundColor: findMostRelevantOccupancy(slots.allday)?.color }}>
            <div
              className="forenoon"
              style={{ backgroundColor: findMostRelevantOccupancy(slots.forenoon)?.color }}
            ></div>
            <div
              className="afternoon"
              style={{ backgroundColor: findMostRelevantOccupancy(slots.afternoon)?.color }}
            ></div>
          </div>
        </div>
      </button>
    ),
    [date, occupancies]
  );
}

function splitSlots(date: Date, occupancies: Set<Occupancy>) {
  const dayStart = startOfDay(date);
  const dayMid = addHours(dayStart, 12);
  const dayEnd = endOfDay(date);
  const allDayInterval = { start: dayStart, end: dayEnd };
  const forenoonInterval = { start: dayStart, end: dayMid };
  const afternoonInterval = { start: dayMid, end: dayEnd };
  const slots = { allday: new Set<Occupancy>(), forenoon: new Set<Occupancy>(), afternoon: new Set<Occupancy>() };

  occupancies.forEach((occupancy) => {
    const { begins_at, ends_at } = occupancy;

    // begins before and ends after that day => allDay
    if (isBefore(begins_at, dayStart) && isAfter(ends_at, dayEnd)) return slots.allday.add(occupancy);

    // ends in the afternoon or begins in the forenoon, there are no others => allDay
    if (
      occupancies.size == 1 &&
      (isWithinInterval(ends_at, afternoonInterval) || isWithinInterval(begins_at, forenoonInterval))
    )
      return slots.allday.add(occupancy);

    // ends that day => foreNoon
    if (isWithinInterval(ends_at, allDayInterval)) return slots.forenoon.add(occupancy);

    // begins that day => afternoon
    if (isWithinInterval(begins_at, allDayInterval)) return slots.afternoon.add(occupancy);
  });

  return slots;
}
