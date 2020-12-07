export type OccupancyJsonData = {
  begins_at: string;
  ends_at: string;
  occupancy_type: string;
  id: string;
  ref: string;
  deadline: string | null;
};

export interface Occupancy {
  begins_at: Date;
  ends_at: Date;
  occupancy_type: string;
  id: string;
  ref: string;
  deadline: string | null;
}
