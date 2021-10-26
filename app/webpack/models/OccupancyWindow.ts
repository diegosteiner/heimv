import {
  Occupancy,
  OccupancyJsonData,
  fromJson as occupancyFromJson,
} from "./Occupancy";
import { parseISO, eachDayOfInterval, formatISO } from "date-fns";

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

function getOccupiedDates(occupancies: Occupancy[]) {
  const occupiedDates: OccupiedDates = {};

  for (const occupancy of occupancies) {
    eachDayOfInterval({ start: occupancy.start, end: occupancy.end }).forEach(
      (occupiedDate) => {
        const occupiedDateString = formatISO(occupiedDate, {
          representation: "date",
        });
        occupiedDates[occupiedDateString] =
          occupiedDates[occupiedDateString]?.add(occupancy) ||
          new Set([occupancy]);
      }
    );
  }

  return occupiedDates;
}
