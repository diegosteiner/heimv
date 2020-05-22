import 'stylesheets/application'
import 'images/logo.svg'
import $ from 'jquery'
import Rails from 'rails-ujs'
import Forms from 'src/forms'
import '../services/i18n'

import 'bootstrap/dist/js/bootstrap.bundle'

window.jQuery = $;
window.$ = $;

$(document).on('DOMContentLoaded', function () {

  Forms.start();
});

Rails.start();

// Support component names relative to this directory:
var componentRequireContext = require.context("components", true);
var ReactRailsUJS = require("react_ujs");
ReactRailsUJS.useContext(componentRequireContext);