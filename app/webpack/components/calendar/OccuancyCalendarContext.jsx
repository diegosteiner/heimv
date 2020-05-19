import React, { useState, createContext, useEffect } from "react";
import { homeCalendarPath } from '../../services/routes'
import { parseISO, formatISO, eachDayOfInterval, areIntervalsOverlapping, startOfDay, endOfDay, isBefore, isAfter, setHours, isWithinInterval } from 'date-fns/esm'

export const OccupancyCalendarContext = createContext();

const filterOccupanciesByDate = (occupancies, date) => {
  return occupancies.filter(occupancy => {
    return areIntervalsOverlapping(
      { start: occupancy.begins_at, end: occupancy.ends_at },
      { start: startOfDay(date), end: endOfDay(date) }
    )
  })
}

const flagsForDayWithOccupancies = (date, occupancies, windowFrom, windowTo) => {
  if (isBefore(date, windowFrom) || isAfter(date, windowTo)) return ['outOfWindow']

  const midDay = setHours(startOfDay(date), 12)

  return occupancies.map((occupancy) => {
    if (isWithinInterval(occupancy.ends_at, { start: startOfDay(date), end: midDay })) {
      return `${occupancy.occupancy_type}Forenoon`
    }
    if (isWithinInterval(occupancy.begins_at, { start: midDay, end: endOfDay(date) })) {
      return `${occupancy.occupancy_type}Afternoon`
    }
    return `${occupancy.occupancy_type}Fullday`
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

  const occupancyDates = {} 

  for(const date of eachDayOfInterval({ start: windowFrom, end: windowTo })) {
    const filteredOccupancies = filterOccupanciesByDate(occupancies, date)

    occupancyDates[formatISO(date, { representation: 'date' })] = {
      occupancies: filteredOccupancies,
      flags: flagsForDayWithOccupancies(date, filteredOccupancies, windowFrom, windowTo)
    }
  }

  return {
          ...calendarData,
          window_from: windowFrom,
          window_to: windowTo, 
          occupancies,
          occupancyDates
  }
}

export const OccupancyCalendarContextProvider = ({ children, homeId }) => {
  const [calendarData, setCalendarData] = useState({
    occupancies: [],
    occupancyDates: {},
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
