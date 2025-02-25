import * as React from "react";
import { Card } from "react-bootstrap";
import { useTranslation } from "react-i18next";
import type { Occupancy } from "../../models/Occupancy";
import type { OccupancyWindowWithOccupiedDates } from "../../models/OccupancyWindow";
import { formatDate } from "../../services/date";
import { translatedString } from "../../services/i18n";

interface OccupancyPopoverProps {
  dateString: string;
  occupancyWindow?: OccupancyWindowWithOccupiedDates;
}

export const OccupancyPopover = React.memo(function OccupancyPopover({
  dateString,
  occupancyWindow,
}: OccupancyPopoverProps) {
  const occupancies = occupancyWindow?.occupiedDates?.get(dateString) || new Set<Occupancy>();
  if (!occupancies || occupancies.size <= 0) return <></>;

  return (
    <Card className="occupancy-popover shadow">
      <Card.Body>
        <ul className="list-unstyled p-0 m-0 occupancies">
          {Array.from(occupancies).map((occupancy) => (
            <OccupancyLi key={occupancy.id} occupancy={occupancy} />
          ))}
        </ul>
      </Card.Body>
    </Card>
  );
});

function OccupancyLi({ occupancy }: { occupancy: Occupancy }) {
  const deadline = occupancy.deadline;
  const { t, i18n } = useTranslation();

  return (
    <li>
      <i>{occupancy.occupiable?.name_i18n && translatedString(occupancy.occupiable.name_i18n, i18n)}</i>
      <strong className="d-block">
        {formatDate(occupancy.beginsAt)} - {formatDate(occupancy.endsAt)}
      </strong>
      <div>
        <span style={{ color: occupancy.color }}>⬤</span>&nbsp;
        <span>
          {t(`activerecord.enums.occupancy.occupancy_type.${occupancy.occupancyType}`)}
          <br />
          {occupancy.ref || occupancy.remarks}
        </span>
        {deadline && (
          <span>
            {" "}
            ({t("until")} {formatDate(deadline)})
          </span>
        )}
      </div>
    </li>
  );
}
