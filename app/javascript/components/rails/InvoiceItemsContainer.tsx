import * as React from "react";
import type { Props as InvoiceItemsProps } from "../invoice_items/InvoiceItems";
import InvoiceItems from "../invoice_items/InvoiceItems";

export default function InvoiceItemContainer(props: unknown) {
  return (
    <React.StrictMode>
      <InvoiceItems {...(props as InvoiceItemsProps)} />
    </React.StrictMode>
  );
}
