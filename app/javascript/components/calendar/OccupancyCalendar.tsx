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

  return (
    <form action={occupancyAtUrl} method="GET">
      <CalendarWithOccupancies
        start={start}
        monthsCount={monthsCount}
        occupancyWindow={occupancyWindow}
      ></CalendarWithOccupancies>
    </form>
  );
}

export default OccupancyCalendar;
