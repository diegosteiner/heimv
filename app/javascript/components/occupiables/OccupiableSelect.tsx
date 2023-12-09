import { useContext, useEffect, useState } from "react";
import { Form } from "react-bootstrap";
import { OrganisationContext } from "../organisation/OrganisationProvider";
import { Organisation, TranslatedString } from "../../types";
import { useTranslation } from "react-i18next";

type Props = {
  initialHomeId?: number;
  initialOccupiableIds?: number[];
};

function inferOccupiableIds(organisation?: Organisation): number[] {
  if (!organisation) return [];

  const occupiables = organisation.homes.flatMap((home) => home.occupiables.length);
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

export default function OccupiableSelect({ initialHomeId, initialOccupiableIds }: Props) {
  const organisation = useContext(OrganisationContext);
  initialOccupiableIds ||= inferOccupiableIds(organisation);
  initialHomeId ||= inferHomeId(organisation, initialOccupiableIds);
  const [selectedHomeId, setSelectedHomeId] = useState(initialHomeId);
  const occupiables = organisation?.homes?.find((home) => home.id === selectedHomeId)?.occupiables;
  const { t, i18n } = useTranslation();

  useEffect(() => {
    setSelectedHomeId(initialHomeId);
  }, [organisation, initialHomeId]);

  return (
    <>
      <Form.Label>{t("activerecord.attributes.booking.occupiable_ids")}</Form.Label>
      <Form.Group className="mb-3">
        <Form.Select
          name="home_id"
          value={selectedHomeId}
          onChange={(event) => setSelectedHomeId(parseInt(event.currentTarget.value))}
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
          <Form.Check
            type="checkbox"
            value={occupiable.id}
            key={occupiable.id}
            id={`occupiable-${occupiable.id}`}
            label={occupiable.name_i18n[i18n.language as keyof TranslatedString]}
          />
        ))}
      </Form.Group>
    </>
  );
}
