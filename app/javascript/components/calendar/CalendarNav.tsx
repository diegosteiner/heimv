import { useContext } from "react";
import { CalendarViewContext } from "./OccupancyCalendar";

interface CalendarNavProps {
  onPrev(): void;
  onNext(): void;
  children?: React.ReactNode;
}

export function CalendarNav({ onPrev, onNext, children }: CalendarNavProps) {
  const { view, setView } = useContext(CalendarViewContext);

  return (
    <nav className="calendar-nav">
      <div className="pages">
        <button onClick={onPrev} className="prev" type="button">
          ←
        </button>
        <button onClick={onNext} className="next" type="button">
          →
        </button>
      </div>
      <div className="label">{children}</div>
      <div className="views">
        <button className={view == "months" ? "active" : ""} onClick={() => setView && setView("months")}>
          ⚏
        </button>
        <button className={view == "year" ? "active" : ""} onClick={() => setView && setView("year")}>
          ⚌
        </button>
      </div>
    </nav>
  );
}
