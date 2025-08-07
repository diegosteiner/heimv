import * as React from "react";
import InvoiceItemElement, {
  AddInvoiceItemDropdown,
  initializeInvoiceItem,
  type InvoiceItem,
  type InvoiceItemType,
} from "./InvoiceItem";
import { ReactSortable } from "react-sortablejs";

export type Props = {
  value?: InvoiceItem[];
  name: string;
  disabled: boolean;
};

export default function InvoiceItemForm({ value, name, disabled }: Props) {
  const [items, setItems] = React.useState<InvoiceItem[]>(
    value?.map((item) => ({ ...item, id: item.id || crypto.randomUUID() })) || [],
  );

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
      <input type="hidden" name={name} disabled={disabled} value={JSON.stringify(items)} />
      <ReactSortable
        tag="ol"
        className="mb-3 list-unstyled"
        list={Array.from(items)}
        setList={setItems}
        handle=".sortable-handle"
      >
        {Array.from(items).map((item) => (
          <li key={item.id} className="py-1">
            <InvoiceItemElement item={item} onChange={handleChange} onRemove={handleRemove} />
          </li>
        ))}
      </ReactSortable>
      <AddInvoiceItemDropdown disabled={disabled} onAction={handleAdd} />
    </div>
  );
}
