import 'stylesheets/application'
import 'font-awesome-webpack'
import 'images/logo.svg'
import 'images/logo_hvs.png'

import Rails from 'rails-ujs'
import Turbolinks from 'turbolinks'
import TurbolinksAdapter from 'vue-turbolinks';

import Vue from 'vue/dist/vue.js'
import AppOccupancyCalendar from '../components/calendar/AppOccupancyCalendar.vue'
import BootstrapVue from 'bootstrap-vue'
import VueI18n from 'vue-i18n'

import 'bootstrap/dist/js/bootstrap.bundle'
import 'bootstrap-vue/dist/bootstrap-vue.css'

import Tarifs from 'src/components/tarifs/Tarifs.vue'
import Forms from 'src/forms'

Vue.use(TurbolinksAdapter)
Vue.use(BootstrapVue);
Vue.use(VueI18n)

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
    components: { Tarifs, AppOccupancyCalendar },
    i18n
  });

  $('[data-href]').click(function (e) {
    if ($(e.target).parents('a').length == 0) {
      Turbolinks.visit($(this).data('href'))
    }
  });

  Forms.start();
});

Rails.start();
Turbolinks.start()
