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

const availableHours = [8, 9, 10, 11, 12, 13, 14, 15, 16, 18, 19, 20, 21, 22]
const allHours = [...new Array(23).keys()]
const availableMinutes = [0, 15, 30, 45]
const clamp = (value, min, max) => value > max ? max : value < min ? min : value

const CalendarInput = ({ value = "", name, label, required = false, disabled = false }) => {
  value = value && parseISO(value)
  if(getHours(value) < Math.min(...availableHours)) value = setHours(value, Math.min(...availableHours));
  if(getHours(value) > Math.max(...availableHours)) value = setHours(value, Math.max(...availableHours));
  const [showModal, setShowModal] = useState(false)
  const [dateValue, setDateValue] = useState(value)
  const [stringValue, setStringValue] = useState(value && formatDate(value) || "");
  const setHourValue = hourValue => setDateValue(setHours(dateValue, clamp(parseInt(hourValue), Math.min(...availableHours), Math.max(...availableHours))))
  const setMinuteValue = minuteValue => setDateValue(setMinutes(minuteValue, clamp(parseInt(minuteValue), Math.min(...availableMinutes), Math.max(...availableMinutes))))

  const handleClose = () => setShowModal(false);
  const handleShow = () => setShowModal(true);
  const handleClick = event => {
    if (disabled) return
    const parsedValue = parseISO(event.target.value)
    if (!isValid(parsedValue)) return

    setShowModal(false)
    setDateValue(parsedValue)
    setStringValue(formatDate(parsedValue))
  }
  const handleHourChange = event => setHourValue(event.target.value)
  const handleMinuteChange = event => setMinuteValue(event.target.value)
  const handleDateChange = event => {
    if (disabled) return
    setStringValue(event.target.value)
    const parsedValue = parse(event.target.value, 'dd.MM.yyyy', new Date())
    if (!isValid(parsedValue)) return
    setDateValue(setHours(setMinutes(parsedValue, getMinutes(dateValue)), getHours(dateValue)))
  }

  const disableCallback = date => !showModal || date <= new Date()
  const classNameCallback = date => isSameDay(date, dateValue) && ['bg-primary', 'text-white']

  return (
    <Form.Group disabled={disabled}>
      <input type="hidden" name={name} value={dateValue && formatISO(dateValue) || ""} />
      <Form.Label className={required && "required"}>{label}</Form.Label>
      <Row>
        <Col>
          <InputGroup>
            <Form.Control disabled={disabled} value={stringValue} onChange={handleDateChange} required={required} />
            <InputGroup.Append>
              <Button variant="primary" onClick={handleShow} disabled={disabled}><i className="fa fa-calendar"></i></Button>
            </InputGroup.Append>
          </InputGroup>
        </Col>
        <Col sm={4} className="pt-3 pt-md-0 pt-lg-0 pt-xl-0 pt-sm-0">
          <Form.Control value={getHours(dateValue)} className="d-inline-block w-auto" onChange={handleHourChange} disabled={disabled} required={required} as="select">
            {allHours.map(hour => <option disabled={!availableHours.includes(hour)} key={hour} value={hour}>{hour.toString().padStart(2, '0')}</option>)}
          </Form.Control> : 
          <Form.Control className="d-inline-block w-auto" onChange={handleMinuteChange} disabled={disabled} required={required} as="select">
            {availableMinutes.map(minutes => <option key={minutes} value={minutes}>{minutes.toString().padStart(2, '0')}</option>)}
          </Form.Control>
        </Col>
      </Row>
      <Modal size='lg' show={showModal} onHide={handleClose}>
        <Modal.Body>
          <Calendar firstMonth={dateValue || new Date()}>
            <OccupancyCalendarDay onClick={handleClick} classNameCallback={classNameCallback} disableCallback={disableCallback}></OccupancyCalendarDay>
          </Calendar>
        </Modal.Body>
      </Modal>
    </Form.Group>
  )
}

export default CalendarInput