import BookingOccupancySelect from "../../occupancies/BookingOccupancySelect";
import OrganisationProvider from "../../organisation/OrganisationProvider";
import * as React from "react";

type Props = {
  organisationId: string;
};

export default function BookingsCalendar({ organisationId }: Props) {
  return (
    <React.StrictMode>
      <OrganisationProvider id={organisationId}>
        <BookingOccupancySelect></BookingOccupancySelect>
      </OrganisationProvider>
    </React.StrictMode>
  );
}
