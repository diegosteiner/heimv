import type { DragEndEvent } from "@dnd-kit/core";
import { DndContext, PointerSensor, useSensor, useSensors } from "@dnd-kit/core";
import { restrictToVerticalAxis } from "@dnd-kit/modifiers";
import { arrayMove, SortableContext, verticalListSortingStrategy } from "@dnd-kit/sortable";
import * as React from "react";
import { Dropdown } from "react-bootstrap";
import { useTranslation } from "react-i18next";
import { v4 as uuidv4 } from "uuid";
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
    value?.map((item) => ({ ...item, id: item.id || uuidv4() })) || [],
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

  const sensors = useSensors(useSensor(PointerSensor));
  const handleDragEnd = ({ active, over }: DragEndEvent) => {
    if (active.id && over?.id && active.id !== over.id) {
      setItems((items) => {
        const oldIndex = items.findIndex((i) => i.id === active.id);
        const newIndex = items.findIndex((i) => i.id === over.id);
        return arrayMove(items, oldIndex, newIndex);
      });
    }
  };

  return (
    <div className="mb-3">
      <DndContext sensors={sensors} modifiers={[restrictToVerticalAxis]} onDragEnd={handleDragEnd}>
        <SortableContext items={items.map((i) => i.id).filter(Boolean)} strategy={verticalListSortingStrategy}>
          <ol className="mb-3 list-unstyled">
            {items.map((item, index) =>
              item.id ? (
                <InvoiceItemElement
                  key={item.id}
                  optionsForSelect={optionsForSelect}
                  namePrefix={`${name}[${index}]`}
                  item={item}
                  onChange={handleChange}
                  onRemove={handleRemove}
                />
              ) : null,
            )}
          </ol>
        </SortableContext>
      </DndContext>
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
