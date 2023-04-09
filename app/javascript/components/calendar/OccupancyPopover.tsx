import * as React from "react";
import { forwardRef, Ref } from "react";
import { Popover } from "react-bootstrap";
import { useTranslation } from "react-i18next";
import { Occupancy } from "../../models/Occupancy";
import { OccupancyWindow } from "../../models/OccupancyWindow";
import { formatDate } from "./calendar_functions";

interface OccupancyPopoverProps {
  dateString: string;
  occupancyWindow?: OccupancyWindow;
}

export const OccupancyPopover = forwardRef(function OccupancyPopover(
  { dateString, occupancyWindow, ...props }: OccupancyPopoverProps,
  ref: Ref<HTMLDivElement>
) {
  const occupancies = occupancyWindow?.occupiedDates?.get(dateString) || new Set<Occupancy>();
  if (!occupancies || occupancies.size <= 0) return <></>;

  return (
    <Popover id="occupancy-popover" ref={ref} {...props}>
      <Popover.Body>
        <ul className="list-unstyled p-0 m-0 occupancies">
          {Array.from(occupancies).map((occupancy) => (
            <OccupancyLi key={occupancy.id} occupancy={occupancy}></OccupancyLi>
          ))}
        </ul>
      </Popover.Body>
    </Popover>
  );
});

function OccupancyLi({ occupancy }: { occupancy: Occupancy }) {
  const deadline = occupancy.deadline;
  const { t } = useTranslation();

  return (
    <li>
      <i>{occupancy.occupiable.name}</i>
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
