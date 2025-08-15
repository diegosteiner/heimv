import * as React from "react";
import { Dropdown } from "react-bootstrap";
import { useTranslation } from "react-i18next";
import { ReactSortable } from "react-sortablejs";
import type { VatCategory } from "../../models/VatCategory";
import { underscorize } from "../../services/i18n";
import InvoiceItemElement, { type InvoiceItem, InvoiceItemType, initializeInvoiceItem } from "./InvoiceItem";

export type Props = {
  value?: InvoiceItem[];
  name: string;
  disabled: boolean;
  errors?: string[];
  optionsForSelect: {
    vatCategories: VatCategory[];
  };
};

export default function InvoiceItems({ value, name, disabled, optionsForSelect }: Props) {
  const [items, setItems] = React.useState<InvoiceItem[]>(
    value?.map((item) => ({ ...item, id: item.id || crypto.randomUUID() })) || [],
  );

  const { t } = useTranslation();
  const handleAdd = (type: InvoiceItemType) =>
    !disabled &&
    setItems((prev) => {
      return [...prev, initializeInvoiceItem({ type })];
    });
  const handleRemove = (removedItem: InvoiceItem) =>
    !disabled && setItems((prev) => prev.filter((prevItem) => prevItem.id !== removedItem.id));
  const handleChange = (changedItem: InvoiceItem) =>
    !disabled && setItems((prev) => prev.map((prevItem) => (prevItem.id === changedItem.id ? changedItem : prevItem)));

  return (
    <div className="mb-3">
      <ReactSortable
        tag="ol"
        className="mb-3 list-unstyled"
        list={Array.from(items)}
        setList={setItems}
        handle=".sortable-handle"
      >
        {Array.from(items).map((item, index) => (
          <li key={item.id} className="py-1">
            <InvoiceItemElement
              optionsForSelect={optionsForSelect}
              namePrefix={`${name}[${index}]`}
              item={item}
              onChange={handleChange}
              onRemove={handleRemove}
            />
          </li>
        ))}
      </ReactSortable>
      <div className="row">
        <div className="col-lg-2 offset-lg-9 py-2 px-4 text-end border-top">
          {items.reduce((sum, item) => sum + +(item.amount || 0), 0).toFixed(2)}
        </div>
      </div>
      <Dropdown onSelect={(eventKey) => !disabled && handleAdd(eventKey as InvoiceItemType)}>
        <Dropdown.Toggle variant="secondary">
          {t("add_record", { model_name: t("activemodel.models.invoice/item.one") })}
        </Dropdown.Toggle>
        <Dropdown.Menu>
          {Object.values(InvoiceItemType)
            .filter((type) => type !== InvoiceItemType.Balance && type !== InvoiceItemType.Deposit)
            .map((type) => (
              <Dropdown.Item disabled={disabled} eventKey={type} key={type}>
                {t(`activemodel.model.${underscorize(type)}.one`)}
              </Dropdown.Item>
            ))}
        </Dropdown.Menu>
      </Dropdown>
    </div>
  );
}
