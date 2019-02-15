<template>
  <calendar :display-months="displayMonths" v-cloak>
    <template slot-scope="date">
      <app-calendar-day
        :date="date"
        :disabled="!loaded && isOutOfRange(date)"
        :occupancies="occupanciesOfDate(date)"
      ></app-calendar-day>
    </template>
  </calendar>
</template>

<script>
import axios from "axios";
import { Calendar } from "vue-occupancies-calendar";
import AppCalendarDay from "./AppCalendarDay.vue";

export default {
  props: [
    "occupanciesUrl",
    "reservationUrl",
    "occupanciesJson",
    "displayMonths"
  ],
  components: { Calendar, AppCalendarDay },
  data: function() {
    return {
      occupancies: [],
      loaded: false
    };
  },
  mounted() {
    this.loadOccupanciesFromRemote();
  },
  methods: {
    disable(e) {
      this.enabled = false;
    },
    loadOccupanciesFromRemote() {
      const vm = this;
      if (this.occupanciesUrl !== undefined) {
        axios.get(this.occupanciesUrl).then(response => {
          vm.occupancies = response.data;
          vm.loaded = true;
        });
      }
    },
    isOutOfRange(date) {
      return (
        date.isBefore(moment().subtract(1, "day")) ||
        date.isAfter(moment().add(2, "years"))
      );
    },
    occupanciesOfDate(date) {
      return this.occupancies.filter(function(occupancy) {
        const begins_at = moment.tz(occupancy.begins_at, "UTC");
        const ends_at = moment.tz(occupancy.ends_at, "UTC");
        const startOfDay = moment(date).startOf("day").utc();
        const endOfDay = moment(date).endOf("day").utc();
        return (
          startOfDay.isBetween(begins_at, ends_at, "hours", "[)") ||
          endOfDay.isBetween(begins_at, ends_at, "hours", "(]") ||
          (begins_at.isBetween(startOfDay, endOfDay, "hours", "(]") &&
          ends_at.isBetween(startOfDay, endOfDay, "hours", "(]"))
        );
      });
    }
  }
};
</script>

<style>
.calendar-week {
  font-size: 0.8rem;
}

.calendar-days {
  height: calc(36px * 6);
  align-content: flex-start;
}
</style>
