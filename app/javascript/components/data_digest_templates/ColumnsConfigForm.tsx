import * as React from "react";
import { useState } from "react";
import { Col, FloatingLabel, Form, Row } from "react-bootstrap";
import { useTranslation } from "react-i18next";
import { ReactSortable } from "react-sortablejs";

enum ColumnConfigType {
  Default = "default",
  Usage = "usage",
  Costs = "costs",
  BookingQuestionResponse = "booking_question_response",
}

type ColumnsConfigFormProps = {
  json: string;
  name: string;
};

type DefaultColumnConfig = {
  id: string;
  index: number;
  type: ColumnConfigType;
  header: string;
  body: string;
};

type UsageColumnConfig = DefaultColumnConfig & {
  type: ColumnConfigType.Usage;
  tarif_id: number;
};

type CostColumnConfig = DefaultColumnConfig & {
  type: "costs";
};

function isColumnConfigType(type: string): type is ColumnConfigType {
  return Object.values<string>(ColumnConfigType).includes(type);
}

function toJson(columnsConfigs: ColumnConfig[]): string {
  return JSON.stringify(columnsConfigs)
}

type ColumnConfig = DefaultColumnConfig | UsageColumnConfig | CostColumnConfig;

export default function ColumnsConfigFrom({ json, name }: ColumnsConfigFormProps) {
  const { t } = useTranslation();
  const [columnsConfig, setColumnsConfig] = useState<ColumnConfig[]>(() =>
    (JSON.parse(json) as unknown as ColumnConfig[]).map((data, index) => ({ ...data, index, id: crypto.randomUUID() })),
  );

  const handleUpdate = (updatedConfig: ColumnConfig) =>
    setColumnsConfig((prev) =>
      prev.map((prevConfig: ColumnConfig) => (prevConfig.index == updatedConfig.index ? updatedConfig : prevConfig)),
    );
  const handleRemove = (removedConfig: ColumnConfig) =>
    setColumnsConfig((prev) => prev.filter((prevConfig) => prevConfig.index != removedConfig.index));
  const handleAdd = (type: string) =>
    isColumnConfigType(type) &&
    setColumnsConfig((prev) => [...prev, { index: prev.length, type, body: "", header: "", id: crypto.randomUUID() }]);

  return (
    <Form.Group className="mb-3">
      <Form.Label>{t("activerecord.attributes.data_digest_template.columns_config")}</Form.Label>
      <ReactSortable tag="ol" className="list-group mb-3" list={columnsConfig} setList={setColumnsConfig} handle=".sortable-handle">
        {columnsConfig.map((config) => (
          <li key={config.id} className="list-group-item">
            <ColumnConfigForm config={config} onRemove={handleRemove} onUpdate={handleUpdate}></ColumnConfigForm>
          </li>
        ))}
      </ReactSortable>
      <Form.Group className="row">
        <Col md={4}>
          <Form.Select value="" onChange={(event) => handleAdd(event.target.value)}>
            <option></option>
            {Object.values(ColumnConfigType).map((type) => (
              <option value={type} key={type}>
                {type}
              </option>
            ))}
          </Form.Select>
        </Col>
      </Form.Group>
      <Form.Control className="d-none" name={name} as="textarea" value={toJson(columnsConfig)}></Form.Control>
    </Form.Group>
  );
}

type ColumnConfigFormProps = {
  config: ColumnConfig;
  onUpdate: (config: ColumnConfig) => void;
  onRemove: (config: ColumnConfig) => void;
  additionalFields?: string[];
};

function ColumnConfigForm({ config, onUpdate, onRemove }: ColumnConfigFormProps) {
  const typeSpecificComponents = {
    [ColumnConfigType.Default]: () => <></>,
    [ColumnConfigType.Costs]: () => <></>,
    [ColumnConfigType.Usage]: () => (
      <FloatingLabel label="Tarif ID">
        <Form.Control
          type="text"
          defaultValue={config.tarif_id}
          onChange={(event) => onUpdate({ ...config, tarif_id: event.target.value })}
        ></Form.Control>
      </FloatingLabel>
    ),
    [ColumnConfigType.BookingQuestionResponse]: () => (
      <FloatingLabel label="Booking Question ID">
        <Form.Control
          type="text"
          defaultValue={config.id}
          onChange={(event) => onUpdate({ ...config, id: event.target.value })}
        ></Form.Control>
      </FloatingLabel>
    ),
  };

  return (
      <Row className="row-gap-2">
        <Col md={1} className="align-self-center">
          <span className="sortable-handle fa fa-bars"></span>
        </Col>
        <Col>
          <Row className="row-gap-2">
            <Col md={6}>
              <FloatingLabel label="Header">
                <Form.Control
                  type="text"
                  defaultValue={config.header}
                  onChange={(event) => onUpdate({ ...config, header: event.target.value })}
                ></Form.Control>
              </FloatingLabel>
            </Col>
            <Col md={6}>
              <FloatingLabel label="Body">
                <Form.Control
                  type="text"
                  defaultValue={config.body}
                  onChange={(event) => onUpdate({ ...config, body: event.target.value })}
                ></Form.Control>
              </FloatingLabel>
            </Col>
            <Col md={12}>{typeSpecificComponents[config.type]?.()}</Col>
          </Row>
        </Col>
        <Col md={1} className="align-self-center">
          <div className="btn-group">
            <button type="button" className="btn btn-default" onClick={() => onRemove(config)}>
              <span className="fa fa-trash"></span>
            </button>
          </div>
        </Col>
      </Row>
  );
}
