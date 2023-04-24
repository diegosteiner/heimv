import i18n from "i18next";
import { initReactI18next } from "react-i18next";

import de_translations from "../../../config/locales/de.yml";
import fr_translations from "../../../config/locales/fr.yml";
import it_translations from "../../../config/locales/it.yml";

const resources = {
  de: { translation: de_translations.de },
  fr: { translation: fr_translations.fr },
  it: { translation: it_translations.it },
};

i18n
  .use(initReactI18next) // passes i18n down to react-i18next
  .init({
    resources,
    lng: document?.documentElement?.lang?.split("-")?.[0] || "de",
    debug: true,
    keySeparator: ".",

    interpolation: {
      escapeValue: false, // react already safes from xss,
      prefix: "%{",
      suffix: "}",
    },
  });

export default i18n;
