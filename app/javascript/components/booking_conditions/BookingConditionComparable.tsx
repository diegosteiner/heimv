import { useEffect, useState } from "react";
import Row from "react-bootstrap/esm/Row";
import Form from "react-bootstrap/esm/Form";
import type { BookingCondition, BookingConditionOptionsForSelect } from "./BookingCondition";

type Props = {
  condition: BookingCondition;
  optionsForSelect: BookingConditionOptionsForSelect;
  onRemove?: (condition: BookingCondition) => void;
  onChange?: (condition: BookingCondition) => void;
};

export default function BookingConditionForm({ optionsForSelect, condition, onRemove, onChange }: Props) {
  // const [condition, setCondition] = useState<BookingCondition>(initialCondition);
  const optionsForSelectedType = optionsForSelect[condition.type];
  const handleChange = (changedCondition: Partial<BookingCondition>) =>
    onChange?.({ ...condition, ...changedCondition });

  return (
    <>
      <div>{optionsForSelectedType.name}</div>
      <Row>
        <Form.Group className="col-md-4">
          {optionsForSelectedType.compare_attributes && optionsForSelectedType.compare_attributes.length > 0 && (
            <Form.Select required onChange={(event) => handleChange({ compare_attribute: event.target.value })}>
              <option />
              {optionsForSelectedType.compare_attributes.map(([label, value]) => (
                <option key={value} value={value}>
                  {label}
                </option>
              ))}
            </Form.Select>
          )}
        </Form.Group>
        <Form.Group className="col-md-2">
          {optionsForSelectedType.compare_operators && optionsForSelectedType.compare_operators.length > 0 && (
            <Form.Select required onChange={(event) => handleChange({ compare_operator: event.target.value })}>
              <option />
              {optionsForSelectedType.compare_operators.map(([label, value]) => (
                <option key={value} value={value}>
                  {label}
                </option>
              ))}
            </Form.Select>
          )}
        </Form.Group>
        <Form.Group className="col-md-4">
          {(optionsForSelectedType.compare_values && optionsForSelectedType.compare_values.length > 0 && (
            <Form.Select required onChange={(event) => handleChange({ compare_value: event.target.value })}>
              <option />
              {optionsForSelectedType.compare_values.map(([label, value]) => (
                <option key={value} value={value}>
                  {label}
                </option>
              ))}
            </Form.Select>
          )) || (
            <Form.Control
              type="text"
              required
              onChange={(event) => handleChange({ compare_value: event.target.value })}
            />
          )}
        </Form.Group>
        <div className="col-md-2 d-flex justify-content-end">
          <button type="button" className="btn btn-default" onClick={() => onRemove?.(condition)}>
            <span className="fa fa-trash" />
          </button>
        </div>
      </Row>
    </>
  );
}
