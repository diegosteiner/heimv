import { useContext, useEffect, useState } from "react";
import { Form } from "react-bootstrap";
import { OrganisationContext } from "../organisation/OrganisationProvider";
import { Organisation } from "../../types";
import { useTranslation } from "react-i18next";
import { Booking } from "../../models/Booking";
import OccupiableSelect, { OccupiableSelectState } from "../occupiables/OccupiableSelect";
import { OccupancyWindowProvider } from "./OccupancyWindowContext";
import { OccupancyIntervalFormControl } from "./OccupancyIntervalFormControl";

type BookingOccupancySelectProps = {
  booking?: Booking;
};

function inferOccupiableIds(organisation?: Organisation): number[] {
  if (!organisation) return [];

  const occupiables = organisation.homes.flatMap((home) => home.occupiables.map((occupiable) => occupiable.id));
  if (occupiables.length === 1) return occupiables;
  return [];
}

function inferHomeId(organisation?: Organisation, occupiableIds?: number[]): number | undefined {
  if (!organisation) return undefined;
  if (organisation.homes.length === 1) return organisation.homes[0].id;

  return (
    occupiableIds?.find(
      (occupiableId) =>
        organisation.homes.find((home) => home.occupiables.find((occupiable) => occupiable.id == occupiableId))?.id,
    ) || undefined
  );
}

export default function BookingOccupancySelect({ booking }: BookingOccupancySelectProps) {
  const organisation = useContext(OrganisationContext);
  const [occupiableState, setOccupiableState] = useState<OccupiableSelectState>({
    homeId: booking?.home_id,
    occupiableIds: booking?.occupiable_ids || [],
  });
  const { t } = useTranslation();

  useEffect(() => {
    setOccupiableState((prev) => ({
      homeId: prev.homeId || inferHomeId(organisation, prev.occupiableIds),
      occupiableIds: prev.occupiableIds?.length == 0 ? inferOccupiableIds(organisation) : [],
    }));
  }, [organisation]);

  return (
    <>
      <Form.Label>{t("activerecord.attributes.booking.occupiable_ids")}</Form.Label>
      <OccupiableSelect
        homeId={occupiableState.homeId}
        occupiableIds={occupiableState.occupiableIds}
        onChange={setOccupiableState}
      ></OccupiableSelect>
      <OccupancyWindowProvider occupiableIds={occupiableState.occupiableIds}>
        <OccupancyIntervalFormControl></OccupancyIntervalFormControl>
      </OccupancyWindowProvider>
    </>
  );
}
