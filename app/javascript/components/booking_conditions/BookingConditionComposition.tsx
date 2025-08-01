import { useTranslation } from "react-i18next";
import {
  AddBookingConditionDropdown,
  type BookingCondition,
  type BookingConditionCompositionType,
  BookingConditionElement,
  type BookingConditionOptionsForSelect,
  type BookingConditionType,
  initializeBookingCondition,
} from "./BookingCondition";

type Props = {
  condition: BookingCondition & { type: BookingConditionCompositionType };
  optionsForSelect: BookingConditionOptionsForSelect;
  disabled?: boolean;
  onRemove?: (condition: BookingCondition) => void;
  onChange?: (condition: BookingCondition) => void;
};

export default function BookingConditionComposition({
  optionsForSelect,
  condition,
  onRemove,
  onChange,
  disabled,
}: Props) {
  const { t } = useTranslation();
  const conditions = condition.conditions || [];

  const handleAddChild = (type: BookingConditionType) => {
    !disabled && onChange?.({ ...condition, conditions: [...conditions, initializeBookingCondition({ type })] });
  };
  const handleChangeChild = (changedCondition: BookingCondition) => {
    !disabled &&
      onChange?.({
        ...condition,
        conditions: conditions.map((prevCondition) =>
          prevCondition.id !== changedCondition.id ? prevCondition : changedCondition,
        ),
      });
  };
  const handleRemoveChild = (removedCondition: BookingCondition) =>
    !disabled &&
    onChange?.({
      ...condition,
      conditions: conditions.filter((prevCondition) => prevCondition.id !== removedCondition.id),
    });

  return (
    <>
      <div>{optionsForSelect[condition.type].name}</div>
      <ol className="list-group mb-3">
        {conditions.map((childCondition) => (
          <li key={condition.id} className="list-group-item py-3">
            <BookingConditionElement
              condition={childCondition}
              optionsForSelect={optionsForSelect}
              onRemove={handleRemoveChild}
              onChange={handleChangeChild}
            />
          </li>
        ))}
      </ol>
      <div className="d-flex justify-content-between">
        <AddBookingConditionDropdown onAction={handleAddChild} optionsForSelect={optionsForSelect} />
        <button
          disabled={disabled}
          type="button"
          className="btn btn-default"
          title={t("destroy")}
          onClick={() => onRemove?.(condition)}
        >
          <span className="fa fa-trash" />
        </button>
      </div>
    </>
  );
}
