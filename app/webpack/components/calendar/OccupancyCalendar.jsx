import React from 'react';
import Calendar from './Calendar';
import { OccupancyCalendarContextProvider } from './OccuancyCalendarContext';
import { OccupancyCalendarDayInContext } from './OccupancyCalendarDay';

const OccupancyCalendar = ({
  occupancyAtUrl,
  calendarUrl,
  displayMonths = 8,
}) => {
  const handleClick = (e) =>
    (window.top.location.href = `${occupancyAtUrl}@${e.target.value}`);

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
