import { type PropsWithChildren, use, useTransition } from "react";
import { CalendarViewContext } from "./Calendar";
import { cx } from "@emotion/css";
import { useTranslation } from "react-i18next";

interface CalendarNavProps {
  onPrev(): void;
  onNext(): void;
  onToday?(): void;
  showViews?: boolean;
}

export function CalendarNav({ onPrev, onNext, onToday, showViews = true, children }: PropsWithChildren<CalendarNavProps>) {
  const { view, setView } = use(CalendarViewContext);
  const { t } = useTranslation();

  return (
    <nav className="calendar-nav">
        {(onToday && (
      <div className="actions">
          <button type="button" className="today active" onClick={() => onToday()}>
            {t("calendar.actions.today")}
            {/* <svg viewBox="0 0 24 24" width="24" height="24">
              <rect fill="none" strokeWidth={2} strokeLinecap="round" strokeLinejoin="round" stroke="currentColor" x="3" y="5" width="18" height="16" rx="2" />
              <path fill="none" strokeWidth={2} strokeLinecap="round" strokeLinejoin="round" stroke="currentColor" d="M8 3v4M16 3v4M3 10h18" />
            </svg> */}
          </button>
      </div>
        )) || <div />}
      <div className="pages">
        <button onClick={onPrev} className="prev" type="button" aria-label="Previous period">
          <svg viewBox="0 0 24 24" width="24" height="24">
            <path d="M14.5 6.5 8.5 12l6 5.5" fill="none" strokeWidth={3} strokeLinecap="round" strokeLinejoin="round" stroke="currentColor" />
          </svg>
        </button>
        <div className="label">{children}</div>
        <button onClick={onNext} className="next" type="button" aria-label="Next period">
          <svg viewBox="0 0 24 24" width="24" height="24">
            <path d="M9.5 6.5 15.5 12l-6 5.5" fill="none" strokeWidth={3} strokeLinecap="round" strokeLinejoin="round" stroke="currentColor" />
          </svg>
        </button>
      </div>
      {showViews && <div className="views">
        <button
          type="button"
          name="view"
          value="months"
          className={cx({active: view === "months"})}
          onClick={() => setView?.("months")}
          aria-pressed={view === "months"}
        >
          {t("calendar.view.months")}
        </button>
        <button
          type="button"
          name="view"
          value="year"
          className={cx({active: view === "year"})}
          onClick={() => setView?.("year")}
          aria-pressed={view === "year"}
        >
          {t("calendar.view.year")}
        </button>
      </div> || <div />}
    </nav>
  );
}
