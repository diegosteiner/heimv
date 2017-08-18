$(document).on('turbolinks:load', function () {
    var container = $('.form-group.booking_customer');
    var target = $('.new_customer_fields');

    target.find('.required').attr('required', false);

    container.children('select').on("select2:select", function (e) {
        if (e.params.data.element === undefined) {
            $(this).attr('required', false);
            target.find('.required').attr('required', true);
            // container.children('.select2').hide();
            target.show();

            var customerData = e.params.data.text.split(',');
            var customerName = (customerData.shift() || '').split(' ');
            var customerArea = (customerData.pop() || '').split(' ');

            target.find('#booking_customer_attributes_last_name').val(customerName.pop());
            target.find('#booking_customer_attributes_first_name').val(customerName.join(' '));
            target.find('#booking_customer_attributes_city_name').val(customerArea.pop());
            target.find('#booking_customer_attributes_zipcode').val(customerArea.join(' '));
            target.find('#booking_customer_attributes_street_address').val(customerData.join(' '));
        } else {
            $(this).attr('required', true);
            target.find('.required').attr('required', false);
            target.hide();
        }
    });
});
