import { addHours, endOfDay, isBefore, startOfDay } from "date-fns/esm";
import { isAfter } from "date-fns/esm";
import { forwardRef, MouseEventHandler, Ref, useMemo } from "react";
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

export const OccupancyCalendarDate = forwardRef(function OccupancyCalendarDate(
  {
    dateString,
    labelCallback,
    occupancyWindow,
    classNameCallback,
    disabledCallback,
    onClick,
    ...props
  }: OccupancyCalendarDateProps,
  ref: Ref<HTMLButtonElement>
) {
  const date = startOfDay(parseDate(dateString));
  const occupancies = occupancyWindow?.occupiedDates?.get(dateString) || new Set<Occupancy>();
  const slots = useMemo(() => splitSlots(date, occupancies), [date, occupancies]);

  return (
    <button
      type="submit"
      name="date"
      disabled={disabledCallback && disabledCallback(date)}
      className={classNameCallback && classNameCallback(date)}
      onClick={onClick}
      value={dateString}
      ref={ref}
      {...props}
    >
      <label style={{ fontWeight: occupancies.size > 0 ? "bold" : "normal" }}>{labelCallback(date)}</label>
      <div className="slots" style={{ backgroundColor: findMostRelevantOccupancy(slots.allday)?.color }}>
        <div className="forenoon" style={{ backgroundColor: findMostRelevantOccupancy(slots.forenoon)?.color }}></div>
        <div className="afternoon" style={{ backgroundColor: findMostRelevantOccupancy(slots.afternoon)?.color }}></div>
      </div>
    </button>
  );
});

function splitSlots(date: Date, occupancies: Set<Occupancy>) {
  const dayStart = startOfDay(date);
  const dayMid = addHours(dayStart, 12);
  const dayEnd = endOfDay(date);
  const slots = { allday: new Set<Occupancy>(), forenoon: new Set<Occupancy>(), afternoon: new Set<Occupancy>() };

  occupancies.forEach((occupancy) => {
    const { begins_at, ends_at } = occupancy;

    if (
      (isBefore(begins_at, dayStart) && isAfter(ends_at, dayMid)) ||
      (isBefore(begins_at, dayMid) && isAfter(ends_at, dayEnd))
    )
      return slots.allday.add(occupancy);

    if (
      (isAfter(ends_at, dayMid) && isBefore(ends_at, dayEnd)) ||
      (isAfter(begins_at, dayMid) && isBefore(begins_at, dayEnd))
    )
      slots.afternoon.add(occupancy);

    if (
      (isAfter(ends_at, dayStart) && isBefore(ends_at, dayEnd)) ||
      (isAfter(begins_at, dayStart) && isBefore(begins_at, dayMid))
    )
      slots.forenoon.add(occupancy);
  });

  return slots;
}
