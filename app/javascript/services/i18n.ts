import i18n from "i18next";
import type { i18n as I18nType } from "i18next";
import { initReactI18next } from "react-i18next";

// @ts-ignore
import de_translations from "../../../config/locales/de.yml";
// @ts-ignore
import fr_translations from "../../../config/locales/fr.yml";
// @ts-ignore
import it_translations from "../../../config/locales/it.yml";
import type { TranslatedString } from "../types";

const resources = {
  de: { translation: de_translations.de },
  fr: { translation: fr_translations.fr },
  it: { translation: it_translations.it },
};

i18n.use(initReactI18next).init({
  resources,
  fallbackLng: "de",
  lng: document?.documentElement?.lang?.split("-")?.[0] || "de",
  debug: false,
  keySeparator: ".",

  interpolation: {
    escapeValue: false, // react already safes from xss,
    prefix: "%{",
    suffix: "}",
  },
});

export default i18n;

export function translatedString(translations: TranslatedString, i18n: I18nType) {
  const translation = translations[i18n.language as keyof TranslatedString];
  return translation && translation.length >= 0 ? translation : translations.de;
}
