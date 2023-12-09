import OccupiableSelect from "../../occupiables/OccupiableSelect";
import OrganisationProvider from "../../organisation/OrganisationProvider";

type Props = {
  organisationId: string;
};

export default function BookingsCalendar({ organisationId }: Props) {
  return (
    <OrganisationProvider id={organisationId}>
      <OccupiableSelect></OccupiableSelect>
    </OrganisationProvider>
  );
}
