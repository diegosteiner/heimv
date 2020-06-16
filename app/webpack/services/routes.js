import { stringify } from "qs";    

export const homeCalendarPath = (homeId, params = {}) => `/homes/${homeId}/occupancies/calendar.json?`
export const homeOccupancyAtPath = (homeId, date, params = {}) => `/homes/${homeId}/occupancies/@${date}`
export const newBookingPath = (homeId, params = {}) => `/b/new?${stringify({ home_id: homeId, ...params })}`