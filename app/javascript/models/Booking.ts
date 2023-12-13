import { parseISOorUndefined } from "../services/date";

export type Booking = {
  beginsAt: Date;
  endsAt: Date;
  homeId: number;
  occupiableIds: number[];
  organisationId: number;
};

export type BookingJson = {
  begins_at?: string;
  ends_at?: string;
  home_id?: number;
  occupiable_ids?: number[];
};

export function parse(json: BookingJson): Partial<Booking> {
  const { begins_at, ends_at, home_id, occupiable_ids } = json;

  return {
    beginsAt: parseISOorUndefined(begins_at),
    endsAt: parseISOorUndefined(ends_at),
    homeId: home_id,
    occupiableIds: occupiable_ids,
  };
}
