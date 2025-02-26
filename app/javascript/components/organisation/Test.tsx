import * as React from "react";
import { OrganisationContext } from "./OrganisationProvider";

export default function Test() {
  const organisation = React.use(OrganisationContext);

  return (
    <dl>
      <dt>Name</dt>
      <dd>{organisation?.name}</dd>
    </dl>
  );
}
