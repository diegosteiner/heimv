import { addHours, endOfDay, isBefore, startOfDay } from "date-fns/esm";
import { isAfter } from "date-fns/esm";
import { MouseEventHandler, useMemo } from "react";
import { findMostRelevantOccupancy, Occupancy } from "../../models/Occupancy";
import { OccupancyWindow } from "../../models/OccupancyWindow";
import { parseDate } from "./calendar_functions";

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
  const times = useMemo(() => splitByTimeOfDay(date, occupancies), [date, occupancies]);

  return (
    <button
      type="submit"
      name="date"
      disabled={disabledCallback && disabledCallback(date)}
      className={classNameCallback && classNameCallback(date)}
      onClick={onClick}
      value={dateString}
    >
      <label style={{ fontWeight: occupancies.size > 0 ? "bold" : "normal" }}>{labelCallback(date)}</label>
      <div className="halfdays" style={{ backgroundColor: findMostRelevantOccupancy(times.allday)?.color }}>
        <div style={{ backgroundColor: findMostRelevantOccupancy(times.forenoon)?.color }}></div>
        <div style={{ backgroundColor: findMostRelevantOccupancy(times.afternoon)?.color }}></div>
      </div>
    </button>
  );
}

function splitByTimeOfDay(date: Date, occupancies: Set<Occupancy>) {
  const dayStart = startOfDay(date);
  const dayMid = addHours(dayStart, 12);
  const dayEnd = endOfDay(date);
  const times = { allday: new Set<Occupancy>(), forenoon: new Set<Occupancy>(), afternoon: new Set<Occupancy>() };

  occupancies.forEach((occupancy) => {
    const { begins_at, ends_at } = occupancy;

    if (
      (isBefore(begins_at, dayStart) && isAfter(ends_at, dayMid)) ||
      (isBefore(begins_at, dayMid) && isAfter(ends_at, dayEnd))
    )
      return times.allday.add(occupancy);

    if (
      (isAfter(ends_at, dayMid) && isBefore(ends_at, dayEnd)) ||
      (isAfter(begins_at, dayMid) && isBefore(begins_at, dayEnd))
    )
      times.afternoon.add(occupancy);

    if (
      (isAfter(ends_at, dayStart) && isBefore(ends_at, dayEnd)) ||
      (isAfter(begins_at, dayStart) && isBefore(begins_at, dayMid))
    )
      times.forenoon.add(occupancy);
  });

  return times;
}
