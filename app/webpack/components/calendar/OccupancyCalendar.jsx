import React from 'react'
import Calendar from './Calendar'
import { OccupancyCalendarContextProvider } from './OccuancyCalendarContext'
import { homeOccupancyAtPath } from '../../services/routes'
import { OccupancyCalendarDayInContext } from './OccupancyCalendarDay'

const OccupancyCalendar = ({ homeId }) => {
  const handleClick = e => window.location.href = homeOccupancyAtPath(homeId, e.target.value)

  return (
    <OccupancyCalendarContextProvider homeId={homeId} >
      <Calendar>
        <OccupancyCalendarDayInContext onClick={handleClick}></OccupancyCalendarDayInContext>
      </Calendar>
    </OccupancyCalendarContextProvider>
  )
}

export default OccupancyCalendar