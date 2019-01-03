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

    // static initializePills() {
    //     for (var select of $('select.input-pills')) {
    //         select = $(select)
    //         $(select).hide()
    //         let pills = $('<ul class="nav nav-pills"></ul>')

    //         for (var option of select.children('option')) {
    //             let pill = $('<li class="nav-item"></li>')
    //             let pillLink = $('<a href="#" class="nav-link"></a>')
    //             pillLink.html($(option).html())
    //             pill.append(pillLink)
    //             pill.click(() => {
    //                 select.value($(option).value())
    //             })
    //             pills.append(pill)
    //         }
    //         select.after(pills)
    //     }
    // }
}
