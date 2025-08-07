import Dropdown from "react-bootstrap/Dropdown";
import Col from "react-bootstrap/esm/Col";
import Form from "react-bootstrap/esm/Form";
import Row from "react-bootstrap/esm/Row";
import { useTranslation } from "react-i18next";
import { v4 as uuidv4 } from "uuid";

export enum InvoiceItemType {
  Add = "Invoice::Items::Add",
  Deposit = "Invoice::Items::Deposit",
  Text = "Invoice::Items::Text",
  Title = "Invoice::Items::Title",
  Percentage = "Invoice::Items::Percentage",
}

export type InvoiceItem = {
  id: string;
  type: InvoiceItemType;
  apply?: boolean;
  accounting_account_nr?: string;
  accounting_cost_center_nr?: string;
  amount?: string | number;
  breakdown?: string;
  label?: string;
  usage_id?: string;
  vat_category_id?: string;
  errors?: {
    // compare_attribute?: string[];
    // compare_operator?: string[];
    // compare_value?: string[];
  };
};

export function initializeInvoiceItem(item: Partial<InvoiceItem> & Pick<InvoiceItem, "type">): InvoiceItem {
  return { id: uuidv4(), ...item };
}

export function AddInvoiceItemDropdown({
  onAction,
  disabled,
}: {
  onAction: (type: InvoiceItemType) => void;
  disabled?: boolean;
}) {
  const { t } = useTranslation();

  return (
    <Dropdown onSelect={(eventKey) => !disabled && onAction(eventKey as InvoiceItemType)}>
      <Dropdown.Toggle variant="secondary">
        {t("add_record", { model_name: t("activemodel.models.invoice_item.one") })}
      </Dropdown.Toggle>
      <Dropdown.Menu>
        {Object.values(InvoiceItemType).map((type) => (
          <Dropdown.Item disabled={disabled} eventKey={type} key={type}>
            {type}
          </Dropdown.Item>
        ))}
      </Dropdown.Menu>
    </Dropdown>
  );
}

type InvoiceItemElementProps = {
  item: InvoiceItem;
  disabled?: boolean;
  onRemove?: (item: InvoiceItem) => void;
  onChange?: (item: InvoiceItem) => void;
};

export default function InvoiceItemElement({ item, onRemove, onChange, disabled }: InvoiceItemElementProps) {
  const { t } = useTranslation();
  // if (!Object.values(InvoiceItemType).includes(item.type)) return;
  const handleChange = (changedCondition: Partial<InvoiceItem>) =>
    !disabled && onChange?.({ ...item, ...changedCondition });

  return (
    <Row>
      <Col md={1} className="sortable-handle align-self-center">
        <span className="fa fa-bars" />
      </Col>
      <Form.Group className="col-md-3">
        <Form.Control
          type="text"
          required
          value={item.label}
          onChange={(event) => handleChange({ label: event.target.value })}
          // isInvalid={(item.errors?.label?.length && true) || false}
        />
        {/* <Form.Control.Feedback type="invalid" tooltip>
            {item.errors?.compare_attribute?.join(", ")}
          </Form.Control.Feedback> */}
      </Form.Group>
      <Form.Group className="col-md-4">
        {[InvoiceItemType.Add, InvoiceItemType.Deposit].includes(item.type) && (
          <Form.Control
            type="text"
            required
            value={item.breakdown}
            onChange={(event) => handleChange({ breakdown: event.target.value })}
            // isInvalid={(item.errors?.label?.length && true) || false}
          />
        )}
        {/* <Form.Control.Feedback type="invalid" tooltip>
            {item.errors?.compare_attribute?.join(", ")}
          </Form.Control.Feedback> */}
      </Form.Group>
      <Form.Group className="col-md-3">
        {[InvoiceItemType.Add, InvoiceItemType.Deposit].includes(item.type) && (
          <Form.Control
            type="text"
            required
            inputMode="numeric"
            value={item.amount}
            className="text-end"
            onChange={(event) => handleChange({ amount: event.target.value })}
            // isInvalid={(item.errors?.label?.length && true) || false}
          />
        )}
        {/* <Form.Control.Feedback type="invalid" tooltip>
            {item.errors?.compare_attribute?.join(", ")}
          </Form.Control.Feedback> */}
      </Form.Group>
      <div className="col-md-1 d-flex justify-content-end">
        <button
          disabled={disabled}
          type="button"
          className="btn btn-default"
          title={t("destroy")}
          onClick={() => onRemove?.(item)}
        >
          <span className="fa fa-trash" />
        </button>
      </div>
    </Row>
  );
}
