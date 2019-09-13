import { format, startOfMonth } from 'date-fns'

function initialize(targetElement, firstDate, monthsCount, dayCallback) {

}

function months(firstDate, monthsCount) {
    const months = []
    let date = startOfMonth(firstDate)
    for(let i = 0; i < monthsCount; i++) {
        months.add(addMonths(firstDate, i))
    } 
}

export default { initialize }
