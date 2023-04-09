import parseISO from "date-fns/parseISO";

export type Booking = {
  home_ids: number | number[];
  begins_at: Date;
  ends_at: Date;
  email: string;
  tenant_organisation: string;
  accept_conditions: boolean;
};

export type BookingJsonData = Booking & {
  begins_at: string;
  ends_at: string;
};

export function fromJson(json: BookingJsonData): Booking {
  const { begins_at, ends_at } = json;

  return {
    ...json,
    begins_at: parseISO(begins_at),
    ends_at: parseISO(ends_at),
  };
}

// export function toJson(json: Booking): BookingJsonData {
//   const { occupancy, ...rest } = json;

//   return {
//     occupancy: occupancyFromJson(occupancy),
//     ...rest
//   };
// }
