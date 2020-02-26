<template>
  <time
    v-if="relevant_time != null"
    :datetime="relevant_time"
  >{{ $t(`booking_strategies.default.states.${booking_state}.relevant_time_label`) }}: {{ $d(date, 'long') }}</time>
</template>

<script>

import { parseISO } from 'date-fns'

export default {
  props: {
    relevant_time: String,
    booking_state: String
  },
  data() {
    return {
      date: parseISO(this.relevant_time)
    }
  }
}
</script>

<style>
</style>
