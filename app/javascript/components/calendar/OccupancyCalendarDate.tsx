import { addHours, endOfDay, isBefore, startOfDay } from "date-fns/esm";
import { isAfter } from "date-fns/esm";
import { useContext } from "react";
import { Occupancy } from "../../models/Occupancy";
import { OccupancyWindow } from "../../models/OccupancyWindow";
import { parseDate } from "./calendar_functions";
import { CalendarBehaviorContext } from "./OccupancyCalendar";
import { OccupancyWindowContext } from "./OccupancyWindowContext";

interface OccupancyCalendarDateProps {
  dateString: string;
  labelCallback: (date: Date) => string;
  disabledCallback?: (date: Date) => boolean;
  occupancyWindow?: OccupancyWindow;
}

export function OccupancyCalendarDate({
  dateString,
  labelCallback,
  occupancyWindow,
  disabledCallback,
}: OccupancyCalendarDateProps) {
  const date = startOfDay(parseDate(dateString));
  const { onClick } = useContext(CalendarBehaviorContext);
  occupancyWindow ??= useContext(OccupancyWindowContext);
  const occupancies = occupancyWindow?.occupiedDates?.get(dateString) || new Set<Occupancy>();
  const times = splitByTimeOfDay(date, occupancies);
  disabledCallback ??= (date: Date) =>
    !occupancyWindow || isBefore(date, occupancyWindow.start) || isAfter(date, occupancyWindow.end);

  console.count(dateString);
  return (
    <button
      type="submit"
      name="date"
      disabled={disabledCallback(date)}
      onClick={onClick}
      value={dateString}
      className={`occupancy-calendar-date ${occupancies?.size && "occupied"}`}
    >
      <div className="label">{labelCallback(date)}</div>
      <div className="halfdays" style={{ backgroundColor: findMostRelevantOccupancy(times.allday)?.color }}>
        <div className="forenoon" style={{ backgroundColor: findMostRelevantOccupancy(times.forenoon)?.color }}></div>
        <div className="afternoon" style={{ backgroundColor: findMostRelevantOccupancy(times.afternoon)?.color }}></div>
      </div>
    </button>
  );
}

function splitByTimeOfDay(date: Date, occupancies?: Set<Occupancy>) {
  const dayStart = startOfDay(date);
  const dayMid = addHours(dayStart, 12);
  const dayEnd = endOfDay(date);
  const times = { allday: new Set<Occupancy>(), forenoon: new Set<Occupancy>(), afternoon: new Set<Occupancy>() };

  occupancies?.forEach((occupancy) => {
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

const occupancyTypeMapping = ["free", "tentative", "occupied", "closed"];

function findMostRelevantOccupancy(occupancies: Set<Occupancy>): Occupancy | undefined {
  let topCandidate: Occupancy | undefined;
  let topScore: number | undefined;

  occupancies.forEach((currentCandidate) => {
    const currentScore = occupancyTypeMapping.indexOf(currentCandidate.occupancy_type);
    if (topScore && topScore > currentScore) return;

    topScore = currentScore;
    topCandidate = currentCandidate;
  });

  return topCandidate;
}
