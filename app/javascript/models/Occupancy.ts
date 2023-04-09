import parseISO from "date-fns/parseISO";

export type Occupancy = {
  id: string;
  begins_at: Date;
  ends_at: Date;
  occupancy_type: "free" | "tentative" | "occupied" | "closed";
  ref: string | null;
  deadline: Date | null;
  remarks: string | null;
  color?: string;
  occupiable: Occupiable;
};

export type OccupancyJsonType = Occupancy & {
  begins_at: string;
  ends_at: string;
  deadline: string | null;
};

export type Occupiable = {
  id: string;
  name: string;
};

export function fromJson(json: OccupancyJsonType): Occupancy {
  const { begins_at, ends_at, deadline, ...rest } = json;

  return {
    ...rest,
    begins_at: parseISO(begins_at),
    ends_at: parseISO(ends_at),
    deadline: deadline ? parseISO(deadline) : null,
  };
}

const occupancyTypeMapping = ["free", "tentative", "occupied", "closed"];

export function findMostRelevantOccupancy(occupancies: Set<Occupancy>): Occupancy | undefined {
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
