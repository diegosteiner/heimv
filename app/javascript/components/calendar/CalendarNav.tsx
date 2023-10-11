import { useContext } from "react";
import { CalendarViewContext } from "./Calendar";

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
            <path d="M87 40H40V20L11 50l29 30V60h47l2-2V42Z" />
          </svg>
        </button>
        <div className="label">{children}</div>
        <button onClick={onNext} className="next" type="button">
          <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100">
            <path d="M13 40h47V20l29 30-29 30V60H13l-2-2V42Z" />
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
