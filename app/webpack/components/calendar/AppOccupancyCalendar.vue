<template>
  <form target="_top" :action="reservationUrl" method="GET" class="calendar-form">
    <input type="hidden" name="booking[home_id]" :value="homeId" />
    <calendar :display-months="displayMonthsScreen" v-if="!loading" v-cloak>
      <template slot-scope="date">
        <app-calendar-day
          :date="date"
          :disabled="isOutOfRange(date)"
          :occupancies="occupanciesOfDate(date)"
        ></app-calendar-day>
      </template>
    </calendar>
    <div class="loading shine" v-else></div>
  </form>
</template>

<script>
import axios from "axios";
import { Calendar } from "vue-occupancies-calendar";
import AppCalendarDay from "./AppCalendarDay.vue";
import { isBefore, isAfter, parseISO, startOfDay, endOfDay, areIntervalsOverlapping } from 'date-fns'

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
      window_from: null,
      window_to: null,
      occupancies: [],
      loading: true
    };
  },
  computed: {
    displayMonthsScreen() {
      return Math.min(this.displayMonths,
       Math.max(Math.floor((window.innerWidth - 100) / 260) * Math.floor((window.innerHeight - 250) / 350), 1))
    }
  },
  mounted() {
    this.loadOccupanciesFromRemote();
  },
  methods: {
    loadOccupanciesFromRemote() {
      const vm = this;
      vm.loading = true;

      if (this.occupanciesUrl !== undefined) {
        axios.get(this.occupanciesUrl).then(response => {
          vm.window_from = parseISO(response.data.window_from),
          vm.window_to = parseISO(response.data.window_to),
          vm.occupancies = response.data.occupancies.map(occupancy => {
            occupancy.begins_at = parseISO(occupancy.begins_at)
            occupancy.ends_at = parseISO(occupancy.ends_at)
            return occupancy
          })
          vm.loading = false;
        });
      }
    },
    isOutOfRange(moment_date) {
      const date = moment_date.toDate()
      return (
        isBefore(date, this.window_from) || isAfter(date, this.window_to)
      );
    },
    occupanciesOfDate(moment_date) {
      const date = moment_date.toDate()
      return this.occupancies.filter(occupancy => {
        return areIntervalsOverlapping(
          { start: occupancy.begins_at, end: occupancy.ends_at},
          { start: startOfDay(date), end: endOfDay(date)}
        )
      });
    }
  }
};
</script>

<style>
.loading {
  height: 36em;
  background-image: url(data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0idXRmLTgiPz4KPHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHN0eWxlPSJiYWNrZ3JvdW5kOiByZ2IoMjQxLCAyNDIsIDI0MykiIHdpZHRoPSI0MyIgaGVpZ2h0PSI0MyIgcHJlc2VydmVBc3BlY3RSYXRpbz0ieE1pZFlNaWQiIHZpZXdCb3g9IjAgMCA0MyA0MyI+PGcgdHJhbnNmb3JtPSJzY2FsZSgwLjE3KSI+PGRlZnM+PGcgaWQ9InN0cmlwZSI+PHBhdGggZD0iTTI1NiAtMTI4IEwzODQgLTEyOCBMLTEyOCAzODQgTC0xMjggMjU2IFoiIGZpbGw9IiNmZmZmZmYiPjwvcGF0aD48cGF0aCBkPSJNMzg0IDAgTDM4NCAxMjggTDEyOCAzODQgTDAgMzg0IFoiIGZpbGw9IiNmZmZmZmYiPjwvcGF0aD48L2c+PC9kZWZzPjxnIHRyYW5zZm9ybT0idHJhbnNsYXRlKDE5Ni4yMDggMCkiPjx1c2UgaHJlZj0iI3N0cmlwZSIgeD0iLTI1NiIgeT0iMCI+PC91c2U+PHVzZSBocmVmPSIjc3RyaXBlIiB4PSIwIiB5PSIwIj48L3VzZT48YW5pbWF0ZVRyYW5zZm9ybSBhdHRyaWJ1dGVOYW1lPSJ0cmFuc2Zvcm0iIHR5cGU9InRyYW5zbGF0ZSIga2V5VGltZXM9IjA7MSIgcmVwZWF0Q291bnQ9ImluZGVmaW5pdGUiIGR1cj0iMC41cyIgdmFsdWVzPSIwIDA7IDI1NiAwIj48L2FuaW1hdGVUcmFuc2Zvcm0+PC9nPjwvZz48L3N2Zz4K);
}

.calendar-form {
  font-size: 0.8rem;
}
</style>
