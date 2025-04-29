import { Dropdown } from "react-bootstrap";
import { useTranslation } from "react-i18next";
import { v4 as uuidv4 } from "uuid";
import BookingConditionComparable from "./BookingConditionComparable";
import BookingConditionComposition from "./BookingConditionComposition";

export enum BookingConditionType {
  Always = "BookingConditions::Always",
  Never = "BookingConditions::Never",
  BookingAttribute = "BookingConditions::BookingAttribute",
  BookingCategory = "BookingConditions::BookingCategory",
  BookingDateTime = "BookingConditions::BookingDateTime",
  BookingQuestion = "BookingConditions::BookingQuestion",
  BookingState = "BookingConditions::BookingState",
  OccupancyDuration = "BookingConditions::OccupancyDuration",
  Occupiable = "BookingConditions::Occupiable",
  Tarif = "BookingConditions::Tarif",
  TenantAttribute = "BookingConditions::TenantAttribute",
  AllOf = "BookingConditions::AllOf",
  OneOf = "BookingConditions::OneOf",
}

export type BookingConditionComparableType =
  | BookingConditionType.Always
  | BookingConditionType.Never
  | BookingConditionType.BookingAttribute
  | BookingConditionType.BookingCategory
  | BookingConditionType.BookingDateTime
  | BookingConditionType.BookingQuestion
  | BookingConditionType.BookingState
  | BookingConditionType.OccupancyDuration
  | BookingConditionType.Occupiable
  | BookingConditionType.Tarif
  | BookingConditionType.TenantAttribute;

export type BookingConditionCompositionType = BookingConditionType.AllOf | BookingConditionType.OneOf;

export type BookingCondition =
  | {
      type: BookingConditionComparableType;
      id: string;
      errors?: {
        compare_attribute?: string[];
        compare_operator?: string[];
        compare_value?: string[];
      };
      compare_attribute?: string;
      compare_operator?: string;
      compare_value?: string;
    }
  | {
      type: BookingConditionCompositionType;
      id: string;
      conditions?: BookingCondition[];
    };

export type BookingConditionOptionsForSelect = {
  [T in BookingConditionType]: {
    type: T;
    name: string;
    compare_attributes?: [string, string][] | null;
    compare_operators?: [string, string][] | null;
    compare_values?: [string, string][] | null;
    compare_value_regex?: string | null;
  };
};

export function initializeBookingCondition(
  condition: Partial<BookingCondition> & Pick<BookingCondition, "type">,
): BookingCondition {
  return { id: uuidv4(), ...condition };
}

type BookingConditionElementProps = {
  condition: BookingCondition;
  optionsForSelect: BookingConditionOptionsForSelect;
  onRemove?: (condition: BookingCondition) => void;
  onChange?: (condition: BookingCondition) => void;
};

function isCompositionCondition(
  condition: BookingCondition,
): condition is BookingCondition & { type: BookingConditionCompositionType } {
  return [BookingConditionType.AllOf, BookingConditionType.OneOf].includes(condition.type);
}

export function BookingConditionElement({
  condition,
  optionsForSelect,
  onRemove,
  onChange,
}: BookingConditionElementProps) {
  if (!Object.values(BookingConditionType).includes(condition.type)) return <></>;

  if (isCompositionCondition(condition))
    return (
      <BookingConditionComposition
        condition={condition}
        optionsForSelect={optionsForSelect}
        onRemove={onRemove}
        onChange={onChange}
      />
    );
  return (
    <BookingConditionComparable
      condition={condition}
      optionsForSelect={optionsForSelect}
      onRemove={onRemove}
      onChange={onChange}
    />
  );
}

export function AddBookingConditionDropdown({
  onAction,
  disabled,
  optionsForSelect,
}: {
  onAction: (type: BookingConditionType) => void;
  optionsForSelect: BookingConditionOptionsForSelect;
  disabled?: boolean;
}) {
  const { t } = useTranslation();

  return (
    <Dropdown onSelect={(eventKey) => !disabled && onAction(eventKey as BookingConditionType)}>
      <Dropdown.Toggle variant="secondary">
        {t("add_record", { model_name: t("activemodel.models.booking_condition.one") })}
      </Dropdown.Toggle>
      <Dropdown.Menu>
        {Object.values(BookingConditionType).map((type) => (
          <Dropdown.Item disabled={disabled} eventKey={type} key={type}>
            {optionsForSelect[type]?.name || type}
          </Dropdown.Item>
        ))}
      </Dropdown.Menu>
    </Dropdown>
  );
}
