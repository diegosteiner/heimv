import parseISO from "date-fns/parseISO";

export type OccupancyJsonData = {
  begins_at: string;
  ends_at: string;
  occupancy_type: string;
  id: string;
  ref: string | null;
  deadline: string | null;
  remarks: string | null;
  color?: string;
};

export type Occupancy = {
  id: string;
  begins_at: Date;
  ends_at: Date;
  occupancy_type: string;
  ref: string | null;
  deadline: Date | null;
  remarks: string | null;
  color?: string;
};

export function fromJson(json: OccupancyJsonData): Occupancy {
  const { begins_at, ends_at, deadline, ...rest } = json;

  return {
    ...rest,
    begins_at: parseISO(begins_at),
    ends_at: parseISO(ends_at),
    deadline: deadline ? parseISO(deadline) : null,
  };
}
