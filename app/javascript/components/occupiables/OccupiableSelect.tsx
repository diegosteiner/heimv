import { useContext } from "react";
import { Form } from "react-bootstrap";
import { OrganisationContext } from "../organisation/OrganisationProvider";
import { TranslatedString } from "../../types";
import { useTranslation } from "react-i18next";

type Props = OccupiableSelectState & {
  onChange: (set: (prev: OccupiableSelectState) => OccupiableSelectState) => void;
};

export type OccupiableSelectState = {
  homeId: number | undefined;
  occupiableIds: number[] | undefined;
};

export default function OccupiableSelect({ homeId, occupiableIds, onChange }: Props) {
  const organisation = useContext(OrganisationContext);
  const occupiables = organisation?.homes?.find((home) => home.id === homeId)?.occupiables;
  const { i18n } = useTranslation();
  const setHomeId = (homeId: number | undefined) => {
    onChange((prev) => ({ ...prev, homeId }));
  };

  const toggleOccupiableId = (occupiableId: number, value: boolean) => {
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
      <Form.Group className="mb-3">
        <Form.Select name="home_id" value={homeId} onChange={(event) => setHomeId(parseInt(event.currentTarget.value))}>
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
          <Form.Check
            type="checkbox"
            value={occupiable.id}
            checked={occupiableIds?.includes(occupiable.id)}
            onChange={(event) => toggleOccupiableId(occupiable.id, event.currentTarget.checked)}
            key={occupiable.id}
            id={`occupiable-${occupiable.id}`}
            label={occupiable.name_i18n[i18n.language as keyof TranslatedString]}
          />
        ))}
      </Form.Group>
    </>
  );
}
