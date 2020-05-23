import React from 'react'
import Calendar from './Calendar'
import { OccupancyCalendarContextProvider } from './OccuancyCalendarContext'
import { newBookingPath } from '../../services/routes'
import { OccupancyCalendarDayInContext } from './OccupancyCalendarDay'

const OccupancyCalendar = ({ homeId }) => {
  const handleClick = e => window.location.href = newBookingPath(homeId, { occupancy_attributes: { begins_at: e.target.value } })

  return (
    <OccupancyCalendarContextProvider homeId={homeId} >
      <Calendar>
        <OccupancyCalendarDayInContext onClick={handleClick}></OccupancyCalendarDayInContext>
      </Calendar>
    </OccupancyCalendarContextProvider>
  )
}

export default OccupancyCalendar