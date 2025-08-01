import { cx } from "@emotion/css";
import { type ComponentProps, use, useEffect, useState } from "react";
import { Form } from "react-bootstrap";
import { useTranslation } from "react-i18next";
import type { Organisation } from "../../types";
import OccupiableSelect, { type OccupiableSelectState } from "../occupiables/OccupiableSelect";
import { OrganisationContext } from "../rails/OrganisationProvider";
import { OccupancyIntervalFormControl } from "./OccupancyIntervalFormControl";
import { OccupancyWindowProvider } from "./OccupancyWindowContext";

export type OccupancySelectProps = {
  initial: Partial<{ beginsAt: Date; endsAt: Date; occupiableIds: number[]; homeId: number }>;
  occupiableInvalidFeedback?: string;
  occupancyInvalidFeedback?: string;
} & Pick<
  ComponentProps<typeof OccupancyIntervalFormControl>,
  "namePrefix" | "required" | "disabled" | "defaultBeginsAtTime" | "defaultEndsAtTime" | "beginsAtTimes" | "endsAtTimes"
>;

function inferOccupiableIds(organisation: Organisation): number[] {
  const occupiables = organisation.homes.flatMap((home) => home.occupiables.map((occupiable) => occupiable.id));
  if (occupiables.length === 1) return occupiables;
  return [];
}

function inferHomeId(organisation: Organisation, occupiableIds?: number[]): number | undefined {
  if (!organisation) return undefined;
  if (organisation.homes.length === 1) return organisation.homes[0].id;

  return (
    occupiableIds?.find(
      (occupiableId) =>
        organisation.homes.find((home) => home.occupiables.find((occupiable) => occupiable.id === occupiableId))?.id,
    ) || undefined
  );
}

export default function OccupancySelect({
  initial,
  namePrefix,
  required,
  disabled,
  occupancyInvalidFeedback,
  occupiableInvalidFeedback,
  defaultBeginsAtTime,
  defaultEndsAtTime,
  beginsAtTimes,
  endsAtTimes,
}: OccupancySelectProps) {
  const organisation = use(OrganisationContext) as Organisation;
  const { t } = useTranslation();
  const [occupiableState, setOccupiableState] = useState<OccupiableSelectState>(() => ({
    homeId: initial.homeId,
    occupiableIds: initial.occupiableIds || [],
  }));

  useEffect(() => {
    setOccupiableState((prev) => ({
      homeId: prev.homeId || inferHomeId(organisation, prev.occupiableIds),
      occupiableIds: prev.occupiableIds?.length === 0 ? inferOccupiableIds(organisation) : prev.occupiableIds,
    }));
  }, [organisation]);

  if (!organisation) return "...";
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
      />
      <OccupancyWindowProvider occupiableIds={occupiableState.occupiableIds}>
        <OccupancyIntervalFormControl
          months={9}
          namePrefix={namePrefix}
          invalidFeedback={occupancyInvalidFeedback}
          initialBeginsAt={initial.beginsAt}
          initialEndsAt={initial.endsAt}
          defaultBeginsAtTime={defaultBeginsAtTime}
          defaultEndsAtTime={defaultEndsAtTime}
          beginsAtTimes={beginsAtTimes}
          endsAtTimes={endsAtTimes}
          required={required}
          disabled={disabled}
        />
      </OccupancyWindowProvider>
    </Form.Group>
  );
}
