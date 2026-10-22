import { use } from "react";
import { useTranslation } from "react-i18next";
import { translatedString } from "../../services/i18n";
import type { Organisation } from "../../types";
import { OrganisationContext } from "../rails/OrganisationProvider";

export function CalendarLegend() {
  const organisation = use(OrganisationContext) as Organisation;
  const { i18n } = useTranslation();

  return (
    <div>
      <ul className="calendar-legend">
        {organisation.calendar_labels?.map((label) => (
          <li key={label.id} title={translatedString(label.description_i18n, i18n)}>
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48" fill={label.color}>
              <rect width="48" height="48" />
            </svg>
            {translatedString(label.title_i18n, i18n)}
          </li>
        ))}
      </ul>
      {/*  */}
    </div>
  );
}
