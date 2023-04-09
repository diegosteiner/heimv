interface CalendarNavProps {
  onPrev(): void;
  onNext(): void;
  children?: React.ReactNode;
}

export function CalendarNav({ onPrev, onNext, children }: CalendarNavProps) {
  return (
    <nav className="calendar-nav">
      <button onClick={onPrev} className="prev" type="button">
        ←
      </button>
      {children}
      <button onClick={onNext} className="next" type="button">
        →
      </button>
    </nav>
  );
}
