import { useContext, useEffect, useState } from "react";
import { Form } from "react-bootstrap";
import { OrganisationContext } from "../organisation/OrganisationProvider";
import { Organisation } from "../../types";
import { useTranslation } from "react-i18next";
import OccupiableSelect, { OccupiableSelectState } from "../occupiables/OccupiableSelect";
import { OccupancyWindowProvider } from "./OccupancyWindowContext";
import { OccupancyIntervalFormControl } from "./OccupancyIntervalFormControl";
import { ViewType } from "../calendar/Calendar";
import { cx } from "@emotion/css";

export type OccupancySelectProps = {
  initial: Partial<{ beginsAt: Date; endsAt: Date; occupiableIds: number[]; homeId: number }>;
  namePrefix?: string;
  required?: boolean;
  disabled?: boolean;
  defaultView?: ViewType;
  defaultBeginsAtTime?: string;
  defaultEndsAtTime?: string;
  occupiableInvalidFeedback?: string;
  occupancyInvalidFeedback?: string;
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

export default function OccupancySelect({
  initial,
  defaultView,
  namePrefix,
  required,
  disabled,
  occupancyInvalidFeedback,
  occupiableInvalidFeedback,
}: OccupancySelectProps) {
  const organisation = useContext(OrganisationContext);
  if (!organisation) return <></>;

  const [occupiableState, setOccupiableState] = useState<OccupiableSelectState>({
    homeId: initial.homeId,
    occupiableIds: initial.occupiableIds || [],
  });
  const { t } = useTranslation();

  useEffect(() => {
    setOccupiableState((prev) => ({
      homeId: prev.homeId || inferHomeId(organisation, prev.occupiableIds),
      occupiableIds: prev.occupiableIds?.length == 0 ? inferOccupiableIds(organisation) : prev.occupiableIds,
    }));
  }, [organisation]);

  return (
    <Form.Group>
      <Form.Label className={cx({ required })}>{t("activerecord.attributes.booking.occupiable_ids")}</Form.Label>
      <OccupiableSelect
        homeId={occupiableState.homeId}
        occupiableIds={occupiableState.occupiableIds}
        onChange={setOccupiableState}
        namePrefix={namePrefix}
        invalidFeedback={occupiableInvalidFeedback}
        required={required}
        disabled={disabled}
      ></OccupiableSelect>
      <OccupancyWindowProvider occupiableIds={occupiableState.occupiableIds}>
        <OccupancyIntervalFormControl
          defaultView={defaultView}
          namePrefix={namePrefix}
          invalidFeedback={occupancyInvalidFeedback}
          initialBeginsAt={initial.beginsAt}
          initialEndsAt={initial.endsAt}
          required={required}
          disabled={disabled}
        ></OccupancyIntervalFormControl>
      </OccupancyWindowProvider>
    </Form.Group>
  );
}
