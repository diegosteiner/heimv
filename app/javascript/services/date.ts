import { compareAsc, formatISO, isValid, parseISO } from "date-fns";

export function parseISOorUndefined(value: string | Date | undefined): Date | undefined {
  const date = typeof value === "string" ? parseISO(value) : value;
  return isValid(date) ? date : undefined;
}

export function formatISOorUndefined(value: string | Date | undefined): string | undefined {
  if (!value) return undefined;
  if (typeof value === "string") return value;

  return formatISO(value);
}

export function toInterval(dates: Date[]) {
  const [start, end] = dates.sort(compareAsc);
  return { start, end };
}

export const formatDate = new Intl.DateTimeFormat("de-CH", {
  year: "numeric",
  month: "2-digit",
  day: "2-digit",
  hour: "numeric",
  minute: "numeric",
  hour12: false,
}).format;

export function parseDate(value: Date | string | undefined, defaultDate: Date = new Date()) {
  if (!value) return defaultDate;

  const date = typeof value === "string" ? parseISO(value) : value;
  if (isValid(date)) return date;
  return defaultDate;
}

export const monthNameFormatter = new Intl.DateTimeFormat(document.documentElement.lang, {
  month: "long",
});

export const weekdayNameFormatter = new Intl.DateTimeFormat(document.documentElement.lang, {
  weekday: "short",
});

export const materializedWeekdays = [1, 2, 3, 4, 5, 6, 7].map((i) => weekdayNameFormatter.format(new Date(2021, 2, i)));
