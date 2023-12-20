export type Organisation = {
  slug: string | null;
  address: string;
  // booking_agents: boolean;
  booking_categories: BookingCategory[];
  // booking_flow_type: string;
  currency: string;
  // designated_documents: TranslatedString;
  email: string;
  homes: Home[];
  // invoice_ref_strategy_type: string;
  // links: Links;
  // location: string;
  name: string;
};

export enum Locale {
  DE = "de",
  FR = "fr",
  IT = "it",
}

export type TranslatedString = Record<Locale, string>;

export type BookingCategory = {
  description_i18n: TranslatedString;
  key: string;
  title: string;
  title_i18n: TranslatedString;
};

export type Home = {
  id: number;
  active: boolean;
  description: string;
  description_i18n: TranslatedString;
  home_id: number;
  name: string;
  name_i18n: TranslatedString;
  occupiable: boolean;
  occupiables: Occupiable[];
};

export type Occupiable = {
  id: number;
  organisation_id: number;
  ref: string | null;
  // janitor: null;
  active: boolean;
  created_at: Date;
  updated_at: Date;
  occupiable: boolean;
  home_id: number;
  // settings: Settings;
  ordinal: number;
  name_i18n: TranslatedString;
  description_i18n: TranslatedString;
};
