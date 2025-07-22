import * as React from "react";
import type { Props as BookingConditionFormProps } from "../booking_conditions/BookingConditionForm";
import BookingConditionForm from "../booking_conditions/BookingConditionForm";

export default function BookingConditionContainer(props: unknown) {
  return (
    <React.StrictMode>
      <BookingConditionForm {...(props as BookingConditionFormProps)} />
    </React.StrictMode>
  );
}
