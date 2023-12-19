import * as React from "react";
import { useState } from "react";
import { InputGroup, Form, Button, Modal, Row, Col } from "react-bootstrap";
import OccupancyIntervalCalendar from "./OccupancyIntervalCalendar";
import { closestNumber, formatISOorUndefined } from "../../services/date";
import { addYears, getHours, getMinutes, getYear, isValid, parse, setHours, setMinutes } from "date-fns";
import { useTranslation } from "react-i18next";
import { cx } from "@emotion/css";

export const availableMinutes = [0, 15, 30, 45];
export const availableHours = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23];
const timeOptions = availableHours.flatMap((hour) => availableMinutes.flatMap((minutes) => formatTime(hour, minutes)));

function formatTime(hour: string | number | undefined, minutes: string | number | undefined): string {
  return `${String(hour || 0).padStart(2, "0")}:${String(minutes || 0).padStart(2, "0")}`;
}
const formatDate = new Intl.DateTimeFormat("de-CH", {
  year: "numeric",
  month: "2-digit",
  day: "2-digit",
}).format;

function parseLocaleDate(value: string, format?: string): Date | undefined {
  let date = parse(value, format || "dd.MM.yyyy", new Date());
  if (!isValid(date)) return;

  if (getYear(date) < 1900) date = addYears(date, 2000);
  return date;
}

function buildControlDateValue({ date, time, text }: Partial<ControlDateValue>): ControlDateValue {
  let [hours, minutes] = time?.split(":").map((value) => parseInt(value)) || [];
  hours = closestNumber(hours ?? (date && getHours(date)) ?? 0, availableHours);
  minutes = closestNumber(minutes ?? (date && getMinutes(date)) ?? 0, availableMinutes);
  time = formatTime(hours, minutes);

  if (text) {
    date = parseLocaleDate(text);
  }

  if (date) {
    date = setHours(date, hours);
    date = setMinutes(date, minutes);
    text = formatDate(date);
  }

  return {
    date: date,
    time: time,
    text: text || "",
  };
}

type ControlDateValue = {
  date?: Date;
  time: string;
  text: string;
};

type OccupancyIntervalFormControlProps = {
  namePrefix?: string;
  required?: boolean;
  disabled?: boolean;
  months?: number;
  initialBeginsAt?: Date;
  initialEndsAt?: Date;
  defaultBeginsAtTime?: string;
  defaultEndsAtTime?: string;
  invalidFeedback?: string | undefined;
};

export function OccupancyIntervalFormControl({
  namePrefix,
  required,
  disabled,
  months,
  initialBeginsAt,
  initialEndsAt,
  defaultBeginsAtTime,
  defaultEndsAtTime,
  invalidFeedback,
}: OccupancyIntervalFormControlProps) {
  const [showModal, setShowModal] = useState(false);
  const [beginsAt, setBeginsAt] = useState<ControlDateValue>(() =>
    buildControlDateValue({ date: initialBeginsAt, time: !initialBeginsAt ? defaultBeginsAtTime : undefined }),
  );
  const [endsAt, setEndsAt] = useState<ControlDateValue>(() =>
    buildControlDateValue({ date: initialEndsAt, time: !initialEndsAt ? defaultEndsAtTime : undefined }),
  );
  const { t } = useTranslation();

  return (
    <>
      <div className="mb-3">
        <Form.Label className={cx({ required })}>{t("activerecord.attributes.booking.begins_at")}</Form.Label>
        <Row>
          <Col sm={6}>
            <InputGroup hasValidation>
              <Form.Control
                value={beginsAt.text}
                id={`booking_begins_at_date`}
                required={required}
                disabled={disabled}
                isInvalid={!!invalidFeedback || (beginsAt.text.length > 0 && !beginsAt.date)}
                onChange={(event) => setBeginsAt((prev) => ({ ...prev, text: event.target.value }))}
                onBlur={(event) =>
                  setBeginsAt((prev) =>
                    buildControlDateValue({
                      text: event.target.value,
                      time: prev.time,
                    }),
                  )
                }
              />
              <Button onClick={() => setShowModal((prev) => !prev)}>
                <i className="fa fa-calendar"></i>
              </Button>
            </InputGroup>
          </Col>
          <Col sm={3}>
            <Form.Select
              value={beginsAt.time}
              id={`booking_begins_at_time`}
              required={required}
              disabled={disabled}
              isInvalid={!!invalidFeedback}
              onChange={(event) =>
                setBeginsAt((prev) =>
                  buildControlDateValue({
                    date: prev.date,
                    time: event.target.value,
                  }),
                )
              }
            >
              <option></option>
              {timeOptions.map((timeOption) => (
                <option key={timeOption} value={timeOption}>
                  {timeOption}
                </option>
              ))}
            </Form.Select>
          </Col>
        </Row>
        <input
          type="hidden"
          disabled={disabled}
          name={`${namePrefix}[begins_at]`}
          value={formatISOorUndefined(beginsAt.date)}
        />
      </div>
      <div className="mb-3">
        <Form.Label className={cx({ required })}>{t("activerecord.attributes.booking.ends_at")}</Form.Label>
        <Row>
          <Col sm={6}>
            <InputGroup>
              <Form.Control
                value={endsAt.text}
                id={`booking_ends_at_date`}
                isInvalid={!!invalidFeedback || (endsAt.text.length > 0 && !endsAt.date)}
                onChange={(event) => setEndsAt((prev) => ({ ...prev, text: event.target.value }))}
                onBlur={(event) =>
                  setEndsAt((prev) =>
                    buildControlDateValue({
                      text: event.target.value,
                      time: prev.time,
                    }),
                  )
                }
              />
              <Button onClick={() => setShowModal((prev) => !prev)}>
                <i className="fa fa-calendar"></i>
              </Button>
            </InputGroup>
          </Col>
          <Col sm={3}>
            <Form.Select
              value={endsAt.time}
              id={`booking_ends_at_time`}
              isInvalid={!!invalidFeedback}
              onChange={(event) =>
                setEndsAt((prev) =>
                  buildControlDateValue({
                    date: prev.date,
                    time: event.target.value,
                  }),
                )
              }
            >
              <option></option>
              {timeOptions.map((timeOption) => (
                <option key={timeOption} value={timeOption}>
                  {timeOption}
                </option>
              ))}
            </Form.Select>
          </Col>
        </Row>
        <input
          type="hidden"
          disabled={disabled}
          name={`${namePrefix}[ends_at]`}
          value={formatISOorUndefined(endsAt.date)}
        />
        {invalidFeedback && <div className="invalid-feedback d-block">{invalidFeedback}</div>}
      </div>

      <Modal size="lg" show={showModal} onHide={() => setShowModal(false)}>
        <Modal.Body>
          <OccupancyIntervalCalendar
            beginsAtString={formatISOorUndefined(beginsAt.date)}
            endsAtString={formatISOorUndefined(endsAt.date)}
            months={months}
            defaultView="months"
            onChange={(value) => {
              if ("beginsAt" in value && value.beginsAt != beginsAt.date)
                setBeginsAt((prev) =>
                  buildControlDateValue({
                    date: value.beginsAt,
                    time: prev.time,
                  }),
                );

              if ("endsAt" in value && value.endsAt != endsAt.date)
                setEndsAt((prev) =>
                  buildControlDateValue({
                    date: value.endsAt,
                    time: prev.time,
                  }),
                );

              if (value.beginsAt && value.endsAt) setShowModal(false);
            }}
          ></OccupancyIntervalCalendar>
        </Modal.Body>
      </Modal>
    </>
  );
}
