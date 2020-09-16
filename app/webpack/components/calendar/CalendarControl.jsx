import React, { useState } from 'react'
import { InputGroup, Form, Button, Modal, Row, Col } from 'react-bootstrap'
import { OccupancyCalendarDay } from './OccupancyCalendarDay'
import Calendar from './Calendar'
import { formatISO, parseISO, parse, isSameDay, isValid, setHours, setMinutes, getHours, getMinutes } from 'date-fns/esm'

const formatDate = new Intl.DateTimeFormat("de-CH", {
  year: "numeric",
  month: "2-digit",
  day: "2-digit"
}).format

const initializeValue = (value) => {
  if (isValid(value)) return value
  value = parseISO(value)
  if (!isValid(value)) return null
  if (value && getHours(value) < Math.min(...availableHours)) return setHours(value, Math.min(...availableHours));
  if (value && getHours(value) > Math.max(...availableHours)) return setHours(value, Math.max(...availableHours));
  return value
}

const availableHours = [8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22]
const allHours = [...new Array(23).keys()]
const availableMinutes = [0, 15, 30, 45]
const clamp = (value, min, max) => value > max ? max : value < min ? min : value
const closestMinutes = (minutes) => {
  return availableMinutes.reduce((a, b) => Math.abs(b - minutes) < Math.abs(a - minutes) ? b : a);
};

const CalendarControl = ({ value = "", name, required = false, disabled = false, onChange, onBlur, isInvalid }) => {
  value = initializeValue(value)
  const defaultHours = getHours(value) || Math.min(...availableHours)
  const defaultMinutes = closestMinutes(getMinutes(value)) || Math.min(...availableMinutes)
  const [state, setState] = useState({ showModal: false, date: value, textDate: (value && formatDate(value) || ""), hours: defaultHours, minutes: defaultMinutes })
  const setDateValue = (date, prevState = state) => {
    setState({ ...prevState, date: date, textDate: formatDate(date) });
    onChange && onChange(date);
  }
  const setHourValue = hourValue => setDateValue(setHours(state.date, clamp(parseInt(hourValue), Math.min(...availableHours), Math.max(...availableHours))), { ...state, hours: hourValue })
  const setMinuteValue = minuteValue => setDateValue(setMinutes(state.date, clamp(parseInt(minuteValue), Math.min(...availableMinutes), Math.max(...availableMinutes))), { ...state, minutes: minuteValue })

  const handleClose = () => setState({ ...state, showModal: false });
  const handleShow = () => setState({ ...state, showModal: true });
  const handleClick = event => {
    if (disabled) return
    let parsedValue = parseISO(event.target.value)
    if (!isValid(parsedValue)) return

    parsedValue = setHours(parsedValue, state.hours)
    parsedValue = setMinutes(parsedValue, state.minutes)
    setDateValue(parsedValue, { ...state, showModal: false })
  }
  const handleHourChange = event => setHourValue(event.target.value)
  const handleMinuteChange = event => setMinuteValue(event.target.value)
  const handleDateChange = event => {
    if (disabled) return
    setState({ ...state, textDate: event.target.value })
    let parsedValue = parse(event.target.value, 'dd.MM.yyyy', new Date())
    if (!isValid(parsedValue)) return

    parsedValue = setHours(parsedValue, state.hours)
    parsedValue = setMinutes(parsedValue, state.minutes)
    setDateValue(parsedValue, state)
  }

  const disableCallback = date => !state.showModal || date <= new Date()
  const classNameCallback = date => isSameDay(date, state.date) && ['bg-primary', 'text-white']

  return (
    <div className={isInvalid && 'is-invalid'}>
      <input type="hidden" name={name} value={state.date && formatISO(state.date) || ""} />
      <Row>
        <Col>
          <InputGroup>
            <Form.Control onBlur={onBlur} disabled={disabled} value={state.textDate} onChange={handleDateChange} isInvalid={isInvalid} required={required} />
            <InputGroup.Append>
              <Button variant="primary" onClick={handleShow} disabled={disabled}><i className="fa fa-calendar"></i></Button>
            </InputGroup.Append>
          </InputGroup>
        </Col>
        <Col sm={6} className="d-flex">
          <Form.Control value={state.hours} onBlur={onBlur} className="d-inline-block w-auto" onChange={handleHourChange} isInvalid={isInvalid} disabled={disabled} required={required} as="select">
            {allHours.map(hour => <option disabled={!availableHours.includes(hour)} key={hour} value={hour}>{hour.toString().padStart(2, '0')}</option>)}
          </Form.Control>
          <Form.Control value={state.minutes} onBlur={onBlur} className="d-inline-block w-auto" onChange={handleMinuteChange} isInvalid={isInvalid} disabled={disabled} required={required} as="select">
            {availableMinutes.map(minutes => <option key={minutes} value={minutes}>{minutes.toString().padStart(2, '0')}</option>)}
          </Form.Control>
        </Col>
      </Row>
      <Modal size='lg' show={state.showModal} onHide={handleClose}>
        <Modal.Body>
          <Calendar firstMonth={state.date || new Date()}>
            <OccupancyCalendarDay onClick={handleClick} classNameCallback={classNameCallback} disableCallback={disableCallback}></OccupancyCalendarDay>
          </Calendar>
        </Modal.Body>
      </Modal>
    </div>
  )
}

export default CalendarControl