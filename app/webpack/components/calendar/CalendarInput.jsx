import React, { useState } from 'react'
import { InputGroup, Form, Button, Modal } from 'react-bootstrap'
import { OccupancyCalendarDay } from './OccupancyCalendarDay'
import Calendar from './Calendar'
import { formatISO, parseISO, parse, isValid } from 'date-fns/esm'

const formatDate = new Intl.DateTimeFormat("de-CH", {
  year: "numeric",
  month: "2-digit",
  day: "2-digit"
}).format

const CalendarInput = ({ value = "", name, label, required = false }) => {
  value = value && parseISO(value)
  const [showModal, setShowModal] = useState(false)
  const [dateValue, setDateValue] = useState(value)
  const [stringValue, setStringValue] = useState(value && formatDate(value) || "");

  const handleClose = () => setShowModal(false);
  const handleShow = () => setShowModal(true);
  const handleClick = event => {
    const parsedValue = parseISO(event.target.value)
    if (!isValid(parsedValue)) return

    setDateValue(parsedValue)
    setStringValue(formatDate(parsedValue))
    setShowModal(false)
  }
  const handleChange = event => {
    setStringValue(event.target.value)
    const parsedValue = parse(event.target.value, 'dd.MM.yyyy', new Date())
    if (!isValid(parsedValue)) return

    setDateValue(parsedValue)
  }
  const disableCallback = date => {
    return date <= new Date()
  }

  return (
    <Form.Group>
      <input type="hidden" name={name} value={dateValue && formatISO(dateValue) || ""} />
      <Form.Label className={required && "required"}>{label}</Form.Label>
      <InputGroup>
        <Form.Control value={stringValue} onChange={handleChange} required={required} />
        <InputGroup.Append>
          <Button variant="primary" onClick={handleShow}><i className="fa fa-calendar"></i></Button>
        </InputGroup.Append>
      </InputGroup>

      <Modal size='lg' show={showModal} onHide={handleClose}>
        <Modal.Body>
          <Calendar firstMonth={dateValue || new Date()}>
            <OccupancyCalendarDay onClick={handleClick} disableCallback={disableCallback}></OccupancyCalendarDay>
          </Calendar>
        </Modal.Body>
      </Modal>
    </Form.Group>
  )
}

export default CalendarInput