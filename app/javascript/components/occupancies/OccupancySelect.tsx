import { cx } from "@emotion/css";
import { type ComponentProps, use, useState } from "react";
import { Form } from "react-bootstrap";
import { useTranslation } from "react-i18next";
import type { Home, Occupiable, Organisation } from "../../types";
import OccupiableSelect, { type OccupiableSelectState } from "../occupiables/OccupiableSelect";
import { OrganisationContext } from "../rails/OrganisationProvider";
import { OccupancyIntervalFormControl } from "./OccupancyIntervalFormControl";
import { OccupancyWindowProvider } from "./OccupancyWindowContext";

export type OccupancySelectProps = {
  initial: Partial<{ id: string; beginsAt: Date; endsAt: Date; occupiableIds: number[]; homeId: number }>;
  occupiableInvalidFeedback?: string;
  occupancyInvalidFeedback?: string;
} & Pick<
  ComponentProps<typeof OccupancyIntervalFormControl>,
  | "namePrefix"
  | "required"
  | "disabled"
  | "defaultBeginsAtTime"
  | "defaultEndsAtTime"
  | "beginsAtTimes"
  | "endsAtTimes"
  | "checkOverlaps"
>;

function inferInitialHome(
  homeId: number | undefined,
  initialOccupiableIds: number[] | undefined,
  organisation: Organisation,
): Home | undefined {
  let home: Home | undefined;
  if (!home) {
    // Home from passed props, but only if it belongs to the organisation
    home = organisation.homes.find((h) => h.id === homeId);
  }
  if (!home && initialOccupiableIds && initialOccupiableIds.length > 0) {
    // Home derived from the occupiableIds from passed props
    home = organisation.homes.find((h) => h.occupiables.some((o) => initialOccupiableIds?.includes(o.id)));
  }
  if (!home && organisation.homes.length === 1) {
    // Home if there is just one
    home = organisation.homes[0];
  }
  return home;
}

export function inferInitialOccupiables(
  occupiableIds: number[] | undefined,
  home: Home | undefined,
  organisation: Organisation,
): Occupiable[] | undefined {
  let occupiables: Occupiable[] | undefined;

  if (!organisation?.homes.some((h) => h.id === home?.id)) {
    // Home is not part of this organisation
    return [];
  }
  if (!occupiables?.length) {
    // OccupiableIds from passed props, but only if they belong to the selected home
    occupiables = home?.occupiables?.filter((o) => occupiableIds?.includes(o.id));
  }
  if (!occupiables?.length && home?.occupiables?.length === 1) {
    // OccupiableIds from the home
    occupiables = [home?.occupiables[0]];
  }
  if (!occupiables?.length && home?.occupiables) {
    // OccupiableIds that are also the home
    occupiables = home.occupiables.filter((o) => o.id === home.id);
  }

  return occupiables;
}

function inferInitialOccupiableState(
  initialHomeId: number | undefined,
  initialOccupiableIds: number[] | undefined,
  organisation: Organisation,
) {
  const home = inferInitialHome(initialHomeId, initialOccupiableIds, organisation);
  const occupiables = inferInitialOccupiables(initialOccupiableIds, home, organisation);

  return { homeId: home?.id, occupiableIds: occupiables?.map((o) => o.id) };
}

export default function OccupancySelect({
  initial,
  namePrefix,
  required,
  disabled,
  checkOverlaps,
  occupancyInvalidFeedback,
  occupiableInvalidFeedback,
  defaultBeginsAtTime,
  defaultEndsAtTime,
  beginsAtTimes,
  endsAtTimes,
}: OccupancySelectProps) {
  const organisation = use(OrganisationContext) as Organisation;
  const { t } = useTranslation();
  const [occupiableState, setOccupiableState] = useState<OccupiableSelectState>(() =>
    inferInitialOccupiableState(initial.homeId, initial.occupiableIds, organisation),
  );

  if (!organisation) return;
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
          bookingId={initial.id}
          invalidFeedback={occupancyInvalidFeedback}
          initialBeginsAt={initial.beginsAt}
          initialEndsAt={initial.endsAt}
          defaultBeginsAtTime={defaultBeginsAtTime}
          defaultEndsAtTime={defaultEndsAtTime}
          beginsAtTimes={beginsAtTimes}
          endsAtTimes={endsAtTimes}
          required={required}
          disabled={disabled}
          checkOverlaps={checkOverlaps}
        />
      </OccupancyWindowProvider>
    </Form.Group>
  );
}
