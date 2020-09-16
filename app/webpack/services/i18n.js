import i18n from "i18next";
import { initReactI18next } from "react-i18next";


import { de } from 'json-loader!yaml-loader!../../../config/locales/de.yml';
// import fr from 'json-loader!yaml-loader!../../../config/locales/fr.yml';
// import it from 'json-loader!yaml-loader!../../../config/locales/it.yml';

const resources = {
  de: {
    translation: {
      ...de
    }
  }
};

i18n
  .use(initReactI18next) // passes i18n down to react-i18next
  .init({
    resources,
    lng: "de",
    debug: true,
    // keySeparator: false, // we do not use keys in form messages.welcome

    interpolation: {
      escapeValue: false, // react already safes from xss,
      prefix: '%{',
      suffix: '}'
    }
  });

export default i18n;