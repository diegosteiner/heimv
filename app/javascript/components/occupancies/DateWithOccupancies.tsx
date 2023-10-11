import { isWithinInterval } from "date-fns";
import { addHours, endOfDay, isBefore, startOfDay } from "date-fns/esm";
import { isAfter } from "date-fns/esm";
import { MouseEventHandler, useMemo } from "react";
import { findMostRelevantOccupancy, Occupancy } from "../../models/Occupancy";
import { OccupancyWindow } from "../../models/OccupancyWindow";
import { parseDate } from "../calendar/functions";
import { OccupancyPopover } from "./OccupancyPopover";

interface DateWithOccupanciesProps {
  dateString: string;
  onClick?: MouseEventHandler;
  occupancyWindow?: OccupancyWindow;
}

export function DateWithOccupancies({ dateString, occupancyWindow }: DateWithOccupanciesProps) {
  const date = startOfDay(parseDate(dateString));
  const occupancies = occupancyWindow?.occupiedDates?.get(dateString) || new Set<Occupancy>();
  const slots = useMemo(() => splitSlots(date, occupancies), [date, occupancies]);
  const classNames = ["occupancy-calendar-date", occupancies.size > 0 && "has-occupancies"];
  return useMemo(
    () => (
      <div className={classNames.filter((className) => className).join(" ")}>
        <OccupancyPopover dateString={dateString} occupancyWindow={occupancyWindow}></OccupancyPopover>
        <svg viewBox="0 0 48 48" preserveAspectRatio="xMidYMid meet">
          {Array.from(slots.allday).some(Boolean) && (
            <rect
              className="occupancy-slot"
              y="0"
              x="0"
              width="48"
              height="48"
              fill={findMostRelevantOccupancy(slots.allday)?.color}
            ></rect>
          )}
          {Array.from(slots.forenoon).some(Boolean) && (
            <polygon
              className="occupancy-slot"
              points="0,0 0,46 46,0"
              fill={findMostRelevantOccupancy(slots.forenoon)?.color}
            />
          )}
          {Array.from(slots.afternoon).some(Boolean) && (
            <polygon
              className="occupancy-slot"
              points="48,0 48,48 0,48"
              fill={findMostRelevantOccupancy(slots.afternoon)?.color}
            />
          )}
        </svg>
      </div>
    ),
    [date, occupancies],
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
