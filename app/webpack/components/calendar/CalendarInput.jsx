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

const availableHours = [8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22]
const allHours = [...new Array(23).keys()]
const availableMinutes = [0, 15, 30, 45]
const clamp = (value, min, max) => value > max ? max : value < min ? min : value

const CalendarInput = ({ value = "", name, label, required = false, disabled = false }) => {
  value = value && parseISO(value)
  if(getHours(value) < Math.min(...availableHours)) value = setHours(value, Math.min(...availableHours));
  if(getHours(value) > Math.max(...availableHours)) value = setHours(value, Math.max(...availableHours));
  const [state, setState] = useState({ showModal: false, date: value, string: (value && formatDate(value) || ""), hours: Math.min(...availableHours), minutes: Math.min(...availableMinutes) })
  const setDateValue = (date, prevState = state) => setState({ ...prevState, date: date, string: formatDate(date) })
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
    setState({ ...state, string: event.target.value })
    let parsedValue = parse(event.target.value, 'dd.MM.yyyy', new Date())
    if (!isValid(parsedValue)) return

    parsedValue = setHours(parsedValue, state.hours)
    parsedValue = setMinutes(parsedValue, state.minutes)
    setDateValue(parsedValue, state)
  }

  const disableCallback = date => !state.showModal || date <= new Date()
  const classNameCallback = date => isSameDay(date, state.date) && ['bg-primary', 'text-white']

  return (
    <Form.Group disabled={disabled}>
      <input type="hidden" name={name} value={state.date && formatISO(state.date) || ""} />
      <Form.Label className={required && "required"}>{label}</Form.Label>
      <Row>
        <Col>
          <InputGroup>
            <Form.Control disabled={disabled} value={state.string} onChange={handleDateChange} required={required} />
            <InputGroup.Append>
              <Button variant="primary" onClick={handleShow} disabled={disabled}><i className="fa fa-calendar"></i></Button>
            </InputGroup.Append>
          </InputGroup>
        </Col>
        <Col sm={4} className="pt-3 pt-md-0 pt-lg-0 pt-xl-0 pt-sm-0">
          <Form.Control value={state.hours} className="d-inline-block w-auto" onChange={handleHourChange} disabled={disabled} required={required} as="select">
            {allHours.map(hour => <option disabled={!availableHours.includes(hour)} key={hour} value={hour}>{hour.toString().padStart(2, '0')}</option>)}
          </Form.Control> : 
          <Form.Control value={state.minutes} className="d-inline-block w-auto" onChange={handleMinuteChange} disabled={disabled} required={required} as="select">
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
    </Form.Group>
  )
}

export default CalendarInput