import * as React from "react";
import BookingConditionForm from "../booking_conditions/BookingConditionForm";
import type { Props as BookingConditionFormProps } from "../booking_conditions/BookingConditionForm";

export default function BookingConditionContainer(props: unknown) {
  return (
    <React.StrictMode>
      <BookingConditionForm {...(props as BookingConditionFormProps)} />
    </React.StrictMode>
  );
}
