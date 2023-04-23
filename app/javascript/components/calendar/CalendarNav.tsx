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
      <div className="views"></div>
      <div className="pages">
        <button onClick={onPrev} className="prev" type="button">
          <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100">
            <path id="prev" d="M87 40H36V20L11 50l25 30V60h51l2-2V42l-2-2z" />
          </svg>
        </button>
        <div className="label">{children}</div>
        <button onClick={onNext} className="next" type="button">
          <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100">
            <path id="next" d="M13 40h51V20l25 30-25 30V60H13l-2-2V42l2-2z" />
          </svg>
        </button>
      </div>
      <div className="views">
        <button className={view == "months" ? "active" : ""} onClick={() => setView && setView("months")}>
          <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100">
            <rect width="33" height="33" x="13" y="13" ry="3" />
            <rect width="33" height="33" x="56" y="13" ry="3" />
            <rect width="33" height="33" x="13" y="56" ry="3" />
            <rect width="33" height="33" x="56" y="56" ry="3" />
          </svg>
        </button>
        <button className={view == "year" ? "active" : ""} onClick={() => setView && setView("year")}>
          <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100">
            <rect width="75" height="15" x="13" y="13" ry="2" />
            <rect width="75" height="15" x="13" y="40" ry="2" />
            <rect width="75" height="15" x="13" y="69" ry="2" />
          </svg>
        </button>
      </div>
    </nav>
  );
}
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100">
  <path id="next" d="M13 40h51V20l25 30-25 30V60H13l-2-2V42l2-2z" />
  <path id="prev" d="M87 40H36V20L11 50l25 30V60h51l2-2V42l-2-2z" />
</svg>;
