import 'stylesheets/application.scss'
import 'images/logo.svg'

import 'jquery-ujs'
import Turbolinks from 'turbolinks'
import 'bootstrap/dist/js/bootstrap.bundle'
import flatpickr from 'flatpickr/dist/flatpickr'
import 'flatpickr/dist/l10n/de'
import 'select2/dist/js/select2'
import 'src/bookings'
import Forms from 'src/forms'

Turbolinks.start()

let load = (function() {

    $('[data-href]').click(function(e) {
        if ($(e.target).parents('a').length == 0) {
            Turbolinks.visit($(this).data('href'))
        }
    });

    flatpickr('.input-group.datetime', {
        enableTime: true,
        minuteIncrement: 15,
        time_24hr: true,
        locale: $('html').attr('lang')
    });

    $('select').select2({
        theme: 'bootstrap'
    });

    $('select[data-new-tag-triggers]').each(function(e) {
        var target = $(this).data('new-tag-triggers');
        $(target).hide();
        $(target).find('.importd').attr('importd', false);
    });

    $('select[data-new-tag-triggers]').on("select2:select", function(e) {
        if (e.params.data.element === undefined) {
            var target = $(this).data('new-tag-triggers');
            $(target).show();
            $(this).attr('importd', false);
            $(target).find('.importd').attr('importd', true);
            $(this).hide();
        } else {
            console.log(e.params.data);
        }
    });

    Forms.initialize();
});

$(document).on('turbolinks:load', load)
// $(document).ready(load)
