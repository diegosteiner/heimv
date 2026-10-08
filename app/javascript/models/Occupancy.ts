import { parseISOorUndefined } from "../services/date";
import type { Occupiable } from "../types";

export type Occupancy = {
  id: string;
  bookingId?: string;
  beginsAt: Date;
  endsAt: Date;
  occupancyStatus: "pending" | "tentative" | "occupied" | "closed" | "internal" | "free" | "none";
  ref?: string;
  deadline?: Date;
  remarks?: string;
  color?: string;
  occupiable?: Occupiable;
  occupiableId: number;
};

export type OccupancyJson = {
  id?: string;
  booking_id?: string;
  begins_at: string;
  ends_at: string;
  deadline?: string;
  occupiable_id: number;
  occupiable: Occupiable;
  occupancy_status: Occupancy["occupancyStatus"];
};

export function parse(json: OccupancyJson): Partial<Occupancy> {
  const { id, booking_id, begins_at, ends_at, deadline, occupiable_id, occupancy_status, ...rest } = json;

  return {
    id,
    bookingId: booking_id,
    ...rest,
    beginsAt: parseISOorUndefined(begins_at),
    endsAt: parseISOorUndefined(ends_at),
    deadline: parseISOorUndefined(deadline),
    occupiableId: occupiable_id,
    occupancyStatus: occupancy_status,
  };
}

const occupancyStatusMapping = ["none", "pending", "free", "closed", "tentative", "occupied"];

export function findMostRelevantOccupancy(occupancies: Set<Occupancy>): Occupancy | undefined {
  let topCandidate: Occupancy | undefined;
  let topScore: number | undefined;

  for (const currentCandidate of Array.from(occupancies)) {
    const currentScore = occupancyStatusMapping.indexOf(currentCandidate.occupancyStatus);
    if (topScore && topScore > currentScore) break;

    topScore = currentScore;
    topCandidate = currentCandidate;
  }

  return topCandidate;
}
