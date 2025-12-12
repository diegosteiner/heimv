import { useCallback, useState } from "react";
import { Button, FloatingLabel, Modal } from "react-bootstrap";
import Col from "react-bootstrap/esm/Col";
import Form from "react-bootstrap/esm/Form";
import Row from "react-bootstrap/esm/Row";
import { useTranslation } from "react-i18next";
import { v4 as uuidv4 } from "uuid";
import type { VatCategory } from "../../models/VatCategory";

export enum InvoiceItemType {
  Add = "Invoice::Items::Add",
  Balance = "Invoice::Items::Balance",
  Deposit = "Invoice::Items::Deposit",
  Text = "Invoice::Items::Text",
  Title = "Invoice::Items::Title",
}

export type InvoiceItem = {
  id: string;
  type: InvoiceItemType;
  suggested?: boolean;
  accounting_account_nr?: string | undefined;
  accounting_cost_center_nr?: string | undefined;
  amount?: number | string;
  breakdown?: string;
  label?: string;
  usage_id?: string | undefined;
  deposit_id?: string | undefined;
  vat_category_id?: string | undefined;
  errors?: {
    label?: string[];
    vat_category_id?: string[];
    accounting_account_nr?: string[];
  };
};

export function initializeInvoiceItem(item: Partial<InvoiceItem> & Pick<InvoiceItem, "type">): InvoiceItem {
  return { id: uuidv4(), ...item };
}

type InvoiceItemElementProps = {
  item: InvoiceItem;
  disabled?: boolean;
  namePrefix: string;
  onRemove?: (item: InvoiceItem) => void;
  onChange?: (item: InvoiceItem) => void;
  optionsForSelect: {
    vatCategories: VatCategory[];
  };
};

export default function InvoiceItemElement({
  item,
  onRemove,
  onChange,
  disabled,
  namePrefix,
  optionsForSelect,
}: InvoiceItemElementProps) {
  const { t } = useTranslation();
  const [editing, setEditing] = useState(false);
  const handleEdit = useCallback(() => setEditing(true), []);
  const handleChange = useCallback(
    (change: Partial<InvoiceItem>) => !disabled && onChange?.({ ...item, ...change }),
    [disabled, item, onChange],
  );
  const nonTextItemType = [InvoiceItemType.Add, InvoiceItemType.Balance, InvoiceItemType.Deposit].includes(item.type);
  const vatCategory =
    item.vat_category_id &&
    optionsForSelect.vatCategories.find((it) => it.id.toString() === item.vat_category_id?.toString());

  return (
    <Row>
      <Col md={1} className="sortable-handle align-items-center d-flex">
        <span className="fa fa-bars" />
        {item.errors && Object.keys(item.errors).length > 0 && (
          <span className="fa fa-exclamation-circle text-danger fs-5 ms-3" />
        )}
        {item.suggested && (
          <span
            title={t("activemodel.attributes.invoice/item.suggested")}
            className="fa fa-lightbulb-o ms-3 text-warning fs-4"
          />
        )}
        <input type="hidden" name={`${namePrefix}[id]`} value={item.id} />
        <input type="hidden" name={`${namePrefix}[type]`} value={item.type} />
        <input type="hidden" name={`${namePrefix}[usage_id]`} value={item.usage_id} />
        <input type="hidden" name={`${namePrefix}[deposit_id]`} value={item.deposit_id} />
        <input type="hidden" name={`${namePrefix}[accounting_account_nr]`} value={item.accounting_account_nr || ""} />
        <input
          type="hidden"
          name={`${namePrefix}[accounting_cost_center_nr]`}
          value={item.accounting_cost_center_nr || ""}
        />
        <input type="hidden" name={`${namePrefix}[vat_category_id]`} value={item.vat_category_id || ""} />
        {item.suggested && <input type="hidden" name={`${namePrefix}[suggested]`} value="1" />}
      </Col>
      <Form.Group className="col-md-3 py-1">
        <FloatingLabel label={t("activemodel.attributes.invoice/item.label")}>
          <Form.Control
            type="text"
            name={`${namePrefix}[label]`}
            required
            value={item.label || ""}
            onChange={(event) => handleChange({ label: event.target.value })}
          />
        </FloatingLabel>
      </Form.Group>
      <Form.Group className="col-lg-5 col-md-3 py-1">
        {nonTextItemType && (
          <FloatingLabel label={t("activemodel.attributes.invoice/item.breakdown")}>
            <Form.Control
              type="text"
              required
              value={item.breakdown || ""}
              name={`${namePrefix}[breakdown]`}
              onChange={(event) => handleChange({ breakdown: event.target.value })}
            />
          </FloatingLabel>
        )}
      </Form.Group>
      <Form.Group className="col-lg-2 col-md-3 py-1">
        {nonTextItemType && (
          <FloatingLabel
            label={
              vatCategory
                ? t("activemodel.attributes.invoice/item.amount_with_vat", {
                    vat_percentage: vatCategory.percentage,
                    vat_label: vatCategory.label,
                  })
                : t("activemodel.attributes.invoice/item.amount")
            }
          >
            <Form.Control
              type="text"
              required
              inputMode="numeric"
              value={item.amount || ""}
              name={`${namePrefix}[amount]`}
              className="text-end"
              onChange={(event) => handleChange({ amount: event.target.value })}
              onBlur={(event) =>
                handleChange({
                  amount: Number.isNaN(+event.target.value) ? undefined : (+event.target.value).toFixed(2),
                })
              }
            />
          </FloatingLabel>
        )}
      </Form.Group>
      <div className="col-lg-1 col-md-2 d-flex justify-content-end align-items-center">
        <div className="btn-group">
          {nonTextItemType && (
            <button
              disabled={disabled}
              type="button"
              className="btn btn-default"
              title={t("edit")}
              onClick={handleEdit}
            >
              <span className="fa fa-pencil" />
            </button>
          )}
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
      </div>
      <Modal show={editing} onHide={() => setEditing(false)}>
        <Modal.Body>
          <Form.Group className="mb-3">
            <Form.Label>{t("activemodel.attributes.invoice/item.label")}</Form.Label>
            <Form.Control
              type="text"
              name={`${namePrefix}[label]`}
              required
              value={item.label || ""}
              onChange={(event) => handleChange({ label: event.target.value })}
            />
          </Form.Group>
          <Form.Group className="mb-3">
            {nonTextItemType && (
              <>
                <Form.Label>{t("activemodel.attributes.invoice/item.breakdown")}</Form.Label>
                <Form.Control
                  type="text"
                  required
                  value={item.breakdown || ""}
                  name={`${namePrefix}[breakdown]`}
                  onChange={(event) => handleChange({ breakdown: event.target.value })}
                />
              </>
            )}
          </Form.Group>
          <Form.Group className="mb-3">
            {nonTextItemType && (
              <>
                <Form.Label>
                  {vatCategory
                    ? t("activemodel.attributes.invoice/item.amount_with_vat", {
                        vat_percentage: vatCategory.percentage,
                        vat_label: vatCategory.label,
                      })
                    : t("activemodel.attributes.invoice/item.amount")}
                </Form.Label>
                <Form.Control
                  type="text"
                  required
                  inputMode="numeric"
                  value={item.amount || ""}
                  name={`${namePrefix}[amount]`}
                  className="text-end"
                  onChange={(event) => handleChange({ amount: event.target.value })}
                  onBlur={(event) =>
                    handleChange({
                      amount: Number.isNaN(+event.target.value) ? undefined : (+event.target.value).toFixed(2),
                    })
                  }
                />
              </>
            )}
          </Form.Group>
          <Form.Group className="mb-3">
            <Form.Label>{t("activemodel.attributes.invoice/item.accounting_account_nr")}</Form.Label>
            <Form.Control
              type="text"
              value={item.accounting_account_nr}
              onChange={(event) => handleChange({ accounting_account_nr: event.target.value })}
              isInvalid={!!item.errors?.accounting_account_nr}
            />
            <Form.Control.Feedback type="invalid">
              {Array.from(item.errors?.accounting_account_nr || []).join(",")}
            </Form.Control.Feedback>
          </Form.Group>
          <Form.Group className="mb-3">
            <Form.Label>{t("activemodel.attributes.invoice/item.accounting_cost_center_nr")}</Form.Label>
            <Form.Control
              type="text"
              value={item.accounting_cost_center_nr}
              onChange={(event) => handleChange({ accounting_cost_center_nr: event.target.value })}
            />
          </Form.Group>
          <Form.Group className="mb-3">
            <Form.Label>{t("activerecord.models.vat_category.one")}</Form.Label>
            <Form.Select
              value={item.vat_category_id}
              onChange={(event) => handleChange({ vat_category_id: event.target.value })}
              isInvalid={!!item.errors?.vat_category_id}
            >
              <option />
              {Array.from(optionsForSelect.vatCategories).map(({ id, label, percentage }) => (
                <option key={id} value={id}>
                  {label} ({percentage}%)
                </option>
              ))}
            </Form.Select>
            <Form.Control.Feedback type="invalid">
              {Array.from(item.errors?.vat_category_id || []).join(",")}
            </Form.Control.Feedback>
          </Form.Group>
          <Button variant="primary" type="button" onClick={() => setEditing(false)}>
            {t("helpers.submit.update")}
          </Button>
        </Modal.Body>
      </Modal>
    </Row>
  );
}
