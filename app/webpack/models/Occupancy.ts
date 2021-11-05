import parseISO from "date-fns/parseISO";

export type OccupancyJsonData = {
  begins_at: string;
  ends_at: string;
  occupancy_type: string;
  id: string;
  ref: string | null;
  deadline: string | null;
  remarks: string | null;
};

export type Occupancy = {
  id: string;
  start: Date;
  end: Date;
  occupancy_type: string;
  ref: string | null;
  deadline: Date | null;
  remarks: string | null;
};

export function fromJson(json: OccupancyJsonData): Occupancy {
  const { begins_at, ends_at, deadline, ...rest } = json;

  return {
    ...rest,
    start: parseISO(begins_at),
    end: parseISO(ends_at),
    deadline: deadline ? parseISO(deadline) : null,
  };
}
