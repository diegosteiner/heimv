import { cx } from "@emotion/css";
import { type PropsWithChildren, use } from "react";
import { useTranslation } from "react-i18next";
import { CalendarViewContext } from "./Calendar";

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
          <button type="button" className="today active" onClick={() => onToday()} title={t("calendar.actions.today")} >
            <span className="fa fa-calendar" />
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
