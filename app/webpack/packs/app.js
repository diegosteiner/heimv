import Turbolinks from 'turbolinks'
import TurbolinksAdapter from 'vue-turbolinks';

// import 'popper.js/dist/popper.js'
import Vue from 'vue/dist/vue.js'
import BootstrapVue from 'bootstrap-vue'
import VueI18n from 'vue-i18n'
// import VueLocalStorage from "vue-localstorage";

import 'bootstrap/dist/js/bootstrap.bundle'
import 'bootstrap-vue/dist/bootstrap-vue.css'

Vue.use(TurbolinksAdapter)
Vue.use(BootstrapVue);
Vue.use(VueI18n)
// Vue.use(VueLocalStorage, { bind: true });

$(document).on('turbolinks:load', function () {

  // const locale = document.querySelector('html').getAttribute('lang')
  // const i18n = new VueI18n({
  //   locale: locale,
  //   messages: {}
  // });

  new Vue({
    el: '#app',
    components: {},
    // i18n
  });
});

Turbolinks.start()
