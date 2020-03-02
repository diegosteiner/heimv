import Vue from 'vue'
import VueI18n from 'vue-i18n';

import de from 'json-loader!yaml-loader!../../../config/locales/de.yml';
// import fr from 'json-loader!yaml-loader!../../../config/locales/fr.yml';
// import it from 'json-loader!yaml-loader!../../../config/locales/it.yml';

Vue.use(VueI18n)

const locale = document.querySelector('html').getAttribute('lang')
const messages = {
  // ...it,
  'de-CH': de.de,
  // ...fr,
}
const dateTimeFormats = {
  'de-CH': {
    short: {
      year: 'numeric', month: '2-digit', day: '2-digit'
    },
    shortDate: {
      year: 'numeric', month: '2-digit', day: '2-digit'
    },
    shortTime: {
      year: 'numeric', month: '2-digit', day: '2-digit', hour: 'numeric', minute: 'numeric'
    },
    long: {
      year: 'numeric', month: 'short', day: 'numeric',
      weekday: 'short', hour: 'numeric', minute: 'numeric'
    }
  },
}
import { de as x, frCH, itCH } from 'date-fns/locale'
const i18n = new VueI18n({
  locale: locale,
  messages: messages,
  dateTimeFormats
})

export { i18n, locale, x }
