import { eachDayOfInterval, formatISO, parseISO } from "date-fns";
import { type Occupancy, type OccupancyJson, parse as parseOccupancy } from "./Occupancy";

export type OccupancyWindow = {
  start: Date;
  end: Date;
  occupancies: Occupancy[];
};

export type OccupancyWindowWithOccupiedDates = OccupancyWindow & {
  occupiedDates: Map<string, Set<Occupancy>>;
};

export type OccupancyWindowJson = {
  window_from: string;
  window_to: string;
  occupancies: OccupancyJson[];
};

export function parse(json: OccupancyWindowJson): OccupancyWindow {
  const occupancies = Array.from(json.occupancies).map(parseOccupancy) as Occupancy[];

  return {
    start: parseISO(json.window_from),
    end: parseISO(json.window_to),
    occupancies,
  };
}

const dateFormat = (date: Date) => formatISO(date, { representation: "date" });

export function calculateOccupiedDates(occupancyWindow: OccupancyWindow): OccupancyWindowWithOccupiedDates {
  return {
    ...occupancyWindow,
    occupiedDates: getOccupiedDates(occupancyWindow.occupancies),
  };
}

export function getOccupiedDates(occupancies: Occupancy[]) {
  const occupiedDates = new Map<string, Set<Occupancy>>();

  for (const occupancy of occupancies) {
    for (const occupiedDate of eachDayOfInterval({
      start: occupancy.beginsAt,
      end: occupancy.endsAt,
    })) {
      const key = dateFormat(occupiedDate);
      occupiedDates.set(key, occupiedDates.get(key)?.add(occupancy) || new Set([occupancy]));
    }
  }

  return occupiedDates;
}
