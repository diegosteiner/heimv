import React, { useContext } from 'react'
import Calendar from './Calendar'
import { OccupancyCalendarContext, OccupancyCalendarContextProvider } from './OccuancyCalendarContext'
import OccupancyCalendarDay from './OccupancyCalendarDay'
import { newBookingPath } from '../../services/routes'

const OccupancyCalendar = ({ homeId }) => {
  const handleClick = e => window.location.href = newBookingPath(homeId, { begins_at: e.target.value })

  return (
    <OccupancyCalendarContextProvider homeId={homeId} >
      <Calendar>
        <OccupancyCalendarDay onClick={handleClick}></OccupancyCalendarDay>
      </Calendar>
    </OccupancyCalendarContextProvider>
  )
}

export default OccupancyCalendar