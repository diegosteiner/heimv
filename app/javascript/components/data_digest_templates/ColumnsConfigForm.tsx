import type { DragEndEvent } from "@dnd-kit/core";
import { DndContext, PointerSensor, useSensor, useSensors } from "@dnd-kit/core";
import { restrictToVerticalAxis } from "@dnd-kit/modifiers";
import { arrayMove, SortableContext, useSortable, verticalListSortingStrategy } from "@dnd-kit/sortable";
import { CSS } from "@dnd-kit/utilities";
import type * as React from "react";
import { useState } from "react";
import { Col, Dropdown, FloatingLabel, Form, Row } from "react-bootstrap";
import { useTranslation } from "react-i18next";
import { v4 as uuidv4 } from "uuid";

enum ColumnConfigType {
  Default = "default",
  Usage = "usage",
  Costs = "costs",
  BookingQuestionResponse = "booking_question_response",
}

export type ColumnConfigOptionsType = {
  tarifs: Record<string, string>;
  bookingQuestions: Record<string, string>;
};

type BaseColumnConfig = {
  id: string;
  header: string;
  body: string;
  type: ColumnConfigType;
};

type UsageColumnConfig = BaseColumnConfig & {
  type: ColumnConfigType.Usage;
  tarif_id: string | number;
};

type BookingQuestionResponseColumnConfig = BaseColumnConfig & {
  type: ColumnConfigType.BookingQuestionResponse;
  booking_question_id: string | number;
};

export type ColumnConfig = BaseColumnConfig | UsageColumnConfig | BookingQuestionResponseColumnConfig;

function isColumnConfigType(type: string): type is ColumnConfigType {
  return Object.values<string>(ColumnConfigType).includes(type);
}

function toJson(columnsConfigs: ColumnConfig[]): string {
  return JSON.stringify(columnsConfigs);
}

type Props = {
  columnsConfig: (ColumnConfig & { id: string | undefined })[];
  name: string;
  options: ColumnConfigOptionsType;
};

export default function ColumnsConfigForm({ columnsConfig: initialColumnsConfig, name, options }: Props) {
  const { t } = useTranslation();
  const [columnsConfig, setColumnsConfig] = useState<ColumnConfig[]>(
    initialColumnsConfig.map((columnConfig) => ({
      ...columnConfig,
      id: columnConfig.id ? columnConfig.id : uuidv4(),
    })),
  );

  const handleUpdate = (updatedConfig: ColumnConfig) =>
    setColumnsConfig((prev) =>
      prev.map((prevConfig: ColumnConfig) => (prevConfig.id === updatedConfig.id ? updatedConfig : prevConfig)),
    );
  const handleRemove = (removedConfig: ColumnConfig) =>
    setColumnsConfig((prev) => prev.filter((prevConfig) => prevConfig.id !== removedConfig.id));
  const handleAdd = (type: string) =>
    isColumnConfigType(type) && setColumnsConfig((prev) => [...prev, { type, body: "", header: "", id: uuidv4() }]);

  const sensors = useSensors(useSensor(PointerSensor));
  const handleDragEnd = ({ active, over }: DragEndEvent) => {
    if (active.id && over?.id && active.id !== over.id) {
      setColumnsConfig((items) => {
        const oldIndex = items.findIndex((i) => i.id === active.id);
        const newIndex = items.findIndex((i) => i.id === over.id);
        return arrayMove(items, oldIndex, newIndex);
      });
    }
  };

  return (
    <Form.Group className="mb-3">
      <Form.Label className="mb-2">{t("activerecord.attributes.data_digest_template.columns_config")}</Form.Label>
      <DndContext sensors={sensors} modifiers={[restrictToVerticalAxis]} onDragEnd={handleDragEnd}>
        <SortableContext
          items={columnsConfig
            .map((c) => c.id)
            .filter(Boolean)
            .filter(Boolean)}
          strategy={verticalListSortingStrategy}
        >
          <ol className="list-unstyled mb-3">
            {columnsConfig.map(
              (config) =>
                config.id && (
                  <ColumnConfigForm
                    key={config.id}
                    config={config}
                    onRemove={handleRemove}
                    onUpdate={handleUpdate}
                    options={options}
                  />
                ),
            )}
          </ol>
        </SortableContext>
      </DndContext>
      <Dropdown onSelect={(eventKey) => handleAdd(eventKey as ColumnConfigType)}>
        <Dropdown.Toggle variant="secondary">
          {t("add_record", { model_name: t("activerecord.attributes.data_digest_template.columns_config") })}
        </Dropdown.Toggle>
        <Dropdown.Menu>
          {Object.values(ColumnConfigType).map((type) => (
            <Dropdown.Item eventKey={type} key={type}>
              {type}
            </Dropdown.Item>
          ))}
        </Dropdown.Menu>
      </Dropdown>
      <Form.Control className="d-none" name={name} as="textarea" readOnly value={toJson(columnsConfig)} />
    </Form.Group>
  );
}

type ColumnConfigFormProps = {
  config: ColumnConfig;
  onUpdate: (config: ColumnConfig) => void;
  onRemove: (config: ColumnConfig) => void;
  additionalFields?: string[];
  options?: ColumnConfigOptionsType;
};

function ColumnConfigForm({ config, onUpdate, onRemove, options }: ColumnConfigFormProps) {
  const {
    attributes: draggableAttributes,
    listeners: draggableListeners,
    setNodeRef,
    setActivatorNodeRef,
    transform,
    transition,
    isDragging,
  } = useSortable({ id: config.id });
  const style = {
    transform: CSS.Transform.toString(transform),
    transition,
    opacity: isDragging ? 0.5 : 1,
  };
  const typeSpecificComponents: Record<ColumnConfigType, (config: ColumnConfig) => React.ReactElement> = {
    [ColumnConfigType.Default]: (_config) => <></>,
    [ColumnConfigType.Costs]: (_config) => <></>,
    [ColumnConfigType.Usage]: (config) => (
      <FloatingLabel label="Tarif ID">
        <Form.Select
          defaultValue={(config as UsageColumnConfig).tarif_id}
          onChange={(event) => onUpdate({ ...(config as UsageColumnConfig), tarif_id: event.target.value })}
        >
          <option />
          {options?.tarifs &&
            Object.entries(options.tarifs).map(([id, label]) => (
              <option key={id} value={id}>
                {label}
              </option>
            ))}
        </Form.Select>
      </FloatingLabel>
    ),
    [ColumnConfigType.BookingQuestionResponse]: (config) => (
      <FloatingLabel label="Booking Question ID">
        <Form.Select
          defaultValue={(config as BookingQuestionResponseColumnConfig).booking_question_id}
          onChange={(event) =>
            onUpdate({ ...(config as BookingQuestionResponseColumnConfig), booking_question_id: event.target.value })
          }
        >
          <option />
          {options?.tarifs &&
            Object.entries(options.tarifs).map(([id, label]) => (
              <option key={id} value={id}>
                {label}
              </option>
            ))}
        </Form.Select>
      </FloatingLabel>
    ),
  };

  return (
    <li ref={setNodeRef} style={style} {...draggableAttributes} className="list-group-item">
      <Row className="row-gap-2">
        <Col ref={setActivatorNodeRef} {...draggableListeners} md={1} className="align-self-center">
          <span className="fa fa-bars" />
        </Col>
        <Col>
          <Row className="mt-3 row-gap-2">
            <Col md={6}>
              <FloatingLabel label="Header">
                <Form.Control
                  type="text"
                  defaultValue={config.header}
                  onChange={(event) => onUpdate({ ...config, header: event.target.value })}
                />
              </FloatingLabel>
            </Col>
            <Col md={6}>
              <FloatingLabel label="Body">
                <Form.Control
                  type="text"
                  defaultValue={config.body}
                  onChange={(event) => onUpdate({ ...config, body: event.target.value })}
                />
              </FloatingLabel>
            </Col>
          </Row>
          {typeSpecificComponents[config.type] && (
            <Row className="mt-2">
              <Col md={12}>{typeSpecificComponents[config.type](config)}</Col>
            </Row>
          )}
        </Col>
        <Col md={1} className="align-self-center">
          <div className="btn-group">
            <button type="button" className="btn btn-default" onClick={() => onRemove(config)}>
              <span className="fa fa-trash" />
            </button>
          </div>
        </Col>
      </Row>
    </li>
  );
}
