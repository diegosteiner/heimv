import Vue from 'vue'
import VueI18n from 'vue-i18n';

import de from 'json-loader!yaml-loader!../../../config/locales/de.yml';
// import fr from 'json-loader!yaml-loader!../../../config/locales/fr.yml';
// import it from 'json-loader!yaml-loader!../../../config/locales/it.yml';

Vue.use(VueI18n)

const locale = document.querySelector('html').getAttribute('lang')
const messages = {
  // ...it,
  ...de,
  // ...fr,
}
export default new VueI18n({
  locale: locale,
  messages: messages
})
