import * as React from 'react';
import { Occupancy, OccupancyJsonData } from '../../models/occupancy';
import {
  parseISO,
  formatISO,
  eachDayOfInterval,
  areIntervalsOverlapping,
  startOfDay,
  endOfDay,
  isBefore,
  isAfter,
  setHours,
  isWithinInterval,
} from 'date-fns';
const { useState, createContext, useEffect } = React;

const defaultOccypancyCalendarState: OccupancyCalendarState = {
  occupancies: [],
  occupancyDates: {},
  windowFrom: null,
  windowTo: null,
};
const defaultContext = {
  loading: true,
  occupancyCalendarState: defaultOccypancyCalendarState,
};

export const OccupancyCalendarContext = createContext<ContextType>(defaultContext);

const filterOccupanciesByDate = (occupancies: Occupancy[], date: Date) => {
  return occupancies.filter((occupancy) => {
    return areIntervalsOverlapping(
      { start: occupancy.begins_at, end: occupancy.ends_at },
      { start: startOfDay(date), end: endOfDay(date) },
    );
  });
};

const flagsForDayWithOccupancies = (
  date: Date,
  occupancies: Occupancy[],
  windowFrom: Date,
  windowTo: Date,
): string[] => {
  if (isBefore(date, windowFrom) || isAfter(date, windowTo)) return ['outOfWindow'];

  const midDay = setHours(startOfDay(date), 12);

  return occupancies.map((occupancy) => {
    if (occupancy.occupancy_type == 'closed') return 'closed';
    if (
      isWithinInterval(occupancy.ends_at, {
        start: startOfDay(date),
        end: midDay,
      })
    ) {
      return `${occupancy.occupancy_type}Forenoon`;
    }
    if (
      isWithinInterval(occupancy.begins_at, {
        start: midDay,
        end: endOfDay(date),
      })
    ) {
      return `${occupancy.occupancy_type}Afternoon`;
    }
    return `${occupancy.occupancy_type}Fullday`;
  });
};

type CalendarJsonData = {
  window_from: string;
  window_to: string;
  occupancies: OccupancyJsonData[];
};

type OccupancyDate = {
  occupancies: Occupancy[];
  flags: string[];
};

type OccupancyCalendarState = {
  windowFrom: Date | null;
  windowTo: Date | null;
  occupancies: Occupancy[];
  occupancyDates: { [key: string]: OccupancyDate };
};

const preprocessCalendarData = (calendarData: CalendarJsonData): OccupancyCalendarState => {
  const windowFrom = parseISO(calendarData.window_from);
  const windowTo = parseISO(calendarData.window_to);
  const occupancies = calendarData.occupancies.map((occupancy) => {
    return {
      ...occupancy,
      begins_at: parseISO(occupancy.begins_at),
      ends_at: parseISO(occupancy.ends_at),
    };
  });

  const occupancyDates: { [key: string]: OccupancyDate } = {};

  for (const date of eachDayOfInterval({ start: windowFrom, end: windowTo })) {
    const filteredOccupancies = filterOccupanciesByDate(occupancies, date);

    occupancyDates[formatISO(date, { representation: 'date' })] = {
      occupancies: filteredOccupancies,
      flags: flagsForDayWithOccupancies(date, filteredOccupancies, windowFrom, windowTo),
    };
  }

  return {
    windowFrom,
    windowTo,
    occupancies,
    occupancyDates,
  };
};

interface ProviderProps {
  calendarUrl: string;
}

export type ContextType = {
  occupancyCalendarState: OccupancyCalendarState;
  loading: boolean;
};

export const Provider: React.FC<ProviderProps> = ({ children, calendarUrl }) => {
  const [occupancyCalendarState, setOccupancyCalendarState] = useState<OccupancyCalendarState>(
    defaultOccypancyCalendarState,
  );
  const [loading, setLoading] = useState<boolean>(true);
  // const [organisation] = useState({});

  useEffect(() => {
    (async () => {
      const result = await fetch(calendarUrl);

      if (result.status == 200)
        setOccupancyCalendarState(preprocessCalendarData((await result.json()) as CalendarJsonData));
      setLoading(false);
    })();
  }, []);

  return (
    <OccupancyCalendarContext.Provider value={{ occupancyCalendarState, loading }}>
      {children}
    </OccupancyCalendarContext.Provider>
  );
};
