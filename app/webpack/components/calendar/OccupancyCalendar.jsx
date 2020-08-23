import React from 'react'
import Calendar from './Calendar'
import { OccupancyCalendarContextProvider } from './OccuancyCalendarContext'
import { homeOccupancyAtPath } from '../../services/routes'
import { OccupancyCalendarDayInContext } from './OccupancyCalendarDay'

const OccupancyCalendar = ({ homeId, baseUrl, displayMonths = 8 }) => {
  const handleClick = e => window.top.location.href = homeOccupancyAtPath(baseUrl, homeId, e.target.value)

  return (
    <OccupancyCalendarContextProvider homeId={homeId} baseUrl={baseUrl} >
      <Calendar displayMonths={displayMonths}>
        <OccupancyCalendarDayInContext onClick={handleClick}></OccupancyCalendarDayInContext>
      </Calendar>
    </OccupancyCalendarContextProvider>
  )
}

export default OccupancyCalendar