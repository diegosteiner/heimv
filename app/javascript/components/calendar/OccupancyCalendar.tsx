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
    e.preventDefault();
    if (!target.value || !window.top) return;
    const url = occupancyAtUrl.replace("__DATE__", target.value);
    window.top.location.href = url;
  };

  return (
    <form action={occupancyAtUrl} method="GET">
      <CalendarWithOccupancies
        start={start}
        monthsCount={monthsCount}
        occupancyWindow={occupancyWindow}
        onClick={handleClick}
      ></CalendarWithOccupancies>
    </form>
  );
}

export default OccupancyCalendar;
