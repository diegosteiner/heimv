import React, { useContext, useMemo } from 'react'
import { OccupancyCalendarContext } from './OccuancyCalendarContext'
import classNames from 'classnames'
import styles from './OccupancyCalendar.module.scss'
import Popover from 'react-bootstrap/Popover'
import OverlayTrigger from 'react-bootstrap/OverlayTrigger'
import { formatISO } from 'date-fns/esm'

const formatDate = new Intl.DateTimeFormat("de-CH", {
  year: "numeric",
  month: "2-digit",
  day: "2-digit",
    hour: 'numeric', minute: 'numeric', hour12: false
}).format

export const OccupancyCalendarDayInContext = ({ date, onClick }) => {
  const { loading, calendarData } = useContext(OccupancyCalendarContext)
  const occupancyDate = calendarData.occupancyDates && calendarData.occupancyDates[formatISO(date, { representation: 'date' })]
  const flags = occupancyDate && occupancyDate.flags || []
  const disableCallback = () => loading || !occupancyDate || flags.includes('outOfWindow') 
  const classNameCallback = () => [styles.calendarDate, ...(flags.map(flag => styles[flag]))]

  return <OccupancyCalendarDay classNameCallback={classNameCallback} disableCallback={disableCallback} { ...{ date, onClick }} ></OccupancyCalendarDay>
}

export const OccupancyCalendarDay = ({ date, onClick, occupancies = [], classNameCallback, disableCallback }) => {
  const disabled = disableCallback && disableCallback(date)
  const className = classNameCallback && classNameCallback(date) || [styles.calendarDate]

  const button = <button type="button" disabled={disabled} onClick={onClick} value={formatISO(date, { representation: 'date' })} className={classNames(className)}>{date.getDate()}</button>

  if(occupancies.length <= 0) return button

  const popover = (
    <Popover id="popover-basic">
      <Popover.Content>
        {occupancies.map(occupancy => {
          return (<dl className="my-1" key={`${formatISO(date, { representation: 'date' })}-${occupancy.id}`}>
            <dt>{formatDate(occupancy.begins_at)} - {formatDate(occupancy.ends_at)}</dt>
            <dd>
              {occupancy.ref}
              <span> {occupancy.occupancy_type}</span>
              {/* <span v-if="occupancy.deadline">(bis {{ $d(Date.parse(occupancy.deadline), 'shortTime')}})</span> */}
            </dd>
          </dl>)
        })}
      </Popover.Content>
    </Popover>
  )

  return (<OverlayTrigger trigger={['focus', 'hover']} overlay={popover}>{button}</OverlayTrigger>)
}