import React from 'react';
import TimeAgo from 'react-timeago';
import { useTranslation } from 'react-i18next';

const BookingRelevantTime = (booking_state, date) => {
  const { t } = useTranslation();

  return (
    <span>
      {t(`booking_flows.default.states.${booking_state}.relevant_time_label`)}:<TimeAgo date={date}></TimeAgo>
    </span>
  );
};

export default BookingRelevantTime;
