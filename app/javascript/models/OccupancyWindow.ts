import { Occupancy, OccupancyJsonData, fromJson as occupancyFromJson } from "./Occupancy";
import { parseISO, eachDayOfInterval, formatISO, isDate } from "date-fns";

export type OccupiedDates = {
  [key: string]: Set<Occupancy>;
};

export type OccupancyWindow = {
  start: Date;
  end: Date;
  occupancies: Occupancy[];
  occupiedDates: OccupiedDates;
};

export type OccupancyWindowJsonData = {
  window_from: string;
  window_to: string;
  occupancies: OccupancyJsonData[];
};

export function fromJson(json: OccupancyWindowJsonData): OccupancyWindow {
  const occupancies = Array.from(json.occupancies).map(occupancyFromJson);

  return {
    start: parseISO(json.window_from),
    end: parseISO(json.window_to),
    occupiedDates: getOccupiedDates(occupancies),
    occupancies,
  };
}

const dateFormat = (date: Date) => formatISO(date, { representation: "date" });

function getOccupiedDates(occupancies: Occupancy[]) {
  const occupiedDates: OccupiedDates = {};

  for (const occupancy of occupancies) {
    eachDayOfInterval({
      start: occupancy.begins_at,
      end: occupancy.ends_at,
    }).forEach((occupiedDate) => {
      const occupiedDateString = dateFormat(occupiedDate);
      occupiedDates[occupiedDateString] = occupiedDates[occupiedDateString]?.add(occupancy) || new Set([occupancy]);
    });
  }

  return occupiedDates;
}

export function occupanciesAt(date: Date | string, occupancyWindow?: OccupancyWindow): Set<Occupancy> {
  const dateString = isDate(date) ? dateFormat(date as Date) : (date as string);
  return occupancyWindow?.occupiedDates[dateString] || new Set<Occupancy>();
}
