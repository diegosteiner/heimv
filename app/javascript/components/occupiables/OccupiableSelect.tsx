import { useContext } from "react";
import { Form } from "react-bootstrap";
import { OrganisationContext } from "../organisation/OrganisationProvider";
import { useTranslation } from "react-i18next";
import { cx } from "@emotion/css";
import { translatedString } from "../../services/i18n";

type OccupiableSelectProps = OccupiableSelectState & {
  onChange: (set: (prev: OccupiableSelectState) => OccupiableSelectState) => void;
  namePrefix?: string;
  required?: boolean;
  disabled?: boolean;
  invalidFeedback?: string;
};

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
  const organisation = useContext(OrganisationContext);
  const occupiables = organisation?.homes?.find((home) => home.id === homeId)?.occupiables;
  const hideHomeSelect = organisation?.homes?.length === 1;
  const { i18n } = useTranslation();
  const setHomeId = (homeId: number) => onChange((prev) => ({ ...prev, homeId }));
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
          value={homeId}
          onChange={(event) => setHomeId(parseInt(event.target.value))}
        >
          <option></option>
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
