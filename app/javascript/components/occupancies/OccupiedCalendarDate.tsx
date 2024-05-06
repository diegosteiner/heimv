import { isWithinInterval } from "date-fns";
import { addHours, endOfDay, isBefore, startOfDay } from "date-fns";
import { isAfter } from "date-fns";
import { MouseEventHandler, useMemo } from "react";
import { findMostRelevantOccupancy, Occupancy } from "../../models/Occupancy";
import { OccupancyWindowWithOccupiedDates } from "../../models/OccupancyWindow";
import { OccupancyPopover } from "./OccupancyPopover";
import { parseDate } from "../../services/date";

interface OccupiedCalendarDateProps {
  dateString: string;
  onClick?: MouseEventHandler;
  occupancyWindow?: OccupancyWindowWithOccupiedDates;
  label: string;
}

export function OccupiedCalendarDate({ dateString, occupancyWindow, label }: OccupiedCalendarDateProps) {
  const date = startOfDay(parseDate(dateString));
  const occupancies = occupancyWindow?.occupiedDates?.get(dateString) || new Set<Occupancy>();
  const slots = useMemo(() => splitSlots(date, occupancies), [date, occupancies]);
  const classNames = ["occupancy-calendar-date", occupancies.size > 0 && "has-occupancies"];
  return useMemo(
    () => (
      <div className={classNames.filter((className) => className).join(" ")} aria-haspopup="true">
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
        <div className="label">{label}</div>
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
    const { beginsAt, endsAt } = occupancy;

    // begins before and ends after that day => allDay
    if (isBefore(beginsAt, dayStart) && isAfter(endsAt, dayEnd)) return slots.allday.add(occupancy);

    // ends in the afternoon or begins in the forenoon, there are no others => allDay
    if (
      occupancies.size == 1 &&
      (isWithinInterval(endsAt, afternoonInterval) || isWithinInterval(beginsAt, forenoonInterval))
    )
      return slots.allday.add(occupancy);

    // ends that day => foreNoon
    if (isWithinInterval(endsAt, allDayInterval)) return slots.forenoon.add(occupancy);

    // begins that day => afternoon
    if (isWithinInterval(beginsAt, allDayInterval)) return slots.afternoon.add(occupancy);
  });

  return slots;
}
