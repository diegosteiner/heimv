import { BookingJson, parse } from "../../models/Booking";
import { ViewType } from "../calendar/Calendar";
import OccupancySelect from "../occupancies/OccupancySelect";
import OrganisationProvider from "../organisation/OrganisationProvider";
import * as React from "react";

type BookingOccupancyFormProps = {
  org: string;
  booking: BookingJson;
  defaultView?: ViewType;
  namePrefix?: string;
  required?: boolean;
  disabled?: boolean;
  defaultBeginsAtTime?: string;
  defaultEndsAtTime?: string;
  occupiableInvalidFeedback?: string;
  occupancyInvalidFeedback?: string;
};

export default function BookingOccupancyForm(props: BookingOccupancyFormProps) {
  const booking = parse(props.booking);

  return (
    <React.StrictMode>
      <OrganisationProvider org={props.org}>
        <OccupancySelect
          initial={{ ...booking }}
          defaultView={props.defaultView}
          namePrefix={props.namePrefix}
          disabled={props.disabled}
          required={props.required}
          defaultBeginsAtTime={props.defaultBeginsAtTime}
          defaultEndsAtTime={props.defaultEndsAtTime}
          occupiableInvalidFeedback={props.occupiableInvalidFeedback}
          occupancyInvalidFeedback={props.occupancyInvalidFeedback}
        ></OccupancySelect>
      </OrganisationProvider>
    </React.StrictMode>
  );
}
