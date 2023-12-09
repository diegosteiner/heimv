import * as React from "react";
import { OrganisationContext } from "./OrganisationProvider";

export default function Test() {
  const organisation = React.useContext(OrganisationContext);
  debugger;

  return (
    <dl>
      <dt>Name</dt>
      <dd>{organisation?.name}</dd>
    </dl>
  );
}
