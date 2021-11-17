import {
  Occupancy,
  OccupancyJsonData,
  fromJson as occupancyFromJson,
} from "./Occupancy";

export type Booking = {
  home_id: number;
  occupancy: Occupancy;
  email: string;
  tenant_organisation: string;
  accept_conditions: boolean;
};

export type BookingJsonData = Booking & {
  occupancy: OccupancyJsonData;
};

export function fromJson(json: BookingJsonData): Booking {
  const { occupancy, ...rest } = json;

  return {
    occupancy: occupancyFromJson(occupancy),
    ...rest,
  };
}

// export function toJson(json: Booking): BookingJsonData {
//   const { occupancy, ...rest } = json;

//   return {
//     occupancy: occupancyFromJson(occupancy),
//     ...rest
//   };
// }
