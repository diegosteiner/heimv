<template>
  <calendar :display-months="displayMonths" v-cloak>
    <template slot-scope="date">
      <app-calendar-day
        :date="date"
        :disabled="isOutOfRange(date)"
        :loading="loading"
        :occupancies="occupanciesOfDate(date)"
        @input="handleClick"
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
      loading: true
    };
  },
  mounted() {
    this.loadOccupanciesFromRemote();
  },
  methods: {
    disable(e) {
      this.enabled = false;
    },
    handleClick(e) {
      window.location = this.reservationUrl.replace(
        "__DATE__",
        this.moment(e)
          .startOf("day")
          .hour(13)
          .toISOString()
      );
    },
    loadOccupanciesFromRemote() {
      const vm = this;
      vm.loading = true;

      if (this.occupanciesUrl !== undefined) {
        axios.get(this.occupanciesUrl).then(response => {
          vm.occupancies = response.data;
          vm.loading = false;
        });
      }
    },
    isOutOfRange(date) {
      return (
        date.isBefore(this.moment().subtract(1, "day")) ||
        date.isAfter(this.moment().add(2, "years"))
      );
    },
    occupanciesOfDate(date) {
      const vm = this
      return this.occupancies.filter(function(occupancy) {
        const begins_at = vm.moment.tz(occupancy.begins_at, "UTC");
        const ends_at = vm.moment.tz(occupancy.ends_at, "UTC");
        const startOfDay = vm.moment(date).startOf("day").utc();
        const endOfDay = vm.moment(date).endOf("day").utc();
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
