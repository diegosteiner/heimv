import * as React from "react";
import { InputGroup, Form, Button, Modal, Row, Col } from "react-bootstrap";
import { OccupancyWindow } from "../../models/OccupancyWindow";
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
  isAfter,
  isBefore,
  addYears,
} from "date-fns/esm";
import CalendarWithOccupancies from "./CalendarWithOccupancies";
import { getYear } from "date-fns";

export type HourRange = number[] | string;

const formatDate = new Intl.DateTimeFormat("de-CH", {
  year: "numeric",
  month: "2-digit",
  day: "2-digit",
}).format;

function valueAsDate(value: string | Date): Date | undefined {
  if (!value) return;
  if (value instanceof Date && isValid(value)) return value;
  const dateValue = parseISO((value as string) || "");
  if (!isValid(dateValue)) return;
  return dateValue;
}

function dateToCalendarControlValue(
  date: Date,
  availableHours: number[],
  availableMinutes: number[]
): CalendarControlValue {
  const hours = closestNumber((date && getHours(date)) || 0, availableHours);
  const minutes = closestNumber(
    (date && getMinutes(date)) || 0,
    availableMinutes
  );

  if (date) {
    date = setHours(date, hours);
    date = setMinutes(date, minutes);
  }

  return {
    date: date,
    hours: hours,
    minutes: minutes,
    text: (date && formatDate(date)) || "",
  };
}

export const availableMinutes = [0, 15, 30, 45];

const closestNumber = (n: number, range: number[]) => {
  return range.reduce((a, b) => (Math.abs(b - n) < Math.abs(a - n) ? b : a));
};

// function range(start: number, end: number) {
//   return [...Array(Math.abs(end - start))].map((_, i) => start + i)
// }

// function parseHourRange(value: string | number[] | undefined): number[]  {
//   if (value === undefined) return range(8, 21)
//   if (typeof value !== 'string') return value

//   const fromToMatch = Array.from(value.matchAll(new RegExp('(\d+)\s*-\s*(\d+)')), match => match[1])
//   if(fromToMatch) return range(parseInt(fromToMatch[0]) ?? 0, parseInt(fromToMatch[1]) ?? 0)

//   const  = Array.from(value.matchAll(new RegExp('(\d+)\s*-\s*(\d+)')), match => match[1])
//   if(fromToMatch) return range(parseInt(fromToMatch[0]) ?? 0, parseInt(fromToMatch[1]) ?? 0)

//   return
// }

type CalendarControlValue = {
  date?: Date;
  hours: number;
  minutes: number;
  text: string;
};

interface CalendarControlProps {
  value: string | Date;
  name?: string;
  id?: string;
  required?: boolean;
  disabled?: boolean;
  onChange?(value: Date): void;
  onBlur?(): void;
  isInvalid?: boolean;
  className?: string;
  occupancyWindow?: OccupancyWindow;
  minDate?: Date;
  maxDate?: Date;
  availableHours?: number[] | string;
}

export default function OccupancyDateTimeFormControl({
  value = "",
  name,
  id,
  required = false,
  disabled = false,
  onChange,
  onBlur,
  isInvalid = false,
  minDate,
  maxDate,
}: CalendarControlProps) {
  const availableHours = [...Array(23)].map((_, i) => 0 + i);
  const [showModal, setShowModal] = React.useState<boolean>(false);
  const [calendarControlValue, setCalendarControlValue] =
    React.useState<CalendarControlValue>({
      hours: Math.min(...availableHours),
      minutes: Math.min(...availableMinutes),
      text: "",
    });

  React.useEffect(() => {
    const dateValue = valueAsDate(value);
    if (
      dateValue &&
      dateValue.toISOString() != calendarControlValue.date?.toISOString()
    )
      setDateValue(
        dateToCalendarControlValue(dateValue, availableHours, availableMinutes)
      );
  }, [value, onChange]);

  const setDateValue = ({
    date,
    hours,
    minutes,
  }: Partial<CalendarControlValue>) => {
    date = date || calendarControlValue?.date;
    if (!date || !isValid(date)) return;

    date = setHours(
      date,
      hours || calendarControlValue?.hours || Math.min(...availableHours)
    );
    date = setMinutes(
      date,
      minutes || calendarControlValue?.minutes || Math.min(...availableMinutes)
    );
    setCalendarControlValue(
      dateToCalendarControlValue(date, availableHours, availableMinutes)
    );
    onChange && onChange(date);
    return date;
  };

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
    let parsedValue = parse(value, "dd.MM.yyyy", new Date());
    if (getYear(parsedValue) < 100) parsedValue = addYears(parsedValue, 2000);
    if (!setDateValue({ date: parsedValue })) {
      setCalendarControlValue((prev) => ({
        ...prev,
        text:
          (calendarControlValue?.date &&
            formatDate(calendarControlValue.date)) ||
          value,
      }));
    }
    onBlur && onBlur();
  };

  const classNameCallback = (date: Date) =>
    calendarControlValue?.date && isSameDay(date, calendarControlValue.date)
      ? "bg-primary text-white"
      : "";

  const disabledCallback = (date: Date) =>
    (minDate && isBefore(date, minDate)) ||
    (maxDate && isAfter(date, maxDate)) ||
    false;

  return (
    <div id={id} className={(!!isInvalid && "is-invalid") || ""}>
      <input
        type="hidden"
        name={name}
        value={
          (calendarControlValue.date && formatISO(calendarControlValue.date)) ||
          ""
        }
      />
      <Row>
        <Col>
          <InputGroup hasValidation>
            <Form.Control
              id={`${id}_date`}
              onBlur={handleTextChange}
              disabled={disabled}
              value={calendarControlValue.text}
              onChange={(e: React.ChangeEvent) => {
                const value = (e.target as HTMLInputElement).value;
                setCalendarControlValue((prev) => ({ ...prev, text: value }));
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
            value={calendarControlValue.hours}
            onBlur={onBlur}
            className="d-inline-block w-auto"
            onChange={(e: React.ChangeEvent) =>
              setDateValue({
                hours: closestNumber(
                  parseInt((e.target as HTMLInputElement).value),
                  availableHours
                ),
              })
            }
            isInvalid={isInvalid}
            disabled={disabled || !isValid(calendarControlValue.date)}
            required={required}
            as="select"
            id={`${id}_hours`}
          >
            {availableHours.map((hour) => (
              <option key={hour} value={hour}>
                {hour.toString().padStart(2, "0")}
              </option>
            ))}
          </Form.Control>
          <Form.Control
            value={calendarControlValue.minutes}
            onBlur={onBlur}
            className="d-inline-block w-auto"
            onChange={(e: React.ChangeEvent) =>
              setDateValue({
                minutes: closestNumber(
                  parseInt((e.target as HTMLInputElement).value),
                  availableMinutes
                ),
              })
            }
            isInvalid={isInvalid}
            disabled={disabled || !isValid(calendarControlValue.date)}
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
          <CalendarWithOccupancies
            start={formatISO(calendarControlValue.date || new Date())}
            onClick={handleClick}
            classNamesCallback={classNameCallback}
            disabledCallback={disabledCallback}
          ></CalendarWithOccupancies>
        </Modal.Body>
      </Modal>
    </div>
  );
}
