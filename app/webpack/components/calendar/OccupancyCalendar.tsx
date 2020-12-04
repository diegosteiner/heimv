import * as React from 'react';
import Calendar from './Calendar';
import { Provider as OccupancyCalendarContextProvider } from './OccuancyCalendarContext';
import { OccupancyCalendarDayInContext } from './OccupancyCalendarDay';

interface OccuancyCalendarProps {
  occupancyAtUrl: string;
  calendarUrl: string;
  displayMonths: number;
}

const OccupancyCalendar: React.FC<OccuancyCalendarProps> = ({
  occupancyAtUrl,
  calendarUrl,
  displayMonths = 8,
}) => {
  const handleClick = (e: React.MouseEvent): void => {
    const target = e.target as HTMLButtonElement;
    if (!target.value) return;

    window.top.location.href = occupancyAtUrl.replace('$DATE', target.value);
  };

  return (
    <OccupancyCalendarContextProvider calendarUrl={calendarUrl}>
      <Calendar displayMonths={displayMonths}>
        <OccupancyCalendarDayInContext
          onClick={handleClick}
        ></OccupancyCalendarDayInContext>
      </Calendar>
    </OccupancyCalendarContextProvider>
  );
};

export default OccupancyCalendar;
