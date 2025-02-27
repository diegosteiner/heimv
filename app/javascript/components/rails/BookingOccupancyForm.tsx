import * as React from "react";
import { type BookingJson, parse } from "../../models/Booking";
import type { Organisation } from "../../types";
import OccupancySelect from "../occupancies/OccupancySelect";
import OrganisationProvider from "./OrganisationProvider";

type BookingOccupancyFormProps = {
  organisation: Organisation;
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
      <OrganisationProvider organisation={props.organisation}>
        <OccupancySelect
          initial={{ ...booking }}
          namePrefix={props.namePrefix}
          disabled={props.disabled}
          required={props.required}
          defaultBeginsAtTime={props.defaultBeginsAtTime}
          defaultEndsAtTime={props.defaultEndsAtTime}
          occupiableInvalidFeedback={props.occupiableInvalidFeedback}
          occupancyInvalidFeedback={props.occupancyInvalidFeedback}
        />
      </OrganisationProvider>
    </React.StrictMode>
  );
}
