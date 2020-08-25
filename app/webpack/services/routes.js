import { stringify } from "qs";

export const homeCalendarPath = (baseUrl, homeId, params = {}) => `${baseUrl}/homes/${homeId}/occupancies/calendar.json?`
export const homeOccupancyAtPath = (baseUrl, homeId, date, params = {}) => `${baseUrl}/homes/${homeId}/occupancies/@${date}`