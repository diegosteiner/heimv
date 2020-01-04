import 'stylesheets/application'
import 'images/logo.svg'
import $ from 'jquery'

import Rails from 'rails-ujs'

import Vue from 'vue'
import AppOccupancyCalendar from '../components/calendar/AppOccupancyCalendar.vue'
import AppCalendarInput from '../components/calendar/AppCalendarInput.vue'
import AppTimespanInputs from '../components/calendar/AppTimespanInputs.vue'
import BootstrapVue from 'bootstrap-vue'
import VueI18n from 'vue-i18n'
import VueMoment from 'vue-moment'
import moment from "moment";

import 'bootstrap/dist/js/bootstrap.bundle'
import 'bootstrap-vue/dist/bootstrap-vue.css'

import Tarifs from 'src/components/tarifs/Tarifs.vue'
import Forms from 'src/forms'

window.jQuery = $;
window.$ = $;
moment.locale(["de", "fr", "it", "en"]);
Vue.use(VueMoment, moment);

Vue.use(BootstrapVue)
Vue.use(VueI18n)
Vue.prototype.moment = moment;
Vue.config.productionTip = false

$(document).on('DOMContentLoaded', function () {
  const locale = document.querySelector('html').getAttribute('lang')
  const i18n = new VueI18n({
    locale: locale,
    messages: {
      'de': {
        next: 'Später',
        prev: 'Früher'
      }
    }
  });

  // TODO: https://github.com/vuejs/vue-cli/issues/2754
  new Vue({
    el: '#app',
    components: { Tarifs, AppOccupancyCalendar, AppCalendarInput, AppTimespanInputs },
    i18n
  });

  Forms.start();
});

Rails.start();
