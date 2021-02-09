export type OccupancyJsonData = {
  begins_at: string;
  ends_at: string;
  occupancy_type: string;
  id: string;
  ref: string | null;
  deadline: string | null;
  remarks: string | null;
};

export interface Occupancy {
  begins_at: Date;
  ends_at: Date;
  occupancy_type: string;
  id: string;
  ref: string | null;
  deadline: string | null;
  remarks: string | null;
}
