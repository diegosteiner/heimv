import {
  type OccupancyWindow,
  type OccupancyWindowJson,
  parse as parseOcupancyWindow,
} from "../models/OccupancyWindow";
import type { Occupiable, Organisation } from "../types";

export class ApiClient {
  public organisationId: Organisation["slug"];
  public basePath: string;

  constructor(organisationId: Organisation["slug"]) {
    this.organisationId = organisationId;
    this.basePath = (organisationId && `/${organisationId}`) || "";
  }

  public async getOrganisation(): Promise<Organisation> {
    const response = await fetch(`${this.basePath}/organisation.json`);
    const json = await response.json();
    if (response.status !== 200) throw new Error(json.error);

    return json as unknown as Organisation;
  }

  public async getOccupiableOccupancyWindow(occupiableId: Occupiable["id"]): Promise<OccupancyWindow> {
    const response = await fetch(`${this.basePath}/occupiables/${occupiableId}/calendar.json`);
    const json = await response.json();
    if (response.status !== 200) throw new Error(json.error);

    return parseOcupancyWindow(json as unknown as OccupancyWindowJson);
  }

  public async getManageOccupiableOccupancyWindow(occupiableId: Occupiable["id"]): Promise<OccupancyWindow> {
    const response = await fetch(`${this.basePath}/manage/occupiables/${occupiableId}/calendar.json`);
    const json = await response.json();
    if (response.status !== 200) throw new Error(json.error);

    return parseOcupancyWindow(json as unknown as OccupancyWindowJson);
  }
}
