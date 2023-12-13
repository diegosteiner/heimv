import { OccupancyJson, parse } from "../../models/Occupancy";
import { ViewType } from "../calendar/Calendar";
import { OccupancyIntervalFormControl } from "../occupancies/OccupancyIntervalFormControl";
import { OccupancyWindowProvider } from "../occupancies/OccupancyWindowContext";
import OrganisationProvider from "../organisation/OrganisationProvider";
import * as React from "react";

type OccupancyFormProps = {
  org: string;
  occupiableId: number;
  occupancy: OccupancyJson;
  defaultView?: ViewType;
  namePrefix?: string;
  required?: boolean;
  disabled?: boolean;
  defaultBeginsAtTime?: string;
  defaultEndsAtTime?: string;
  occupiableInvalidFeedback?: string;
  occupancyInvalidFeedback?: string;
};

export default function BookingOccupancyForm(props: OccupancyFormProps) {
  const occupancy = parse(props.occupancy);

  return (
    <React.StrictMode>
      <OrganisationProvider org={props.org}>
        <OccupancyWindowProvider occupiableIds={[props.occupiableId]}>
          <OccupancyIntervalFormControl
            defaultView={props.defaultView}
            namePrefix={props.namePrefix}
            invalidFeedback={props.occupancyInvalidFeedback}
            initialBeginsAt={occupancy.beginsAt}
            initialEndsAt={occupancy.endsAt}
            required={props.required}
            disabled={props.disabled}
          ></OccupancyIntervalFormControl>
        </OccupancyWindowProvider>
      </OrganisationProvider>
    </React.StrictMode>
  );
}
