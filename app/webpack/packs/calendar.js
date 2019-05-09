import Vue from 'vue/dist/vue.js'
import AppOccupancyCalendar from '../components/calendar/AppOccupancyCalendar.vue'
import VueI18n from 'vue-i18n'
import moment from "moment";

import 'dayjs/locale/de'
import dayjs from 'dayjs'

moment.locale(["de-CH", "de", "fr-CH", "fr", "it-CH", "it", "en"]);
dayjs.locale('de')

Vue.use(VueI18n)
Vue.prototype.moment = moment;

document.addEventListener('DOMContentLoaded', function () {

  const locale = document.querySelector('html').getAttribute('lang')
  const i18n = new VueI18n({
    locale: locale,
    messages: {
      'de-CH': {
        next: 'Später',
        prev: 'Früher'
      }
    }
  });

  new Vue({
    el: '#app',
    components: { AppOccupancyCalendar },
    i18n
  });
});
