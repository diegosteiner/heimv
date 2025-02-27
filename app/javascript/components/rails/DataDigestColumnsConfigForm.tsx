import * as React from "react";
import ColumnsConfigForm, { type ColumnConfig } from "../data_digest_templates/ColumnsConfigForm";

type Props = {
  name: string;
  columnsConfig: ColumnConfig[];
};

export default function DataDigestColumnsConfigForm({ name, columnsConfig }: Props) {
  return (
    <React.StrictMode>
      <ColumnsConfigForm name={name} columnsConfig={columnsConfig} />
    </React.StrictMode>
  );
}
