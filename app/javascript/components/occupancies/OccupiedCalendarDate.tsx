import { addHours, isAfter, isBefore, startOfDay } from "date-fns";
import { type MouseEventHandler, useMemo } from "react";
import { findMostRelevantOccupancy, type Occupancy } from "../../models/Occupancy";
import type { OccupancyWindowWithOccupiedDates } from "../../models/OccupancyWindow";
import { parseDate } from "../../services/date";
import { OccupancyPopover } from "./OccupancyPopover";

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
  const classNames = ["occupancy-calendar-date", occupancies.size > 0 && "has-occupancies"]
    .filter((className) => className)
    .join(" ");
  return useMemo(
    () => (
      <div className={classNames} aria-haspopup="true">
        <OccupancyPopover dateString={dateString} occupancyWindow={occupancyWindow} />
        <svg viewBox="0 0 48 48" preserveAspectRatio="xMidYMid meet">
          {Array.from(slots.allday).some(Boolean) && (
            <rect
              className="occupancy-slot"
              y="0"
              x="0"
              width="48"
              height="48"
              fill={findMostRelevantOccupancy(slots.allday)?.color}
            />
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
    [slots, label, occupancyWindow, dateString, classNames],
  );
}

function splitSlots(date: Date, occupancies: Set<Occupancy>) {
  const dayStart = startOfDay(date);
  const dayMid = addHours(dayStart, 12);
  // const dayEnd = endOfDay(date);
  const slots = { allday: new Set<Occupancy>(), forenoon: new Set<Occupancy>(), afternoon: new Set<Occupancy>() };

  for (const occupancy of Array.from(occupancies)) {
    const { beginsAt, endsAt } = occupancy;

    // const beginsBeforeDayStart = isBefore(beginsAt, dayStart);
    const beginsBeforeDayMid = isBefore(beginsAt, dayMid);
    // const beginsAfterDayStart = isAfter(beginsAt, dayStart);
    // const beginsAfterDayMid = isAfter(beginsAt, dayMid);

    const endsAfterDayStart = isAfter(endsAt, dayStart);
    const endsAfterDayMid = isAfter(endsAt, dayMid);
    // const endsAfterDayEnd = isAfter(endsAt, dayEnd);
    // const endsBeforeDayEnd = isBefore(endsAt, dayEnd);

    // Single day booking
    // if (beginsAfterDayStart && beginsBeforeDayMid && endsAfterDayMid && endsBeforeDayEnd)
    //   slots.allday.add(occupancy); break;

    // Indicate change of tenant
    // if (beginsBeforeDayStart && endsAfterDayMid && endsBeforeDayEnd) break slots.forenoon.add(occupancy);
    // if (beginsAfterDayStart && beginsBeforeDayMid && endsAfterDayEnd) { slots.afternoon.add(occupancy); break; }

    if (beginsBeforeDayMid && endsAfterDayMid) {
      slots.allday.add(occupancy);
      continue;
    }
    if (beginsBeforeDayMid && endsAfterDayStart) {
      slots.forenoon.add(occupancy);
      continue;
    }
    if (!beginsBeforeDayMid && endsAfterDayMid) {
      slots.afternoon.add(occupancy);
      continue;
    }

    console.error("Occupancy has no slot", occupancy);
  }

  return slots;
}
