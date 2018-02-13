export default class {
    static initialize() {
        $('.form-check-input').addClass('form-check-control').removeClass('form-check-input')
        $('.form-group.is-invalid .form-control').addClass('is-invalid')
    }

    static initializePills() {
        for (var select of $('select.input-pills')) {
            select = $(select)
            $(select).hide()
            let pills = $('<ul class="nav nav-pills"></ul>')

            for (var option of select.children('option')) {
                let pill = $('<li class="nav-item"></li>')
                let pillLink = $('<a href="#" class="nav-link"></a>')
                pillLink.html($(option).html())
                pill.append(pillLink)
                pill.click(() => {
                    select.value($(option).value())
                })
                pills.append(pill)
            }
            select.after(pills)
        }
    }
}
