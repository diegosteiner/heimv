// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, or any plugin's
// vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery3
//= require jquery_ujs
//= require turbolinks
//= require bootstrap/dist/js/bootstrap.bundle
//= require flatpickr/dist/flatpickr
//= require flatpickr/dist/l10n/de
//= require select2/dist/js/select2
//= require_tree .

$(document).on('turbolinks:load', function() {
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
        $(target).find('.required').attr('required', false);
    });

    $('select[data-new-tag-triggers]').on("select2:select", function(e) {
        if (e.params.data.element === undefined) {
            var target = $(this).data('new-tag-triggers');
            $(target).show();
            $(this).attr('required', false);
            $(target).find('.required').attr('required', true);
            $(this).hide();
        } else {
            console.log(e.params.data);
        }
    });
});
