import i18n from "i18next";
import { initReactI18next } from "react-i18next";

import de_translations from "../../../config/locales/translation.de.yml";
import fr_translations from "../../../config/locales/translation.fr.yml";
import it_translations from "../../../config/locales/translation.it.yml";
import de_localization from "../../../config/locales/localization.de.yml";
import fr_localization from "../../../config/locales/localization.fr.yml";
import it_localization from "../../../config/locales/localization.it.yml";

const resources = {
  de: { translation: { ...de_translations.de, ...de_localization.de } },
  fr: { translation: { ...fr_translations.fr, ...fr_localization.fr } },
  it: { translation: { ...it_translations.it, ...it_localization.it } },
};

i18n
  .use(initReactI18next) // passes i18n down to react-i18next
  .init({
    resources,
    lng: "de",
    debug: true,
    keySeparator: ".",

    interpolation: {
      escapeValue: false, // react already safes from xss,
      prefix: "%{",
      suffix: "}",
    },
  });

export default i18n;
