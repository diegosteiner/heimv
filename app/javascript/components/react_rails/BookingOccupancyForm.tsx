import * as React from "react";
import { BookingJson, parse } from "../../models/Booking";
import OccupancySelect from "../occupancies/OccupancySelect";
import OrganisationProvider from "../organisation/OrganisationProvider";

type BookingOccupancyFormProps = {
  org: string;
  booking: BookingJson;
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
