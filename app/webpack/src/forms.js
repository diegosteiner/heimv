import moment from 'moment';

export default class {
    static start() {
        $('.form-check-input').addClass('form-check-control')
        $('.form-group.is-invalid .form-control').addClass('is-invalid')

        $('.custom-file-input').on('change', function () {
            let fileName = $(this).val();
            $(this).next('.custom-file-label').html(fileName);
        })

        $('[data-range-role="unit"]').each(function () {
            const unit = $(this);
            unit.find('[data-range-role="start"]').on('change', function () {
                unit.find('[data-range-role="end"]').val($(this).val());
            })
        })
    }
}
