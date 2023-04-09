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
