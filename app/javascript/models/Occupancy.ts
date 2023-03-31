import parseISO from "date-fns/parseISO";

export type Occupancy = {
  id: string;
  begins_at: Date;
  ends_at: Date;
  occupancy_type: string;
  ref: string | null;
  deadline: Date | null;
  remarks: string | null;
  color?: string;
  occupiable: Occupiable;
};

export type Occupiable = {
  id: string;
  name: string;
};

export function fromJson(
  json: Occupancy & {
    begins_at: string;
    ends_at: string;
    deadline: string | null;
  }
): Occupancy {
  const { begins_at, ends_at, deadline, ...rest } = json;

  return {
    ...rest,
    begins_at: parseISO(begins_at),
    ends_at: parseISO(ends_at),
    deadline: deadline ? parseISO(deadline) : null,
  };
}
