import Form from "react-bootstrap/esm/Form";
import Row from "react-bootstrap/esm/Row";
import {
  type BookingCondition,
  type BookingConditionComparableType,
  type BookingConditionOptionsForSelect,
  BookingConditionType,
} from "./BookingCondition";

type Props = {
  condition: BookingCondition & { type: BookingConditionComparableType };
  optionsForSelect: BookingConditionOptionsForSelect;
  disabled?: boolean;
  onRemove?: (condition: BookingCondition) => void;
  onChange?: (condition: BookingCondition) => void;
};

export default function BookingConditionForm({ optionsForSelect, condition, onRemove, onChange, disabled }: Props) {
  const optionsForSelectedType = optionsForSelect[condition.type];
  const handleChange = (changedCondition: Partial<BookingCondition>) =>
    !disabled && onChange?.({ ...condition, ...changedCondition });

  return (
    <>
      <div>{optionsForSelectedType.name}</div>
      <Row>
        <Form.Group className="col-md-4">
          {optionsForSelectedType.compare_attributes && optionsForSelectedType.compare_attributes.length > 0 && (
            <Form.Select
              required
              disabled={disabled}
              value={condition.compare_attribute}
              onChange={(event) => handleChange({ compare_attribute: event.target.value })}
              isInvalid={(condition.errors?.compare_attribute?.length && true) || false}
            >
              <option />
              {optionsForSelectedType.compare_attributes.map(([label, value]) => (
                <option key={value} value={value}>
                  {label}
                </option>
              ))}
            </Form.Select>
          )}
          <Form.Control.Feedback type="invalid" tooltip>
            {condition.errors?.compare_attribute?.join(", ")}
          </Form.Control.Feedback>
        </Form.Group>
        <Form.Group className="col-md-2">
          {optionsForSelectedType.compare_operators && optionsForSelectedType.compare_operators.length > 0 && (
            <Form.Select
              required
              disabled={disabled}
              value={condition.compare_operator}
              onChange={(event) => handleChange({ compare_operator: event.target.value })}
              isInvalid={(condition.errors?.compare_operator?.length && true) || false}
            >
              <option />
              {optionsForSelectedType.compare_operators.map(([label, value]) => (
                <option key={value} value={value}>
                  {label}
                </option>
              ))}
            </Form.Select>
          )}
          <Form.Control.Feedback type="invalid" tooltip>
            {condition.errors?.compare_operator?.join(", ")}
          </Form.Control.Feedback>
        </Form.Group>
        <Form.Group className="col-md-5">
          {(optionsForSelectedType.compare_values && optionsForSelectedType.compare_values.length > 0 && (
            <Form.Select
              required
              disabled={disabled}
              value={condition.compare_value}
              onChange={(event) => handleChange({ compare_value: event.target.value })}
              isInvalid={(condition.errors?.compare_value?.length && true) || false}
            >
              <option />
              {optionsForSelectedType.compare_values.map(([label, value]) => (
                <option key={value} value={value}>
                  {label}
                </option>
              ))}
            </Form.Select>
          )) ||
            (optionsForSelectedType.compare_value_regex && (
              <Form.Control
                type="text"
                required
                value={condition.compare_value}
                onChange={(event) => handleChange({ compare_value: event.target.value })}
                isInvalid={(condition.errors?.compare_value?.length && true) || false}
              />
            ))}
          <Form.Control.Feedback type="invalid" tooltip>
            {condition.errors?.compare_value?.join(", ")}
          </Form.Control.Feedback>
        </Form.Group>
        <div className="col-md-1 d-flex justify-content-end">
          <button disabled={disabled} type="button" className="btn btn-default" onClick={() => onRemove?.(condition)}>
            <span className="fa fa-trash" />
          </button>
        </div>
      </Row>
    </>
  );
}
