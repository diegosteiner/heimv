import { isSameDay, parseISO } from "date-fns";
import { memo, type ReactElement } from "react";

export type DateElementFactory = (dateString: string, label: (date: Date) => string) => ReactElement;

interface CalendarDateProps {
  dateString: string;
  children?: ReactElement;
}
export const CalendarDate = memo(function CalendarDate({ dateString, children }: CalendarDateProps) {
  const isToday = isSameDay(parseISO(dateString), new Date());
  return (
    <time className={`date${isToday ? " today" : ""}`} dateTime={dateString}>
      {children}
    </time>
  );
});
