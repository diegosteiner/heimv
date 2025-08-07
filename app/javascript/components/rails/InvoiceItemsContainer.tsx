import * as React from "react";
import type { Props as InvoiceItemFormProps } from "../invoice_items/InvoiceItemForm";
import InvoiceItemForm from "../invoice_items/InvoiceItemForm";

export default function InvoiceItemContainer(props: unknown) {
  return (
    <React.StrictMode>
      <InvoiceItemForm {...(props as InvoiceItemFormProps)} />
    </React.StrictMode>
  );
}
