import * as React from "react";
import ColumnsConfigForm, {
  type ColumnConfig,
  type ColumnConfigOptionsType,
} from "../data_digest_templates/ColumnsConfigForm";

type Props = {
  name: string;
  columnsConfig: ColumnConfig[];
  options: ColumnConfigOptionsType;
};

export default function DataDigestColumnsConfigForm({ name, columnsConfig, options }: Props) {
  return (
    <React.StrictMode>
      <ColumnsConfigForm name={name} columnsConfig={columnsConfig} options={options} />
    </React.StrictMode>
  );
}
