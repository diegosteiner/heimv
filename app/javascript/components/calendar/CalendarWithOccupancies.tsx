import * as React from "react";
import {
  formatISO,
  isBefore,
  isAfter,
  setHours,
  startOfDay,
  endOfDay,
  isWithinInterval,
  isDate,
} from "date-fns/esm";
import Calendar from "./Calendar";
import { Popover, OverlayTrigger } from "react-bootstrap";
import { css } from "@emotion/react";
import { useTranslation } from "react-i18next";
import { Occupancy } from "../../models/Occupancy";
import { OccupancyWindow } from "../../models/OccupancyWindow";

const CalendarWithOccupanciesStyles = css`
  .calendarDay * {
    background-color: white;
    border: 1px solid white;
    cursor: pointer;
    text-align: center;
    display: block;
    font-size: 0.9rem;
    transition: opacity 0.1s ease-in-out;
    opacity: 1;

    &:hover {
      opacity: 0.8;
    }

    &.disabled,
    &[disabled] {
      cursor: default;
      opacity: 0.2;
    }
  }
`;

function occupanciesAt(
  date: Date | string,
  occupancyWindow?: OccupancyWindow
): Set<Occupancy> {
  const dateString = isDate(date)
    ? formatISO(date as Date, { representation: "date" })
    : (date as string);
  return occupancyWindow?.occupiedDates[dateString] || new Set<Occupancy>();
}

export function defaultClassNamesCallback(
  date: Date,
  occupancyWindow?: OccupancyWindow
): string {
  const midDay = setHours(startOfDay(date), 12);

  return Array.from(occupanciesAt(date, occupancyWindow))
    .map(({ begins_at, ends_at, occupancy_type }) => {
      if (isWithinInterval(ends_at, { start: startOfDay(date), end: midDay })) {
        return `${occupancy_type}-forenoon`;
      }
      if (isWithinInterval(begins_at, { start: midDay, end: endOfDay(date) })) {
        return `${occupancy_type}-afternoon`;
      }
      return `${occupancy_type}-fullday`;
    })
    .join(" ");
}

export function defaultDisabledCallback(
  date: Date,
  occupancyWindow?: OccupancyWindow
): boolean {
  return (
    !occupancyWindow ||
    isBefore(date, occupancyWindow.start) ||
    isAfter(date, occupancyWindow.end)
  );
}

const formatDate = new Intl.DateTimeFormat("de-CH", {
  year: "numeric",
  month: "2-digit",
  day: "2-digit",
  hour: "numeric",
  minute: "numeric",
  hour12: false,
}).format;

interface CalendarDayProps {
  date: Date;
  occupancyWindow?: OccupancyWindow;
  onClick?(e: React.MouseEvent): void;
  classNames?: string | ((date: Date) => string);
  disabled?: boolean | ((date: Date) => boolean);
}

export function CalendarDay({
  date,
  occupancyWindow,
  classNames,
  disabled,
  onClick,
}: CalendarDayProps) {
  const occupancies = occupanciesAt(date, occupancyWindow);

  if (typeof disabled === "function") disabled = disabled(date);
  if (typeof classNames === "function") classNames = classNames(date);

  const button = (
    <button
      type="button"
      disabled={disabled}
      onClick={onClick}
      value={formatISO(date, { representation: "date" })}
      className={classNames}
    >
      {date.getDate()}
    </button>
  );

  if (occupancies.size <= 0) return button;

  const { t } = useTranslation();
  const popover = (
    <Popover id="popover-basic">
      <Popover.Body>
        {Array.from(occupancies).map((occupancy) => {
          const deadline = occupancy.deadline;

          return (
            <dl
              className="my-2"
              key={`${formatISO(date, { representation: "date" })}-${
                occupancy.id
              }`}
            >
              <dt>
                {formatDate(occupancy.begins_at)} -{" "}
                {formatDate(occupancy.ends_at)}
              </dt>
              <dd>
                <span>
                  <>
                    {t(
                      `activerecord.enums.occupancy.occupancy_type.${occupancy.occupancy_type}`
                    )}
                    <br />
                    {occupancy.ref || occupancy.remarks}
                  </>
                </span>
                {deadline && (
                  <span>
                    <>
                      {" "}
                      ({t("until")} {formatDate(deadline)})
                    </>
                  </span>
                )}
              </dd>
            </dl>
          );
        })}
      </Popover.Body>
    </Popover>
  );

  return (
    <OverlayTrigger trigger={["focus", "hover"]} overlay={popover}>
      {button}
    </OverlayTrigger>
  );
}
export const CalendarDayMemo = React.memo(CalendarDay);

interface CalendarWithOccupanciesProps {
  start?: Date | string;
  monthsCount?: number;
  occupancyWindow?: OccupancyWindow;
  onClickCallback?: (e: React.MouseEvent) => void;
  classNamesCallback?: (date: Date) => string;
  disabledCallback?: (date: Date) => boolean;
}

function CalendarWithOccupancies({
  start,
  occupancyWindow,
  monthsCount,
  onClickCallback,
  classNamesCallback,
  disabledCallback,
}: CalendarWithOccupanciesProps) {
  const dayElement = (date: Date) => (
    <CalendarDayMemo
      occupancyWindow={occupancyWindow}
      date={date}
      onClick={onClickCallback}
      classNames={
        classNamesCallback ||
        ((date: Date) => defaultClassNamesCallback(date, occupancyWindow))
      }
      disabled={
        disabledCallback ||
        ((date: Date) => defaultDisabledCallback(date, occupancyWindow))
      }
    ></CalendarDayMemo>
  );

  return (
    <div css={CalendarWithOccupanciesStyles} className="occupancyCalendar">
      <Calendar
        start={start}
        monthsCount={monthsCount}
        dayElement={dayElement}
      ></Calendar>
    </div>
  );
}

export default CalendarWithOccupancies;
