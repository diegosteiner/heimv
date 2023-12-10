import { bool, string } from "prop-types";
import * as React from "react";
import { useCallback, useContext, useState } from "react";
import { InputGroup, Form, Button, Modal, Row, Col } from "react-bootstrap";
import Calendar, { ViewType } from "../calendar/Calendar";
import OccupancyIntervalCalendar from "./OccupancyIntervalCalendar";
import { formatISOorUndefined, parseISOorUndefined } from "../../services/date";
import { Booking } from "../../models/Booking";
import { getHours, getMinutes, setHours, setMinutes } from "date-fns";
import { DateInterval } from "../../types";

export const availableMinutes = [0, 15, 30, 45];
export const availableHours = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23];

const formatDate = new Intl.DateTimeFormat("de-CH", {
  year: "numeric",
  month: "2-digit",
  day: "2-digit",
}).format;

function toControlDateValue(date: Date | undefined, hours?: number, minutes?: number): ControlDateValue {
  hours = closestNumber(hours || (date && getHours(date)) || 0, availableHours);
  minutes = closestNumber(minutes || (date && getMinutes(date)) || 0, availableMinutes);

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

const closestNumber = (n: number, range: number[]) => {
  return range.includes(n) ? n : range.reduce((a, b) => (Math.abs(b - n) < Math.abs(a - n) ? b : a));
};

type ControlDateValue = {
  date?: Date;
  hours: number;
  minutes: number;
  text: string;
};

type ControlState = {
  beginsAt: ControlDateValue;
  endsAt: ControlDateValue;
};

// interface CalendarInputProps {
//   value: string | Date;
//   name?: string;
//   id?: string;
//   required?: boolean;
//   disabled?: boolean;
//   onChange?(value: Date): void;
//   onBlur?(): void;
//   isInvalid?: boolean;
//   className?: string;
//   occupancyWindow?: OccupancyWindow;
//   minDate?: Date;
//   maxDate?: Date;
//   availableHours?: number[] | string;
//   calendarUrl?: string;
// }

interface OccupancyIntervalFormControlProps {
  booking?: Booking;
}

export function OccupancyIntervalFormControl({ booking }: OccupancyIntervalFormControlProps) {
  const [showModal, setShowModal] = useState(false);
  const [controlState, setControlState] = useState<ControlState>({
    beginsAt: toControlDateValue(booking?.begins_at),
    endsAt: toControlDateValue(booking?.ends_at),
  });

  const setControlStateFromModal = ({ start, end }: DateInterval) => {
    if (start && end) setShowModal(false);
    setControlState((prev) => ({
      beginsAt: toControlDateValue(start, prev.beginsAt.hours, prev.beginsAt.minutes),
      endsAt: toControlDateValue(end, prev.endsAt.hours, prev.endsAt.minutes),
    }));
  };

  const setControlStateFromText = ({ start, end }: { start?: string; end?: string }) => {
    setControlState((prev) => ({
      beginsAt: toControlDateValue(
        start ? parseISOorUndefined(start) : prev.beginsAt.date,
        prev.beginsAt.hours,
        prev.beginsAt.minutes,
      ),
      endsAt: toControlDateValue(
        end ? parseISOorUndefined(end) : prev.endsAt.date,
        prev.endsAt.hours,
        prev.endsAt.minutes,
      ),
    }));
  };

  return (
    <>
      <InputGroup>
        <Form.Control
          value={controlState.beginsAt.text}
          onChange={(event) => setControlStateFromText({ start: event.currentTarget.value })}
        />
        <Form.Select value={controlState.beginsAt.hours}></Form.Select>
        <InputGroup.Text> – </InputGroup.Text>
        <Form.Control
          value={controlState.endsAt.text}
          onChange={(event) => setControlStateFromText({ end: event.currentTarget.value })}
        />
        <Button onClick={() => setShowModal((prev) => !prev)}>
          <i className="fa fa-calendar"></i>
        </Button>
      </InputGroup>
      <Modal size="lg" show={showModal} onHide={() => setShowModal(false)}>
        <Modal.Body>
          <OccupancyIntervalCalendar
            beginsAtString={formatISOorUndefined(controlState.beginsAt.date)}
            endsAtString={formatISOorUndefined(controlState.endsAt.date)}
            onChange={setControlStateFromModal}
          ></OccupancyIntervalCalendar>
        </Modal.Body>
      </Modal>
    </>
  );
}
