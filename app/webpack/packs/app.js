import 'stylesheets/application'
import 'images/logo.svg'
import 'images/logo_hvs.png'
import $ from 'jquery';

import Rails from 'rails-ujs'
import Turbolinks from 'turbolinks'
import TurbolinksAdapter from 'vue-turbolinks';

import Vue from 'vue/dist/vue.js'
import AppOccupancyCalendar from '../components/calendar/AppOccupancyCalendar.vue'
import AppCalendarInput from '../components/calendar/AppCalendarInput.vue'
import BootstrapVue from 'bootstrap-vue'
import VueI18n from 'vue-i18n'
import moment from "moment";

import 'bootstrap/dist/js/bootstrap.bundle'
import 'bootstrap-vue/dist/bootstrap-vue.css'

import Tarifs from 'src/components/tarifs/Tarifs.vue'
import Forms from 'src/forms'

window.jQuery = $;
window.$ = $;
moment.locale(["de-CH", "de", "fr-CH", "fr", "it-CH", "it", "en"]);

Vue.use(TurbolinksAdapter)
Vue.use(BootstrapVue)
Vue.use(VueI18n)
Vue.prototype.moment = moment;

$(document).on('turbolinks:load', function () {

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
    components: { Tarifs, AppOccupancyCalendar, AppCalendarInput },
    i18n
  });

  // TODO: ignore buttons as well
  // $('[data-href]').click(function (e) {
  //   if ($(e.target).parents('a').length == 0) {
  //     Turbolinks.visit($(this).data('href'))
  //   }
  // });

  Forms.start();

});

Rails.start();
Turbolinks.start()
