import { Home } from "./Home";

export type Organisation = {
  homes: Home[];
  slug: string | null;
  links: {
    privacy_statement_pdf: string;
    terms_pdf: string;
    post_bookings: string;
    logo?: string;
  };
};
