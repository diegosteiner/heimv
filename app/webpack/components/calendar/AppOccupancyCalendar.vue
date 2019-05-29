<template>
  <form target="_top" :action="reservationUrl" method="GET">
    <input type="hidden" name="booking[home_id]" :value="homeId">
    <calendar :display-months="displayMonths" v-cloak>
      <template slot-scope="date">
        <app-calendar-day
          :date="date"
          :disabled="isOutOfRange(date)"
          :loading="loading"
          :occupancies="occupanciesOfDate(date)"
        ></app-calendar-day>
      </template>
    </calendar>
  </form>
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
    "displayMonths",
    "homeId"
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
      const moment = this.moment
      return this.occupancies.filter(function(occupancy) {
        const begins_at = moment(occupancy.begins_at, moment.ISO_8601);
        const ends_at = moment(occupancy.ends_at, moment.ISO_8601);
        const startOfDay = moment(date).startOf("day");
        const endOfDay = moment(date).endOf("day");
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
