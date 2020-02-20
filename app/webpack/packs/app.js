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
import { locale, i18n, dateLocale } from '../services/i18n'

import 'bootstrap/dist/js/bootstrap.bundle'
import 'bootstrap-vue/dist/bootstrap-vue.css'

import Forms from 'src/forms'

window.jQuery = $;
window.$ = $;
Vue.use(BootstrapVue)
Vue.use(VueI18n)
Vue.config.productionTip = false

$(document).on('DOMContentLoaded', function () {
  // TODO: https://github.com/vuejs/vue-cli/issues/2754
  new Vue({
    components: { AppOccupancyCalendar, AppCalendarInput, AppTimespanInputs, BookingRelevantTime },
    i18n
  }).$mount('#app');

  Forms.start();
});

Rails.start();
