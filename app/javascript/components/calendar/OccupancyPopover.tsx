import { ReactElement } from "react";
import { OverlayTrigger, Popover } from "react-bootstrap";
import { useTranslation } from "react-i18next";
import { Occupancy } from "../../models/Occupancy";
import { OccupancyWindow } from "../../models/OccupancyWindow";
import { formatDate } from "./calendar_functions";

interface OccupancyPopoverProps {
  dateString: string;
  occupancyWindow?: OccupancyWindow;
  children: ReactElement;
}

export function OccupancyPopover({ dateString, occupancyWindow, children }: OccupancyPopoverProps) {
  const occupancies = occupancyWindow?.occupiedDates?.get(dateString) || new Set<Occupancy>();
  if (!occupancies || occupancies.size <= 0) return children;

  const popover = (
    <Popover id="popover-basic">
      <Popover.Body>
        <ul className="list-unstyled">
          {Array.from(occupancies).map((occupancy) => (
            <OccupancyLi key={occupancy.id} occupancy={occupancy}></OccupancyLi>
          ))}
        </ul>
      </Popover.Body>
    </Popover>
  );

  return (
    <OverlayTrigger trigger={["focus", "hover"]} overlay={popover}>
      {children}
    </OverlayTrigger>
  );
}

function OccupancyLi({ occupancy }: { occupancy: Occupancy }) {
  const deadline = occupancy.deadline;
  const { t } = useTranslation();

  return (
    <li className="my-3">
      <div>{occupancy.occupiable.name}</div>
      <strong className="d-block">
        {formatDate(occupancy.begins_at)} - {formatDate(occupancy.ends_at)}
      </strong>
      <div>
        <span style={{ color: occupancy.color }}>⬤</span>&nbsp;
        <span>
          {t(`activerecord.enums.occupancy.occupancy_type.${occupancy.occupancy_type}`)}
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
