import { parseISO, isSameDay } from "date-fns";
import { memo } from "react";

export type DateElementFactory = (dateString: string, label: (date: Date) => string) => React.ReactElement;

interface CalendarDateProps {
  dateString: string;
  children?: React.ReactElement;
}
export const CalendarDate = memo(function CalendarDate({ dateString, children }: CalendarDateProps) {
  const isToday = isSameDay(parseISO(dateString), new Date());
  return (
    <time className={`date${isToday ? " today" : ""}`} dateTime={dateString}>
      {children}
    </time>
  );
});
