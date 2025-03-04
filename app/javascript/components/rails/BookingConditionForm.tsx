import * as React from "react";
import {
  AddBookingConditionDropdown,
  type BookingCondition,
  BookingConditionElement,
  type BookingConditionOptionsForSelect,
  type BookingConditionType,
  initializeBookingCondition,
} from "../booking_conditions/BookingCondition";

type Props = {
  value?: BookingCondition[];
  name: string;
  disabled: boolean;
  optionsForSelect: BookingConditionOptionsForSelect;
};

export default function BookingConditionForm({ optionsForSelect, value, name, disabled }: Props) {
  const [conditions, setConditions] = React.useState<BookingCondition[]>(value || []);

  const handleAdd = (type: BookingConditionType) =>
    !disabled &&
    setConditions((prev) => {
      return [...prev, initializeBookingCondition({ type })];
    });
  const handleRemove = (removedCondition: BookingCondition) =>
    !disabled && setConditions((prev) => prev.filter((prevCondition) => prevCondition.id !== removedCondition.id));
  const handleChange = (changedCondition: BookingCondition) =>
    !disabled &&
    setConditions((prev) =>
      prev.map((prevCondition) => (prevCondition.id === changedCondition.id ? changedCondition : prevCondition)),
    );

  return (
    <div className="mb-3">
      <input type="hidden" name={name} disabled={disabled} value={JSON.stringify(conditions)} />
      <ol className="list-group mb-3">
        {Array.from(conditions).map((condition) => (
          <li key={condition.id} className="list-group-item">
            <BookingConditionElement
              condition={condition}
              optionsForSelect={optionsForSelect}
              onChange={handleChange}
              onRemove={handleRemove}
            />
          </li>
        ))}
      </ol>
      <AddBookingConditionDropdown disabled={disabled} onAction={handleAdd} optionsForSelect={optionsForSelect} />
    </div>
  );
}
