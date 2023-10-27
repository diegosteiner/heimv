import { bool } from "prop-types";
import * as React from "react";
import { useCallback, useContext, useState } from "react";
import { InputGroup, Form, Button, Modal, Row, Col } from "react-bootstrap";
import { OccupancyWindowContext, OccupancyWindowProvider } from "./OccupancyWindowContext";
import { CalendarDate, DateElementFactory } from "../calendar/CalendarDate";
import parseISO from "date-fns/parseISO";
import { DateWithOccupancies } from "./DateWithOccupancies";
import Calendar, { ViewType } from "../calendar/Calendar";

const formatDate = new Intl.DateTimeFormat("de-CH", {
  year: "numeric",
  month: "2-digit",
  day: "2-digit",
}).format;

// function valueAsDate(value: string | Date): Date | undefined {
//   if (!value) return;
//   if (value instanceof Date && isValid(value)) return value;
//   const dateValue = parseISO((value as string) || "");
//   if (!isValid(dateValue)) return;
//   return dateValue;
// }

// function dateToCalendarControlValue(
//   date: Date,
//   availableHours: number[],
//   availableMinutes: number[],
// ): CalendarControlValue {
//   const hours = closestNumber((date && getHours(date)) || 0, availableHours);
//   const minutes = closestNumber((date && getMinutes(date)) || 0, availableMinutes);

//   if (date) {
//     date = setHours(date, hours);
//     date = setMinutes(date, minutes);
//   }

//   return {
//     date: date,
//     hours: hours,
//     minutes: minutes,
//     text: (date && formatDate(date)) || "",
//   };
// }

// export const availableMinutes = [0, 15, 30, 45];

const closestNumber = (n: number, range: number[]) => {
  return range.includes(n) ? n : range.reduce((a, b) => (Math.abs(b - n) < Math.abs(a - n) ? b : a));
};

// type CalendarControlValue = {
//   date?: Date;
//   hours: number;
//   minutes: number;
//   text: string;
// };

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

type OccupancyFormControlProps = {
  calendarUrl: string;
};

export function OccupancyFormControl({ calendarUrl }: OccupancyFormControlProps) {
  const [showModal, setShowModal] = useState(false);

  return (
    <OccupancyWindowProvider url={calendarUrl}>
      <Button onClick={() => setShowModal((prev) => !prev)}></Button>
      <Modal size="lg" show={showModal} onHide={() => setShowModal(false)}>
        <Modal.Body>
          <OccupancyPickCalendar defaultView="months"></OccupancyPickCalendar>
        </Modal.Body>
      </Modal>
    </OccupancyWindowProvider>
  );
}

type OccupancyPickCalendarProps = {
  start?: string;
  defaultView: ViewType;
};

function OccupancyPickCalendar({ start, defaultView }: OccupancyPickCalendarProps) {
  const occupancyWindow = useContext(OccupancyWindowContext);

  const initialFirstDate = start;

  // const disabledCallback = useCallback(
  //   (date: Date) => !occupancyWindow || isBefore(date, occupancyWindow.start) || isAfter(date, occupancyWindow.end),
  //   [occupancyWindow],
  // );

  const dateElementFactory: DateElementFactory = useCallback(
    (dateString: string, labelCallback: (date: Date) => string) => {
      const date = parseISO(dateString);
      const disabled = false; // !occupancyAtUrl || disabledCallback(date);
      // const href = occupancyAtUrl?.replace("__DATE__", dateString);

      return (
        <CalendarDate dateString={dateString}>
          <button className="date-action" aria-disabled={disabled}>
            <DateWithOccupancies
              dateString={dateString}
              label={labelCallback(date)}
              occupancyWindow={occupancyWindow}
            ></DateWithOccupancies>
          </button>
        </CalendarDate>
      );
    },
    [occupancyWindow],
  );

  return (
    <Calendar
      initialFirstDate={initialFirstDate}
      defaultView={defaultView}
      dateElementFactory={dateElementFactory}
    ></Calendar>
  );
}
