import { Occupancy, OccupancyJsonType, fromJson as occupancyFromJson } from "./Occupancy";
import { parseISO, eachDayOfInterval, formatISO } from "date-fns";

export type OccupancyWindow = {
  start: Date;
  end: Date;
  occupancies: Occupancy[];
  occupiedDates?: Map<string, Set<Occupancy>>;
};

export type OccupancyWindowJsonType = {
  window_from: string;
  window_to: string;
  occupancies: OccupancyJsonType[];
};

export function parse(json: OccupancyWindowJsonType): OccupancyWindow {
  const occupancies = Array.from(json.occupancies).map(occupancyFromJson);

  return {
    start: parseISO(json.window_from),
    end: parseISO(json.window_to),
    // occupiedDates: getOccupiedDates(occupancies),
    occupancies,
  };
}

const dateFormat = (date: Date) => formatISO(date, { representation: "date" });

export function getOccupiedDates(occupancies: Occupancy[]) {
  const occupiedDates = new Map<string, Set<Occupancy>>();

  for (const occupancy of occupancies) {
    eachDayOfInterval({
      start: occupancy.begins_at,
      end: occupancy.ends_at,
    }).forEach((occupiedDate) => {
      const key = dateFormat(occupiedDate);
      occupiedDates.set(key, occupiedDates.get(key)?.add(occupancy) || new Set([occupancy]));
    });
  }

  return occupiedDates;
}

// export function occupanciesAt(date: Date | string, occupancyWindow?: OccupancyWindow): Set<Occupancy> {
//   const dateString = isDate(date) ? dateFormat(date as Date) : (date as string);
//   return occupancyWindow?.occupiedDates[dateString] || new Set<Occupancy>();
// }
