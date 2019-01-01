<template>
  <calendar :display-months="displayMonths">
    <template slot-scope="date">
      <app-calendar-day
        :date="date"
        :disabled="!loaded"
        :occupancies="occupanciesOfDate(date)"
        :href="reservationUrl"
      ></app-calendar-day>
    </template>
  </calendar>
</template>

<script>
import moment from "moment";
import "moment-timezone";
moment.locale(["de-CH", "de", "fr-CH", "fr", "it-CH", "it", "en"]);
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
    occupanciesOfDate(date) {
      return this.occupancies.filter(function(occupancy) {
        let begins_at = moment.tz(occupancy.begins_at, "UTC");
        let ends_at = moment.tz(occupancy.ends_at, "UTC");
        return (
          date.startOf("day").isBetween(begins_at, ends_at, "hours", "[)") ||
          date.endOf("day").isBetween(begins_at, ends_at, "hours", "(]")
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

.calendar-month {
  max-width: initial;
  min-width: 182px !important;
}
</style>
