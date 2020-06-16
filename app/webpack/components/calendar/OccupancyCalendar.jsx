import React from 'react'
import Calendar from './Calendar'
import { OccupancyCalendarContextProvider } from './OccuancyCalendarContext'
import { homeOccupancyAtPath } from '../../services/routes'
import { OccupancyCalendarDayInContext } from './OccupancyCalendarDay'

const OccupancyCalendar = ({ homeId, displayMonths = 8 }) => {
  const handleClick = e => window.top.location.href = homeOccupancyAtPath(homeId, e.target.value)

  return (
    <OccupancyCalendarContextProvider homeId={homeId} >
      <Calendar displayMonths={displayMonths}>
        <OccupancyCalendarDayInContext onClick={handleClick}></OccupancyCalendarDayInContext>
      </Calendar>
    </OccupancyCalendarContextProvider>
  )
}

export default OccupancyCalendar