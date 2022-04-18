import * as React from "react";
import { formatISO, isBefore, isAfter, setHours, startOfDay, endOfDay, isWithinInterval } from "date-fns/esm";
import Calendar from "./Calendar";
import { Popover, OverlayTrigger } from "react-bootstrap";
import { css } from "@emotion/react";
import * as chroma from 'chroma.ts'
import { useTranslation } from "react-i18next";
import { OccupancyWindow, occupanciesAt } from "../../models/OccupancyWindow";
import { Occupancy } from "../../models/Occupancy";

const calendarDayBaseStyle = css`
  border: 1px solid transparent;
  background: transparent;
  font-size: 0.9rem;

  &.occupied {
    font-weight: bold;
    color: var(--calendar-color);
    background: var(--calendar-background);
    border-top-color: var(--calendar-forenoon-color);
    border-left-color: var(--calendar-forenoon-color);
    border-right-color: var(--calendar-afternoon-color);
    border-bottom-color: var(--calendar-afternoon-color);
  }
`

function calendarDayFullStyle(hexColorString: string): React.CSSProperties {
  if (!hexColorString) return {}

  const color = chroma.css(hexColorString);
  return {
    color: color.toString(),
    borderColor: color.toString(),
    backgroundColor: color.alpha(0.3).toString(),
  }
};

function calendarDayDividedStyle(hexTopColorString?: string, hexBottomColorString?: string): React.CSSProperties {
  const fallbackColor = "#FFFFFF"
  const textColor = hexTopColorString || hexBottomColorString;
  const topColor = chroma.css(hexTopColorString || fallbackColor);
  const bottomColor = chroma.css(hexBottomColorString || fallbackColor);
  const background = `linear-gradient(135deg, 
                        ${topColor.alpha(0.3)} 48%, 
                        ${fallbackColor} 48%, 
                        ${fallbackColor} 52%, 
                        ${bottomColor.alpha(0.3)} 52%`

  return {
    color: textColor,
    borderTopColor: topColor.toString(),
    borderLeftColor: topColor.toString(),
    borderBottomColor: bottomColor.toString(),
    borderRightColor: bottomColor.toString(),
    background: background
  }
};

function calendarDayStyle(slots: CalendarDaySlot<Occupancy>) {
  if (!slots || slots == [null, null]) return
  if (slots instanceof Array && (slots[0] || slots[1])) {
    return calendarDayDividedStyle(slots[0]?.color, slots[1]?.color);
  }
  slots = slots as Occupancy;
  if (slots.color) return calendarDayFullStyle(slots.color)
}

type CalendarDaySlot<T> = [T | null, T | null] | T;

function occupancySlotsInCalendarDay(date: Date, occupancies: Set<Occupancy>) {
  const midDay = setHours(startOfDay(date), 12);
  const slots: CalendarDaySlot<Occupancy> = [null, null]

  for (const occupancy of Array.from(occupancies)) {
    if (isWithinInterval(occupancy.ends_at, { start: startOfDay(date), end: midDay })) {
      slots[0] = occupancy;
      continue;
    }
    if (isWithinInterval(occupancy.begins_at, { start: midDay, end: endOfDay(date) })) {
      slots[1] = occupancy;
      continue;
    }
    return occupancy
  }

  return slots;
};

export function defaultDisabledCallback(date: Date, occupancyWindow?: OccupancyWindow): boolean {
  return !occupancyWindow || isBefore(date, occupancyWindow.start) || isAfter(date, occupancyWindow.end);
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

export function CalendarDay({ date, occupancyWindow, classNames, disabled, onClick }: CalendarDayProps) {
  const occupancies = occupanciesAt(date, occupancyWindow);
  const { t } = useTranslation();
  const slots = occupancySlotsInCalendarDay(date, occupancies)

  if (typeof disabled === "function") disabled = disabled(date);
  if (typeof classNames === "function") classNames = classNames(date);

  const button = (
    <button
      type="button"
      disabled={disabled}
      onClick={onClick}
      value={formatISO(date, { representation: "date" })}
      className={classNames}
      css={calendarDayBaseStyle}
      style={calendarDayStyle(slots)}
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
            <dl className="my-2" key={`${formatISO(date, { representation: "date" })} -${occupancy.id} `}>
              <dt>
                {formatDate(occupancy.begins_at)} - {formatDate(occupancy.ends_at)}
              </dt>
              <dd>
                <span>
                  <>
                    {t(`activerecord.enums.occupancy.occupancy_type.${occupancy.occupancy_type} `)}
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
      classNames={classNamesCallback}
      disabled={disabledCallback || ((date: Date) => defaultDisabledCallback(date, occupancyWindow))}
    ></CalendarDayMemo>
  );

  return (
    <div className="occupancyCalendar">
      <Calendar start={start} monthsCount={monthsCount} dayElement={dayElement}></Calendar>
    </div>
  );
}

export default CalendarWithOccupancies;
