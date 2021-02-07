import * as React from 'react';
import { InputGroup, Form, Button, Modal, Row, Col } from 'react-bootstrap';
import { OccupancyCalendarDay } from './OccupancyCalendar';
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

const initializeValue = (value: string | null): Date | null => {
  const dateValue = parseISO(value || '');
  if (!isValid(dateValue)) return null;
  if (dateValue && getHours(dateValue) < Math.min(...availableHours))
    return setHours(dateValue, Math.min(...availableHours));
  if (dateValue && getHours(dateValue) > Math.max(...availableHours))
    return setHours(dateValue, Math.max(...availableHours));
  return dateValue;
};

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
  required?: boolean;
  disabled?: boolean;
  onChange?(value: Date): void;
  onBlur?(): void;
  isInvalid?: boolean;
}

const CalendarControl: React.FC<CalendarControlProps> = ({
  value = '',
  name,
  required = false,
  disabled = false,
  onChange,
  onBlur,
  isInvalid = false,
}) => {
  const initializedValue = initializeValue(value);
  const [showModal, setShowModal] = React.useState<boolean>(false);
  const [dateState, setDateState] = React.useState<Date | null>(initializedValue);
  const [hourState, setHourState] = React.useState(
    (initializedValue && getHours(initializedValue)) || Math.min(...availableHours),
  );
  const [minuteState, setMinuteState] = React.useState<number>(
    (initializedValue && closestMinutes(getMinutes(initializedValue))) || Math.min(...availableMinutes),
  );
  const [textState, setTextState] = React.useState<string>((initializedValue && formatDate(initializedValue)) || '');

  const setDateValue = ({ date, hours, minutes }: { date?: Date; hours?: number; minutes?: number }) => {
    let dateValue = date || dateState;
    if (!dateValue) return;

    dateValue = setHours(dateValue, hours || hourState);
    dateValue = setMinutes(dateValue, minutes || minuteState);
    setDateState(dateValue);
    setHourState(hours || getHours(dateValue));
    setMinuteState(minutes || getMinutes(dateValue));
    setTextState(formatDate(dateValue));
    onChange && onChange(dateValue);
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
    const parsedValue = parse(value, 'dd.MM.yyyy', new Date());
    if (isValid(parsedValue)) {
      setDateValue({ date: parsedValue });
    } else {
      setTextState((dateState && formatDate(dateState)) || value);
    }
    onBlur && onBlur();
  };

  const disableCallback = (date: Date) => !showModal || date <= new Date();
  const classNameCallback = (date: Date) =>
    (dateState && isSameDay(date, dateState) && ['bg-primary', 'text-white']) || [];

  return (
    <div className={(isInvalid && 'is-invalid') || ''}>
      <input type="hidden" name={name} value={(dateState && formatISO(dateState)) || ''} />
      <Row>
        <Col>
          <InputGroup>
            <Form.Control
              onBlur={handleTextChange}
              disabled={disabled}
              value={textState}
              onChange={(e: React.ChangeEvent) => setTextState((e.target as HTMLInputElement).value)}
              isInvalid={isInvalid}
              required={required}
            />
            <InputGroup.Append>
              <Button variant="primary" onClick={handleShow} disabled={disabled}>
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
            onChange={(e: React.ChangeEvent) => setHourValue((e.target as HTMLInputElement).value)}
            isInvalid={isInvalid}
            disabled={disabled}
            required={required}
            as="select"
          >
            {allHours.map((hour) => (
              <option disabled={!availableHours.includes(hour)} key={hour} value={hour}>
                {hour.toString().padStart(2, '0')}
              </option>
            ))}
          </Form.Control>
          <Form.Control
            value={minuteState}
            onBlur={onBlur}
            className="d-inline-block w-auto"
            onChange={(e: React.ChangeEvent) => setMinuteValue((e.target as HTMLInputElement).value)}
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

interface CalendarInputProps {
  value: string;
  name: string;
  label?: string;
  required?: boolean;
  disabled?: boolean;
}

const CalendarInput: React.FC<CalendarInputProps> = ({ value, name, label, required = false, disabled = false }) => {
  return (
    <Form.Group disabled={disabled}>
      {label && <Form.Label className={required && 'required'}>{label}</Form.Label>}
      <CalendarControl value={value} name={name} required={required}></CalendarControl>
    </Form.Group>
  );
};

export default CalendarInput;
