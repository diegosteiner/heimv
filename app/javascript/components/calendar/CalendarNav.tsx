import { type PropsWithChildren, use } from "react";
import { CalendarViewContext } from "./Calendar";

interface CalendarNavProps {
  onPrev(): void;
  onNext(): void;
  onToday(): void;
}

export function CalendarNav({ onPrev, onNext, onToday, children }: PropsWithChildren<CalendarNavProps>) {
  const { view, setView } = use(CalendarViewContext);

  return (
    <nav className="calendar-nav">
      <div className="actions">
        {(onToday && (
          <button type="button" className="today active" onClick={() => onToday()}>
            <svg width="48" height="48" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48" fill="currentColor">
              <rect width="40" height="8" x="4" y="4" rx="2" />
              <rect width="40" height="36" x="4" y="4" rx="2" fill="none" stroke="currentColor" strokeWidth="3" />
            </svg>
          </button>
        )) || <div />}
        <button type="button">
          <span className="fa fa-question-circle" />
        </button>
      </div>
      <div className="pages">
        <button onClick={onPrev} className="prev" type="button">
          <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48" fill="currentColor">
            <path d="M30 36L18 24l12-12" stroke="currentColor" />
          </svg>
        </button>
        <div className="label">{children}</div>
        <button onClick={onNext} className="next" type="button">
          <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48" fill="currentColor">
            <path d="M18 36l12-12-12-12" stroke="currentColor" />
          </svg>
        </button>
      </div>
      <div className="views">
        <button type="button" className={view === "months" ? "active" : ""} onClick={() => setView?.("months")}>
          <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48" fill="currentColor">
            <rect width="12" height="12" x="6" y="6" />
            <rect width="12" height="12" x="26" y="6" />
            <rect width="12" height="12" x="6" y="26" />
            <rect width="12" height="12" x="26" y="26" />
          </svg>
        </button>
        <button type="button" className={view === "year" ? "active" : ""} onClick={() => setView?.("year")}>
          <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48" fill="currentColor">
            <rect width="36" height="4" x="6" y="8" />
            <rect width="36" height="4" x="6" y="20" />
            <rect width="36" height="4" x="6" y="32" />
          </svg>
        </button>
      </div>
    </nav>
  );
}
