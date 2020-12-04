import * as React from 'react';
import {
  OccupancyCalendarContext,
  ContextType,
} from './OccuancyCalendarContext';
import classNames from 'classnames';
import * as styles from './OccupancyCalendar.module.scss';
import Popover from 'react-bootstrap/Popover';
import OverlayTrigger from 'react-bootstrap/OverlayTrigger';
import { formatISO, parseISO } from 'date-fns/esm';
import { useTranslation } from 'react-i18next';
import { Occupancy } from '../../models/occupancy';

const formatDate = new Intl.DateTimeFormat('de-CH', {
  year: 'numeric',
  month: '2-digit',
  day: '2-digit',
  hour: 'numeric',
  minute: 'numeric',
  hour12: false,
}).format;

interface OccupancyCalendarDayInContextProps {
  date?: Date;
  onClick(event: React.MouseEvent): void;
}

export const OccupancyCalendarDayInContext: React.FC<OccupancyCalendarDayInContextProps> = ({
  date,
  onClick,
}) => {
  const { loading, occupancyCalendarState } = React.useContext<ContextType>(
    OccupancyCalendarContext,
  );
  const occupancyDate =
    date &&
    occupancyCalendarState.occupancyDates &&
    occupancyCalendarState.occupancyDates[
      formatISO(date, { representation: 'date' })
    ];
  const flags = (occupancyDate && occupancyDate.flags) || [];
  const disableCallback = () =>
    loading || !occupancyDate || flags.includes('outOfWindow');
  const classNameCallback = () => flags.map((flag) => styles[flag]);

  return (
    <OccupancyCalendarDay
      classNameCallback={classNameCallback}
      disableCallback={disableCallback}
      occupancies={(occupancyDate && occupancyDate.occupancies) || []}
      {...{ date, onClick }}
    ></OccupancyCalendarDay>
  );
};

interface OccupancyCalendarDayProps {
  date?: Date;
  onClick(event: React.MouseEvent): void;
  occupancies?: Occupancy[];
  classNameCallback?(date: Date): string[];
  disableCallback?(date: Date): boolean;
}

export const OccupancyCalendarDay: React.FC<OccupancyCalendarDayProps> = ({
  date,
  onClick,
  occupancies = [],
  classNameCallback,
  disableCallback,
}) => {
  if (!date) return <></>;

  const disabled = disableCallback && disableCallback(date);
  const className = [
    styles.calendarDate,
    ...Array.from((classNameCallback && classNameCallback(date)) || []),
  ];

  const button = (
    <button
      type="button"
      disabled={disabled}
      onClick={onClick}
      value={formatISO(date, { representation: 'date' })}
      className={classNames(className)}
    >
      {date.getDate()}
    </button>
  );

  if (occupancies.length <= 0) return button;

  const { t } = useTranslation();
  const popover = (
    <Popover id="popover-basic">
      <Popover.Content>
        {occupancies.map((occupancy) => {
          const deadline = occupancy.deadline && parseISO(occupancy.deadline);

          return (
            <dl
              key={`${formatISO(date, { representation: 'date' })}-${
                occupancy.id
              }`}
            >
              <dt>
                {formatDate(occupancy.begins_at)} -{' '}
                {formatDate(occupancy.ends_at)}
              </dt>
              <dd>
                <span>
                  {occupancy.ref}:{' '}
                  {t(
                    `activerecord.enums.occupancy.occupancy_type.${occupancy.occupancy_type}`,
                  )}
                </span>
                {deadline && (
                  <span>
                    {' '}
                    ({t('until')} {formatDate(deadline)})
                  </span>
                )}
              </dd>
            </dl>
          );
        })}
      </Popover.Content>
    </Popover>
  );

  return (
    <OverlayTrigger trigger={['focus', 'hover']} overlay={popover}>
      {button}
    </OverlayTrigger>
  );
};
