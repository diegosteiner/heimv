import { isFirstDayOfMonth, isWithinInterval } from "date-fns";
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
  const slots = { allday: new Set<Occupancy>(), forenoon: new Set<Occupancy>(), afternoon: new Set<Occupancy>() };

  occupancies.forEach((occupancy) => {
    const { beginsAt, endsAt } = occupancy;

    const beginsBeforeDayStart = isBefore(beginsAt, dayStart);
    const beginsBeforeDayMid = isBefore(beginsAt, dayMid);
    const beginsAfterDayStart = isAfter(beginsAt, dayStart);
    const beginsAfterDayMid = isAfter(beginsAt, dayMid);

    const endsAfterDayStart = isAfter(endsAt, dayStart);
    const endsAfterDayMid = isAfter(endsAt, dayMid);
    const endsAfterDayEnd = isAfter(endsAt, dayEnd);
    const endsBeforeDayEnd = isBefore(endsAt, dayEnd);

    // Single day booking
    // if (beginsAfterDayStart && beginsBeforeDayMid && endsAfterDayMid && endsBeforeDayEnd)
    //   return slots.allday.add(occupancy);

    // Indicate change of tenant
    // if (beginsBeforeDayStart && endsAfterDayMid && endsBeforeDayEnd) return slots.forenoon.add(occupancy);
    // if (beginsAfterDayStart && beginsBeforeDayMid && endsAfterDayEnd) return slots.afternoon.add(occupancy);

    if (beginsBeforeDayMid && endsAfterDayMid) return slots.allday.add(occupancy);
    if (beginsBeforeDayMid && endsAfterDayStart) return slots.forenoon.add(occupancy);
    if (beginsAfterDayMid && endsAfterDayMid) return slots.afternoon.add(occupancy);

    debugger;
  });

  return slots;
}
