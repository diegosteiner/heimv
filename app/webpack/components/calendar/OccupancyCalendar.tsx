import * as React from "react";
import { parseISO, formatISO, isBefore, isAfter, setHours, startOfDay, endOfDay, isWithinInterval } from "date-fns/esm";
import Calendar from "./Calendar";
import { Popover, OverlayTrigger } from "react-bootstrap";
import styled from "@emotion/styled";
import { useTranslation } from "react-i18next";
import { Occupancy } from "../../models/Occupancy";
import { OccupancyWindow, fromJson as occupancyWindowFromJson } from "../../models/OccupancyWindow";

const OccupancyCalendarContainer = styled.div`
  .calendarLoading {
    height: 36em;
    background-image: url(data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0idXRmLTgiPz4KPHN2ZyB4bWxucz
      0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHN0eWxlPSJiYWNrZ3JvdW5kOiByZ2IoMjQxLCAyNDIsIDI0MykiIHdpZHRoPSI0MyIgaGVpZ2
      h0PSI0MyIgcHJlc2VydmVBc3BlY3RSYXRpbz0ieE1pZFlNaWQiIHZpZXdCb3g9IjAgMCA0MyA0MyI+PGcgdHJhbnNmb3JtPSJzY2FsZSgwLjE3KS
      I+PGRlZnM+PGcgaWQ9InN0cmlwZSI+PHBhdGggZD0iTTI1NiAtMTI4IEwzODQgLTEyOCBMLTEyOCAzODQgTC0xMjggMjU2IFoiIGZpbGw9IiNmZm
      ZmZmYiPjwvcGF0aD48cGF0aCBkPSJNMzg0IDAgTDM4NCAxMjggTDEyOCAzODQgTDAgMzg0IFoiIGZpbGw9IiNmZmZmZmYiPjwvcGF0aD48L2c+PC
      9kZWZzPjxnIHRyYW5zZm9ybT0idHJhbnNsYXRlKDE5Ni4yMDggMCkiPjx1c2UgaHJlZj0iI3N0cmlwZSIgeD0iLTI1NiIgeT0iMCI+PC91c2U+PH
      VzZSBocmVmPSIjc3RyaXBlIiB4PSIwIiB5PSIwIj48L3VzZT48YW5pbWF0ZVRyYW5zZm9ybSBhdHRyaWJ1dGVOYW1lPSJ0cmFuc2Zvcm0iIHR5cG
      U9InRyYW5zbGF0ZSIga2V5VGltZXM9IjA7MSIgcmVwZWF0Q291bnQ9ImluZGVmaW5pdGUiIGR1cj0iMC41cyIgdmFsdWVzPSIwIDA7IDI1NiAwIj
      48L2FuaW1hdGVUcmFuc2Zvcm0+PC9nPjwvZz48L3N2Zz4K);
  }

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

const occupancyDateClassNames = (date: Date, occupancies: Set<Occupancy>): string[] => {
  const midDay = setHours(startOfDay(date), 12);

  return Array.from(occupancies).map(({ start, end, occupancy_type }) => {
    if (isWithinInterval(end, { start: startOfDay(date), end: midDay })) {
      return `${occupancy_type}-forenoon`;
    }
    if (isWithinInterval(start, { start: midDay, end: endOfDay(date) })) {
      return `${occupancy_type}-afternoon`;
    }
    return `${occupancy_type}-fullday`;
  });
};

const formatDate = new Intl.DateTimeFormat("de-CH", {
  year: "numeric",
  month: "2-digit",
  day: "2-digit",
  hour: "numeric",
  minute: "numeric",
  hour12: false,
}).format;

interface OccupancyCalendarDayProps {
  dateString?: string;
  occupancyWindow?: OccupancyWindow;
  onClick(e: React.MouseEvent): void;
  classNames?: string | ((date: Date, occupancies: Set<Occupancy>) => string);
  disabled?: boolean | ((date: Date, occupancies: Set<Occupancy>) => boolean);
}

export const OccupancyCalendarDay: React.FC<OccupancyCalendarDayProps> = ({
  dateString,
  occupancyWindow,
  classNames,
  disabled,
  onClick,
}) => {
  if (!dateString) return <></>;

  const date = parseISO(dateString);
  const occupancies = occupancyWindow?.occupiedDates[dateString] || new Set<Occupancy>();

  if (typeof disabled === "function") {
    disabled = disabled(date, occupancies);
  } else if (disabled === undefined) {
    disabled = !occupancyWindow || isBefore(date, occupancyWindow.start) || isAfter(date, occupancyWindow.end);
  }
  if (typeof classNames === "function") {
    classNames = classNames(date, occupancies);
  } else if (classNames === undefined) {
    classNames = occupancyDateClassNames(date, occupancies).join(" ");
  }
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
            <dl className="my-2" key={`${formatISO(date, { representation: "date" })}-${occupancy.id}`}>
              <dt>
                {formatDate(occupancy.start)} - {formatDate(occupancy.end)}
              </dt>
              <dd>
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
};
const OccupancyCalendarDayMemo = React.memo(OccupancyCalendarDay);

interface OccupancyCalendarProps {
  start?: string;
  monthsCount?: number;
  occupancyAtUrl: string;
  calendarUrl: string;
}

const OccupancyCalendar: React.FC<OccupancyCalendarProps> = ({ start, calendarUrl, occupancyAtUrl, monthsCount }) => {
  const [occupancyWindow, setOccupancyWindow] = React.useState<OccupancyWindow | null>();

  React.useEffect(() => {
    (async () => {
      const result = await fetch(calendarUrl);
      if (result.status == 200) setOccupancyWindow(occupancyWindowFromJson(await result.json()));
    })();
  }, []);

  const handleClick = (e: React.MouseEvent): void => {
    const target = e.target as HTMLButtonElement;
    if (!target.value || !window.top) return;

    window.top.location.href = occupancyAtUrl.replace("$DATE", target.value);
  };

  const dayElement = (occupancyWindow && (
    <OccupancyCalendarDayMemo occupancyWindow={occupancyWindow} onClick={handleClick}></OccupancyCalendarDayMemo>
  )) || <></>;
  return (
    <OccupancyCalendarContainer className="occupancyCalendar">
      <Calendar start={start} monthsCount={monthsCount}>
        {dayElement}
      </Calendar>
    </OccupancyCalendarContainer>
  );
};

export default OccupancyCalendar;
