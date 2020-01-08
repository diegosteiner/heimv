import 'stylesheets/application'
import 'images/logo.svg'
import $ from 'jquery'

import Rails from 'rails-ujs'

import Vue from 'vue'
import AppOccupancyCalendar from '../components/calendar/AppOccupancyCalendar.vue'
import AppCalendarInput from '../components/calendar/AppCalendarInput.vue'
import AppTimespanInputs from '../components/calendar/AppTimespanInputs.vue'
import BookingRelevantTime from '../components/BookingRelevantTime.vue'
import BootstrapVue from 'bootstrap-vue'
import VueI18n from 'vue-i18n'
import VueMoment from 'vue-moment'
import moment from 'moment'
import 'moment/locale/de-ch'
import 'moment/locale/fr-ch'
import 'moment/locale/it-ch'
import i18n from '../services/i18n'

import 'bootstrap/dist/js/bootstrap.bundle'
import 'bootstrap-vue/dist/bootstrap-vue.css'

import Tarifs from 'components/tarifs/Tarifs.vue'
import Forms from 'src/forms'

window.jQuery = $;
window.$ = $;
Vue.use(BootstrapVue)
Vue.use(VueI18n)
Vue.use(VueMoment, { moment });
Vue.config.productionTip = false

$(document).on('DOMContentLoaded', function () {
  const locale = document.querySelector('html').getAttribute('lang')
  Vue.moment.locale([`${locale}-ch`, locale, 'en'])

  // TODO: https://github.com/vuejs/vue-cli/issues/2754
  new Vue({
    components: { Tarifs, AppOccupancyCalendar, AppCalendarInput, AppTimespanInputs, BookingRelevantTime },
    i18n
  }).$mount('#app');

  Forms.start();
});

Rails.start();
