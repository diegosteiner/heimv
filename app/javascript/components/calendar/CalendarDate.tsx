import { cx } from "@emotion/css";
import { isSameDay, isWeekend, parseISO } from "date-fns";
import { memo, type ReactElement } from "react";

export type DateElementFactory = (dateString: string, label: (date: Date) => string) => ReactElement;

interface CalendarDateProps {
  dateString: string;
  children?: ReactElement;
}
export const CalendarDate = memo(function CalendarDate({ dateString, children }: CalendarDateProps) {
  const date = parseISO(dateString);
  const isToday = isSameDay(date, new Date());

  return (
    <time className={cx({ date: true, today: isToday, weekend: isWeekend(date) })} dateTime={dateString}>
      {children}
    </time>
  );
});
