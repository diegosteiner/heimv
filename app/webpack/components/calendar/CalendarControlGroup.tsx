import * as React from "react";
import { Form } from "react-bootstrap";
import CalendarControl from "./CalendarControl";

interface CalendarControlGroupProps {
  value: string;
  name: string;
  id?: string;
  label: string;
  required?: boolean;
  disabled?: boolean;
  isInvalid?: boolean;
  invalidFeedback?: string;
}

export default function CalendarControlGroup({
  value,
  name,
  id,
  label,
  required = false,
  disabled = false,
  invalidFeedback,
  isInvalid = !!invalidFeedback,
}: CalendarControlGroupProps) {
  return (
    <Form.Group className="mb-3">
      <Form.Label className={required ? "required" : ""}>{label}</Form.Label>
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
}
