import { memo } from "react";

export type DateElementFactory = (dateString: string, label: (date: Date) => string) => React.ReactElement;

interface CalendarDateProps {
  dateString: string;
  children?: React.ReactElement;
}
export const CalendarDate = memo(function CalendarDate({ dateString, children }: CalendarDateProps) {
  return (
    <time className="date" dateTime={dateString}>
      {children}
    </time>
  );
});
