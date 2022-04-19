import * as React from "react";
import {
  parseISO,
  formatISO,
  isBefore,
  isAfter,
  setHours,
  startOfDay,
  endOfDay,
  isWithinInterval,
} from "date-fns/esm";
import Calendar from "./Calendar";
import { Popover, OverlayTrigger } from "react-bootstrap";
import { css } from "@emotion/react";
import * as chroma from "chroma.ts";
import { useTranslation } from "react-i18next";
import { OccupancyWindow, occupanciesAt } from "../../models/OccupancyWindow";
import { Occupancy } from "../../models/Occupancy";

const styles = (slotColors: (string | undefined)[]) => {
  // const backgroundize = (color: string) => chroma.css(color).brighter(0.75).saturate(-0.25).toString()
  const backgroundize = (color: string) => color;
  const foregroundize = (color: string) =>
    chroma.css(color).darker(3).toString();
  const fallbackColor = "#FFFFFF00";
  const textColor = foregroundize(slotColors[0] || slotColors[1] || "#000000");
  let fontWeight = "normal";
  let topLeftColor = fallbackColor;
  let bottomRightColor = fallbackColor;
  let background = fallbackColor;

  switch (slotColors.length) {
    case 1:
      fontWeight = "bold";
      topLeftColor = slotColors[0] || fallbackColor;
      bottomRightColor = slotColors[0] || fallbackColor;
      background = backgroundize(topLeftColor);
      break;
    case 2:
      fontWeight = "bold";
      topLeftColor = slotColors[0] || fallbackColor;
      bottomRightColor = slotColors[1] || fallbackColor;
      background = `linear-gradient(135deg, 
                        ${backgroundize(topLeftColor)} 49%, 
                        ${fallbackColor} 49%, 
                        ${fallbackColor} 51%, 
                        ${backgroundize(bottomRightColor)} 51%)`;
  }

  return css`
    margin: 0;
    padding: 0;
    width: 100%;
    height: 100%;
    font-weight: ${fontWeight};
    color: ${textColor};
    background: ${background};
    background-size: cover;
    background-repeat: no-repeat;
    border: 1px solid transparent;
    border-color: ${topLeftColor};
    border-left-color: ${topLeftColor};
    border-right-color: ${bottomRightColor};
    border-bottom-color: ${bottomRightColor};

    &[disabled] {
      opacity: 0.3;
    }
    &:hover {
      opacity: 0.7;
    }
  `;
};

type CalendarDaySlot = [Occupancy | null, Occupancy | null] | [Occupancy] | [];

function occupancySlotsInCalendarDay(
  date: Date,
  occupancies: Set<Occupancy>
): CalendarDaySlot {
  const midDay = setHours(startOfDay(date), 12);
  const slots: CalendarDaySlot = [null, null];

  for (const occupancy of Array.from(occupancies)) {
    if (
      isWithinInterval(occupancy.ends_at, {
        start: startOfDay(date),
        end: midDay,
      })
    ) {
      slots[0] = occupancy;
      continue;
    }
    if (
      isWithinInterval(occupancy.begins_at, {
        start: midDay,
        end: endOfDay(date),
      })
    ) {
      slots[1] = occupancy;
      continue;
    }
    return [occupancy];
  }

  return !slots[0] && !slots[1] ? [] : slots;
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
  dateString: string;
  occupancies?: Set<Occupancy>;
  onClick?(e: React.MouseEvent): void;
  classNames?: string | ((date: Date) => string);
  disabled?: boolean | ((date: Date) => boolean);
}

export function CalendarDay({
  dateString,
  occupancies = new Set(),
  classNames,
  disabled,
  onClick,
}: CalendarDayProps) {
  const date = parseISO(dateString);
  const { t } = useTranslation();
  const slots = occupancySlotsInCalendarDay(date, occupancies);

  if (typeof disabled === "function") disabled = disabled(date);
  if (typeof classNames === "function") classNames = classNames(date);

  const button = (
    <button
      type="button"
      disabled={disabled}
      onClick={onClick}
      value={formatISO(date, { representation: "date" })}
      className={classNames}
      css={styles(slots.map((slot) => slot?.color))}
    >
      {date.getDate()}
    </button>
  );

  if (occupancies.size <= 0) return button;

  const popover = (
    <Popover id="popover-basic">
      <Popover.Body>
        {Array.from(occupancies).map((occupancy) => {
          const deadline = occupancy.deadline;

          return (
            <dl
              className="my-2"
              key={`${formatISO(date, { representation: "date" })}-${occupancy.id}`}
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
  const dayElement = (dateString: string) =>
    React.useCallback(
      (dateString: string) => {
        const occupancies = occupanciesAt(dateString, occupancyWindow);
        return (
          <CalendarDay
            occupancies={occupancies}
            dateString={dateString}
            onClick={onClickCallback}
            classNames={classNamesCallback}
            disabled={
              disabledCallback ||
              ((date: Date) => defaultDisabledCallback(date, occupancyWindow))
            }
          ></CalendarDay>
        );
      },
      [dateString, !!occupancyWindow]
    )(dateString);

  return (
    <div className="occupancyCalendar">
      <Calendar
        start={start}
        monthsCount={monthsCount}
        dayElement={dayElement}
      ></Calendar>
    </div>
  );
}

export default CalendarWithOccupancies;
