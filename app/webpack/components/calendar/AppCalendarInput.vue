<template>
  <div>
    <slot :toggleModal="toggleModal" :date="selectedDate" :formattedDate="formattedDate"></slot>
    <b-modal v-model="showDateModal" hide-footer hide-header>
      <calendar :display-months="2">
        <template slot-scope="date">
          <app-calendar-day
            :active="date.isSame(selectedDate, 'day')"
            :date="date"
            @input="setDate"
            :disabled="false"
          ></app-calendar-day>
        </template>
      </calendar>
    </b-modal>
  </div>
</template>
<script>
import { Calendar } from "vue-occupancies-calendar";
import AppCalendarDay from "./AppCalendarDay.vue";

export default {
  components: { Calendar, AppCalendarDay },
  props: {
    value: {
      default: null
    }
  },
  data() {
    return {
      selectedDate: null,
      showDateModal: false,
      dateFormat: 'DD.MM.Y'
    }
  },
  computed: {
    formattedDate: {
      get() {
        if(this.selectedDate == null) return ""
        return this.moment(this.selectedDate).format(this.dateFormat)
      },
      set(newDate) {
        newDate = moment(newDate, this.dateFormat)
        this.setDate(newDate)
      }
    },
  },
  methods: {
    setDate(newDate) {
      this.showDateModal = false
      newDate = moment(newDate)
      if(newDate.isValid()) { this.selectedDate = newDate }
    },
    toggleModal(e) {
      this.showDateModal = !this.showDateModal
    }
  },
}
</script>
