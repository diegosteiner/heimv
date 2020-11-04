import React, { useState } from 'react';
import { InputGroup, Form, Button, Modal, Row, Col } from 'react-bootstrap';
import { OccupancyCalendarDay } from './OccupancyCalendarDay';
import Calendar from './Calendar';
import {
  formatISO,
  parseISO,
  parse,
  isSameDay,
  isValid,
  setHours,
  setMinutes,
  getHours,
  getMinutes,
} from 'date-fns/esm';

const formatDate = new Intl.DateTimeFormat('de-CH', {
  year: 'numeric',
  month: '2-digit',
  day: '2-digit',
}).format;


const initializeValue = (value) => {
  if (isValid(value)) return value;
  value = parseISO(value);
  if (!isValid(value)) return null;
  if (value && getHours(value) < Math.min(...availableHours))
    return setHours(value, Math.min(...availableHours));
  if (value && getHours(value) > Math.max(...availableHours))
    return setHours(value, Math.max(...availableHours));
  return value;
};

const availableHours = [
  8,
  9,
  10,
  11,
  12,
  13,
  14,
  15,
  16,
  17,
  18,
  19,
  20,
  21,
  22,
];
const allHours = [...new Array(23).keys()];
const availableMinutes = [0, 15, 30, 45];
const clamp = (value, min, max) =>
  value > max ? max : value < min ? min : value;
const closestMinutes = (minutes) => {
  return availableMinutes.reduce((a, b) =>
    Math.abs(b - minutes) < Math.abs(a - minutes) ? b : a,
  );
};

const CalendarControl = ({
  value = '',
  name,
  required = false,
  disabled = false,
  onChange,
  onBlur,
  isInvalid,
}) => {
  value = initializeValue(value)
  const [showModal, setShowModal] = useState(false)
  const [dateState, setDateState] = useState(value)
  const [hourState, setHourState] = useState(getHours(value) || Math.min(...availableHours))
  const [minuteState, setMinuteState] = useState(closestMinutes(getMinutes(value)) || Math.min(...availableMinutes))
  const [textState, setTextState] = useState(value && formatDate(value))

  const setDateValue = ({ date, hours, minutes }) => {
    date = date || dateState
    date = setHours(date, hours || hourState)
    date = setMinutes(date, minutes || minuteState)
    setDateState(date);
    setHourState(hours || getHours(date))
    setMinuteState(minutes || getMinutes(date))
    setTextState(formatDate(date))
    onChange && onChange(date);
  };

  const setHourValue = (value) => {
    setDateValue({
      hours: clamp(
        parseInt(value),
        Math.min(...availableHours),
        Math.max(...availableHours),
      )
    });
  }

  const setMinuteValue = (value) =>
    setDateValue({
      minutes: clamp(
        parseInt(value),
        Math.min(...availableMinutes),
        Math.max(...availableMinutes),
      ),
    });

  const handleClose = () => setShowModal(false);
  const handleShow = () => setShowModal(true);
  const handleClick = (event) => {
    if (disabled) return;

    const parsedValue = parseISO(event.target.value);
    if (!isValid(parsedValue)) return;

    setDateValue({ date: parsedValue });
    setShowModal(false)
  };

  const handleTextChange = (event) => {
    if (disabled) return;

    const parsedValue = parse(event.target.value, 'dd.MM.yyyy', new Date());
    if (isValid(parsedValue)) {
      setDateValue({ date: parsedValue })
    } else {
      setTextState(formatDate(dateState))
    }
    onBlur && onBlur()
  };

  const disableCallback = (date) => !showModal || date <= new Date();
  const classNameCallback = (date) => isSameDay(date, dateState) && ['bg-primary', 'text-white'];

  return (
    <div className={isInvalid && 'is-invalid'}>
      <input
        type="hidden"
        name={name}
        value={(dateState && formatISO(dateState)) || ''}
      />
      <Row>
        <Col>
          <InputGroup>
            <Form.Control
              onBlur={handleTextChange}
              disabled={disabled}
              value={textState}
              onChange={e => setTextState(e.target.value)}
              isInvalid={isInvalid}
              required={required}
            />
            <InputGroup.Append>
              <Button
                variant="primary"
                onClick={handleShow}
                disabled={disabled}
              >
                <i className="fa fa-calendar"></i>
              </Button>
            </InputGroup.Append>
          </InputGroup>
        </Col>
        <Col sm={6} className="d-flex">
          <Form.Control
            value={hourState}
            onBlur={onBlur}
            className="d-inline-block w-auto"
            onChange={e => setHourValue(e.target.value)}
            isInvalid={isInvalid}
            disabled={disabled}
            required={required}
            as="select"
          >
            {allHours.map((hour) => (
              <option
                disabled={!availableHours.includes(hour)}
                key={hour}
                value={hour}
              >
                {hour.toString().padStart(2, '0')}
              </option>
            ))}
          </Form.Control>
          <Form.Control
            value={minuteState}
            onBlur={onBlur}
            className="d-inline-block w-auto"
            onChange={e => setMinuteValue(e.target.value)}
            isInvalid={isInvalid}
            disabled={disabled}
            required={required}
            as="select"
          >
            {availableMinutes.map((minutes) => (
              <option key={minutes} value={minutes}>
                {minutes.toString().padStart(2, '0')}
              </option>
            ))}
          </Form.Control>
        </Col>
      </Row>
      <Modal size="lg" show={showModal} onHide={handleClose}>
        <Modal.Body>
          <Calendar firstMonth={dateState || new Date()}>
            <OccupancyCalendarDay
              onClick={handleClick}
              classNameCallback={classNameCallback}
              disableCallback={disableCallback}
            ></OccupancyCalendarDay>
          </Calendar>
        </Modal.Body>
      </Modal>
    </div>
  );
};

export default CalendarControl;
