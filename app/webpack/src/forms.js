import moment from 'moment';

export default class {
    static start() {
        $('input[name=authenticity_token]').val($('meta[name=csrf-token]').attr('content'))

        $('.form-check-input').addClass('form-check-control')
        $('.form-group.is-invalid .form-control').addClass('is-invalid')

        $('.custom-file-input').on('change', function () {
            let fileName = $(this).val();
            $(this).next('.custom-file-label').html(fileName);
        })

        $('[data-range-role="unit"]').each(function () {
            const unit = $(this);
            const startInput = unit.find('[data-range-role="start"]');
            const endInput = unit.find('[data-range-role="end"]');
            const updateEndInput = function (value) {
                if (!endInput.val()) {
                    endInput.val(value);
                }
            }
            startInput.on('change', function () { updateEndInput($(this).val()) });
            updateEndInput(startInput.val());
        })


    }
}
