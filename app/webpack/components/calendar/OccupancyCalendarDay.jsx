import React, { useContext, useMemo } from 'react'
import { OccupancyCalendarContext } from './OccuancyCalendarContext'
import { isBefore, isAfter, startOfDay, endOfDay, setHours, isWithinInterval, formatISO } from 'date-fns/esm'
import classNames from 'classnames'
import styles from './OccupancyCalendar.module.scss'
import Popover from 'react-bootstrap/Popover'
import OverlayTrigger from 'react-bootstrap/OverlayTrigger'

const classNamesForDateWithOccupancies = (disabled, occupancies, date) => {
  if (disabled) return [styles.disabled]

  const midDay = setHours(startOfDay(date), 12)

  return occupancies.map((occupancy) => {
    if (isWithinInterval(occupancy.ends_at, { start: startOfDay(date), end: midDay })) {
      return styles[`${occupancy.occupancy_type}Forenoon`]
    }
    if (isWithinInterval(occupancy.begins_at, { start: midDay, end: endOfDay(date) })) {
      return styles[`${occupancy.occupancy_type}Afternoon`]
    }
    return styles[`${occupancy.occupancy_type}Fullday`]
  })
}

  const formatDate = new Intl.DateTimeFormat("de-CH", {
    year: "numeric",
    month: "2-digit",
    day: "2-digit",
     hour: 'numeric', minute: 'numeric', hour12: false
  }).format

const OccupancyCalendarDay = ({ date, onClick }) => {
  const { loading, calendarData } = useContext(OccupancyCalendarContext)
  const occupancies = calendarData.occupanciesByDate[formatISO(date, { representation: 'date' })] || []
  const appliedClassNames = useMemo(() => {
    const disabled = isBefore(date, calendarData.window_from) || isAfter(date, calendarData.window_to) || loading

    return classNames([styles.calendarDate, ...classNamesForDateWithOccupancies(disabled, occupancies, date)])
  }, [loading, calendarData, formatISO(date)])

  if(occupancies.count > 0) {

  const popover = (
    <Popover id="popover-basic">
      <Popover.Content>
        {occupancies.map(occupancy => {
          return (<dl className="my-1" key={occupancy.id}>
            <dt>{formatDate(occupancy.begins_at)} - {formatDate(occupancy.ends_at)}</dt>
            <dd>
              {occupancy.ref}
              <span>{occupancy.occupancy_type}</span>
              {/* <span v-if="occupancy.deadline">(bis {{ $d(Date.parse(occupancy.deadline), 'shortTime')}})</span> */}
            </dd>
          </dl>)
        })}
      </Popover.Content>
    </Popover>
  );
    return (<OverlayTrigger trigger={['focus', 'hover']} overlay={popover}>
      <button type="button" className={appliedClassNames}>{date.getDate()}</button>
    </OverlayTrigger>)
  } else {
      return <button type="button" onClick={onClick} value={formatISO(date, { representation: 'date' })} className={appliedClassNames}>{date.getDate()}</button>
  }
}

export default OccupancyCalendarDay