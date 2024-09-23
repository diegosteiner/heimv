import { parseISOorUndefined } from "../services/date";
import { Occupiable } from "../types";

export type Occupancy = {
  id: string;
  beginsAt: Date;
  endsAt: Date;
  occupancyType: "free" | "tentative" | "occupied" | "closed";
  ref?: string;
  deadline?: Date;
  remarks?: string;
  color?: string;
  occupiable?: Occupiable;
  occupiableId: number;
};

export type OccupancyJson = {
  begins_at: string;
  ends_at: string;
  deadline?: string;
  occupiable_id: number;
  occupiable: Occupiable;
  occupancy_type: Occupancy["occupancyType"];
};

export function parse(json: OccupancyJson): Partial<Occupancy> {
  const { begins_at, ends_at, deadline, occupiable_id, occupancy_type, ...rest } = json;

  return {
    ...rest,
    beginsAt: parseISOorUndefined(begins_at),
    endsAt: parseISOorUndefined(ends_at),
    deadline: parseISOorUndefined(deadline),
    occupiableId: occupiable_id,
    occupancyType: occupancy_type,
  };
}

const occupancyTypeMapping = ["free", "tentative", "occupied", "closed"];

export function findMostRelevantOccupancy(occupancies: Set<Occupancy>): Occupancy | undefined {
  let topCandidate: Occupancy | undefined;
  let topScore: number | undefined;

  occupancies.forEach((currentCandidate) => {
    const currentScore = occupancyTypeMapping.indexOf(currentCandidate.occupancyType);
    if (topScore && topScore > currentScore) return;

    topScore = currentScore;
    topCandidate = currentCandidate;
  });

  return topCandidate;
}
