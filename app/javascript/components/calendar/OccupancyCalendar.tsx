import * as React from "react";
import {
  OccupancyWindow,
  fromJson as occupancyWindowFromJson,
} from "../../models/OccupancyWindow";
import CalendarWithOccupancies from "./CalendarWithOccupancies";

interface OccupancyCalendarProps {
  start?: string;
  monthsCount?: number;
  occupancyAtUrl: string;
  calendarUrl: string;
}

function OccupancyCalendar({
  start,
  calendarUrl,
  occupancyAtUrl,
  monthsCount,
}: OccupancyCalendarProps) {
  const [occupancyWindow, setOccupancyWindow] = React.useState<
    OccupancyWindow | undefined
  >();

  React.useEffect(() => {
    (async () => {
      const result = await fetch(calendarUrl);
      if (result.status == 200)
        setOccupancyWindow(occupancyWindowFromJson(await result.json()));
    })();
  }, []);

  const handleClick = (e: React.MouseEvent): void => {
    const target = e.target as HTMLButtonElement;
    if (!target.value || !window.top) return;

    window.top.location.href = occupancyAtUrl.replace("$DATE", target.value);
  };

  return (
    <CalendarWithOccupancies
      start={start}
      monthsCount={monthsCount}
      onClickCallback={handleClick}
      occupancyWindow={occupancyWindow}
    ></CalendarWithOccupancies>
  );
}

export default OccupancyCalendar;
