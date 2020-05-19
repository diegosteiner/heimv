import React, { useState, createContext, useEffect } from "react";
import { homeCalendarPath } from '../../services/routes'
import { parseISO, formatISO, eachDayOfInterval, areIntervalsOverlapping, startOfDay, endOfDay } from 'date-fns/esm'

export const OccupancyCalendarContext = createContext();

const occupanciesOfDate = (occupancies, date) => {
  return occupancies.filter(occupancy => {
    return areIntervalsOverlapping(
      { start: occupancy.begins_at, end: occupancy.ends_at },
      { start: startOfDay(date), end: endOfDay(date) }
    )
  })
}

const preprocessCalendarData = calendarData => {
  const windowFrom = parseISO(calendarData.window_from)
  const windowTo = parseISO(calendarData.window_to)
  const occupancies = calendarData.occupancies.map(occupancy => {
    return {
      ...occupancy,
      begins_at: parseISO(occupancy.begins_at),
      ends_at: parseISO(occupancy.ends_at),
    }
  })
  const occupanciesByDate = {} 
  for(const date of eachDayOfInterval({ start: windowFrom, end: windowTo })) {
    occupanciesByDate[formatISO(date, { representation: 'date' })] = occupanciesOfDate(occupancies, date)
  }

  return {
          ...calendarData,
          window_from: windowFrom,
          window_to: windowTo, 
          occupancies,
          occupanciesByDate
  }
}

export const OccupancyCalendarContextProvider = ({ children, homeId }) => {
  const [calendarData, setCalendarData] = useState({
    occupancies: [],
    occupanciesByDate: {},
    window_from: null,
    window_to: null
  })
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    (async () => {
      const result = await fetch(homeCalendarPath(homeId));

      if (result.status == 200) setCalendarData(preprocessCalendarData(await result.json()))
      setLoading(false)
    })();
  }, []);

  return (
    <OccupancyCalendarContext.Provider value={{ calendarData, loading }} >
      {children}
    </OccupancyCalendarContext.Provider>
  );
}; 
