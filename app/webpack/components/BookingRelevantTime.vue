<template>
  <time
    v-if="relevant_time != null"
    :datetime="relevant_time"
  >{{ $t(`booking_strategies.default.states.${booking_state}.relevant_time_label`) }}: {{ relevant_time | moment("from") }}</time>
</template>

<script>
export default {
  props: {
    relevant_time: String,
    booking_state: String
  },
}
</script>

<style>
</style>
