import * as React from "react";
import { InputGroup, Form, Button, Modal, Row, Col } from "react-bootstrap";
import { OccupancyCalendarDay } from "./OccupancyCalendar";
import Calendar from "./Calendar";
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
} from "date-fns/esm";
import { Occupancy } from "../../models/Occupancy";

const formatDate = new Intl.DateTimeFormat("de-CH", {
  year: "numeric",
  month: "2-digit",
  day: "2-digit",
}).format;

function initializeValue(value: string | null): Date | null {
  const dateValue = parseISO(value || "");
  if (!isValid(dateValue)) return null;
  if (dateValue && getHours(dateValue) < Math.min(...availableHours))
    return setHours(dateValue, Math.min(...availableHours));
  if (dateValue && getHours(dateValue) > Math.max(...availableHours))
    return setHours(dateValue, Math.max(...availableHours));
  return dateValue;
}

function dateToCalendarControlValue(date: Date | null): CalendarControlValue {
  return {
    date: date,
    hours: (date && getHours(date)) || Math.min(...availableHours),
    minutes: (date && closestMinutes(getMinutes(date))) || Math.min(...availableMinutes),
    text: (date && formatDate(date)) || "",
  };
}

const availableHours = [8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22];
const allHours = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24];
const availableMinutes = [0, 15, 30, 45];

const clamp = (value: number, min: number, max: number) => (value > max ? max : value < min ? min : value);
const closestMinutes = (minutes: number) => {
  return availableMinutes.reduce((a, b) => (Math.abs(b - minutes) < Math.abs(a - minutes) ? b : a));
};

interface CalendarControlProps {
  value: string;
  name?: string;
  id?: string;
  required?: boolean;
  disabled?: boolean;
  onChange?(value: Date): void;
  onBlur?(): void;
  isInvalid?: boolean;
  invalidFeedback?: string;
}

type CalendarControlValue = {
  date: Date | null;
  hours: number;
  minutes: number;
  text: string;
};

export const CalendarControl: React.FC<CalendarControlProps> = ({
  value = "",
  name,
  id,
  required = false,
  disabled = false,
  onChange,
  onBlur,
  invalidFeedback,
  isInvalid = !!invalidFeedback,
}) => {
  const [showModal, setShowModal] = React.useState<boolean>(false);
  const [inputValue, setInputValue] = React.useState<CalendarControlValue>(() =>
    dateToCalendarControlValue(initializeValue(value))
  );

  const setDateValue = ({ date, hours, minutes }: { date?: Date; hours?: number; minutes?: number }) => {
    let value = date || inputValue.date;
    if (!value) return;

    value = setHours(value, hours !== undefined ? hours : inputValue.hours);
    value = setMinutes(value, minutes !== undefined ? minutes : inputValue.minutes);
    // console.log(`input[${name}]: ${value.toString()}`);
    setInputValue(dateToCalendarControlValue(value));
    onChange && onChange(value);
  };

  const setHourValue = (value: string) => {
    setDateValue({
      hours: clamp(parseInt(value), Math.min(...availableHours), Math.max(...availableHours)),
    });
  };

  const setMinuteValue = (value: string) =>
    setDateValue({
      minutes: clamp(parseInt(value), Math.min(...availableMinutes), Math.max(...availableMinutes)),
    });

  const handleClose = () => setShowModal(false);
  const handleShow = () => setShowModal(true);
  const handleClick = (event: React.MouseEvent) => {
    if (disabled) return;

    const parsedValue = parseISO((event.target as HTMLInputElement).value);
    if (!isValid(parsedValue)) return;

    setDateValue({ date: parsedValue });
    setShowModal(false);
  };

  const handleTextChange = (event: React.ChangeEvent) => {
    if (disabled) return;

    const value = (event.target as HTMLInputElement).value;
    const parsedValue = parse(value, "dd.MM.yyyy", new Date());
    if (isValid(parsedValue)) {
      setDateValue({ date: parsedValue });
    } else {
      setInputValue((prev) => ({
        ...prev,
        text: (inputValue.date && formatDate(inputValue.date)) || value,
      }));
    }
    onBlur && onBlur();
  };

  const disableCallback = (date: Date, _occupancies: Set<Occupancy>) => !showModal || date <= new Date();
  const classNameCallback = (date: Date, _occupancies: Set<Occupancy>) =>
    (inputValue.date && isSameDay(date, inputValue.date) && "bg-primary text-white") || "";

  return (
    <>
      <div id={id} className={(isInvalid && "is-invalid") || ""}>
        <input type="hidden" name={name} value={(inputValue.date && formatISO(inputValue.date)) || ""} />
        <Row>
          <Col>
            <InputGroup hasValidation>
              <Form.Control
                id={`${id}_date`}
                onBlur={handleTextChange}
                disabled={disabled}
                value={inputValue.text}
                onChange={(e: React.ChangeEvent) => {
                  const value = (e.target as HTMLInputElement).value;
                  setInputValue((prev) => ({ ...prev, text: value }));
                }}
                isInvalid={isInvalid}
                required={required}
              />
              <Button variant="primary" onClick={handleShow} disabled={disabled}>
                <i className="fa fa-calendar"></i>
              </Button>
            </InputGroup>
          </Col>
          <Col sm={6} className="d-flex">
            <Form.Control
              value={inputValue.hours}
              onBlur={onBlur}
              className="d-inline-block w-auto"
              onChange={(e: React.ChangeEvent) => setHourValue((e.target as HTMLInputElement).value)}
              isInvalid={isInvalid}
              disabled={disabled}
              required={required}
              as="select"
              id={`${id}_hours`}
            >
              {allHours.map((hour) => (
                <option disabled={!availableHours.includes(hour)} key={hour} value={hour}>
                  {hour.toString().padStart(2, "0")}
                </option>
              ))}
            </Form.Control>
            <Form.Control
              value={inputValue.minutes}
              onBlur={onBlur}
              className="d-inline-block w-auto"
              onChange={(e: React.ChangeEvent) => setMinuteValue((e.target as HTMLInputElement).value)}
              isInvalid={isInvalid}
              disabled={disabled}
              required={required}
              as="select"
              id={`${id}_minutes`}
            >
              {availableMinutes.map((minutes) => (
                <option key={minutes} value={minutes}>
                  {minutes.toString().padStart(2, "0")}
                </option>
              ))}
            </Form.Control>
          </Col>
        </Row>
        <Modal size="lg" show={showModal} onHide={handleClose}>
          <Modal.Body>
            <Calendar start={formatISO(inputValue.date || new Date())}>
              <OccupancyCalendarDay
                onClick={handleClick}
                classNames={classNameCallback}
                disabled={disableCallback}
              ></OccupancyCalendarDay>
            </Calendar>
          </Modal.Body>
        </Modal>
      </div>
      {<Form.Control.Feedback type="invalid">{invalidFeedback}</Form.Control.Feedback>}
    </>
  );
};

interface CalendarInputProps {
  value: string;
  name: string;
  id?: string;
  label?: string;
  required?: boolean;
  disabled?: boolean;
  isInvalid?: boolean;
  invalidFeedback?: string;
}

const CalendarInput: React.FC<CalendarInputProps> = ({
  value,
  name,
  id,
  label,
  required = false,
  disabled = false,
  invalidFeedback,
  isInvalid = !!invalidFeedback,
}) => {
  return (
    <Form.Group className="mb-3">
      {label && <Form.Label className={required ? "required" : ""}>{label}</Form.Label>}
      <CalendarControl
        disabled={disabled}
        value={value}
        name={name}
        id={id}
        required={required}
        isInvalid={isInvalid}
        invalidFeedback={invalidFeedback}
      ></CalendarControl>
    </Form.Group>
  );
};

export default CalendarInput;
