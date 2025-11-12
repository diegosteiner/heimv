import { cx } from "@emotion/css";
import { type Dispatch, type SetStateAction, use } from "react";
import { Form } from "react-bootstrap";
import { useTranslation } from "react-i18next";
import { translatedString } from "../../services/i18n";
import { OrganisationContext } from "../rails/OrganisationProvider";

type OccupiableSelectProps = OccupiableSelectState & {
  onChange: Dispatch<SetStateAction<OccupiableSelectState>>;
  namePrefix?: string;
  required?: boolean;
  disabled?: boolean;
  invalidFeedback?: string;
};

function ordinalOrder(a: { ordinal?: number | undefined }, b: { ordinal?: number | undefined }): number {
  if (a.ordinal === undefined && b.ordinal === undefined) return 0;
  if (a.ordinal === undefined) return 1;
  if (b.ordinal === undefined) return -1;
  return a.ordinal - b.ordinal;
}

export type OccupiableSelectState = {
  homeId: number | undefined;
  occupiableIds: number[] | undefined;
};

export default function OccupiableSelect({
  homeId,
  occupiableIds,
  namePrefix,
  disabled,
  required,
  invalidFeedback,
  onChange,
}: OccupiableSelectProps) {
  const { i18n } = useTranslation();
  const organisation = use(OrganisationContext);
  const home = organisation?.homes?.find((home) => home.id === homeId);
  const occupiables = home?.occupiables
    ?.filter((occupiable) => occupiable.occupiable && !occupiable.discarded_at)
    ?.sort(ordinalOrder);
  const hideHomeSelect = organisation?.homes?.length === 1;
  const setHomeId = (homeId: number) => {
    const newHome = organisation?.homes?.find((home) => home.id === homeId);
    const newOccupiables = newHome?.occupiables;
    const x = { homeId, occupiableIds: newOccupiables?.length === 1 ? [newOccupiables[0].id] : [] };
    onChange(x);
  };
  const setOccupiableId = (occupiableId: number, value: boolean) => {
    onChange(({ occupiableIds, homeId }) => {
      occupiableIds ||= [];
      occupiableIds =
        occupiableIds.includes(occupiableId) && !value
          ? occupiableIds.filter((id) => id !== occupiableId)
          : [...occupiableIds, occupiableId];

      return { homeId, occupiableIds };
    });
  };

  return (
    <>
      <Form.Group className={cx({ "mb-3": true, "d-none": hideHomeSelect })}>
        <Form.Select
          name={`${namePrefix}[home_id]`}
          id="booking_home_id"
          disabled={disabled}
          required={required}
          value={homeId || ""}
          onChange={(event) => setHomeId(+event.target.value)}
        >
          <option />
          {organisation?.homes.map((home) => (
            <option key={home.id} value={home.id}>
              {home.name}
            </option>
          ))}
        </Form.Select>
      </Form.Group>

      <Form.Group className="mb-3">
        {occupiables?.map((occupiable) => (
          <Form.Check type="checkbox" key={occupiable.id} id={`booking_occupiable_ids_${occupiable.id}`}>
            <Form.Check.Input
              type="checkbox"
              value={occupiable.id}
              name={`${namePrefix}[occupiable_ids][]`}
              checked={occupiableIds?.includes(occupiable.id)}
              onChange={(event) => setOccupiableId(occupiable.id, event.target.checked)}
            />
            <Form.Check.Label>
              {translatedString(occupiable.name_i18n, i18n)}
              <p className="text-muted m-0">{translatedString(occupiable.description_i18n, i18n)}</p>
            </Form.Check.Label>
          </Form.Check>
        ))}
        {!!invalidFeedback && <div className="invalid-feedback d-block">{invalidFeedback}</div>}
      </Form.Group>
    </>
  );
}
