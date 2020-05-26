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

const CalendarInput = ({ value = "", name, label, required = false, disabled = false }) => {
  value = value && parseISO(value)
  const [showModal, setShowModal] = useState(false)
  const [dateValue, setDateValue] = useState(value)
  const [stringValue, setStringValue] = useState(value && formatDate(value) || "");

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
  const handleHourChange = event => setDateValue(setHours(dateValue, parseInt(event.target.value)))
  const handleMinuteChange = event => setDateValue(setMinutes(dateValue, parseInt(event.target.value)))
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
            <option value="8">08</option>
            <option value="9">09</option>
            <option value="10">10</option>
            <option value="11">11</option>
            <option value="12">12</option>
            <option value="13">13</option>
            <option value="14">14</option>
            <option value="15">15</option>
            <option value="16">16</option>
            <option value="17">17</option>
            <option value="18">18</option>
            <option value="19">19</option>
            <option value="20">20</option>
            <option value="21">21</option>
            <option value="22">22</option>
          </Form.Control> : 
          <Form.Control className="d-inline-block w-auto" onChange={handleMinuteChange} disabled={disabled} required={required} as="select">
            <option value="00">00</option>
            <option value="15">15</option>
            <option value="30">30</option>
            <option value="45">45</option>
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