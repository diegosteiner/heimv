import { Home } from "./Home";

export type Organisation = {
  homes: Home[];
  slug: string | null;
  designated_documents: {
    privacy_statement: string;
    terms_pdf: string;
  };
  booking_agents: boolean;
  links: {
    post_bookings: string;
    logo?: string;
  };
};
