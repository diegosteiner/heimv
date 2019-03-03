<template>
  <div>
    <b-form-group :label="label" :labelClass="required ? 'required' : ''">
      <b-input-group>
        <b-form-input v-model.lazy="formattedDate"/>
        <b-btn slot="append" variant="primary" @click="toggleModal">
          <i class="fa fa-calendar"></i>
        </b-btn>
        <input type="hidden" :name="name" :value="isoDate">
      </b-input-group>
    </b-form-group>
    <b-modal v-model="showDateModal" size="sm" lazy hide-footer hide-header>
      <calendar :display-months="1" :firstDate="selectedDate">
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
    value: null,
    label: null,
    name: null,
    required: false
  },
  data() {
    const parsedDate = this.moment(this.value, "YYYY-MM-DD HH:mm Z")

    return {
      selectedDate: parsedDate.isValid() ? parsedDate : null,
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
        newDate = this.moment(newDate, this.dateFormat)
        this.setDate(newDate)
      }
    },
    isoDate() {
      if(this.selectedDate == null) return ""
      return this.moment(this.selectedDate).format('Y-MM-DD')
    }
  },
  methods: {
    setDate(newDate) {
      this.showDateModal = false
      newDate = this.moment(newDate)
      if(newDate.isValid()) {
        this.selectedDate = newDate
        this.$emit('input', newDate)
       }
    },
    toggleModal(e) {
      this.showDateModal = !this.showDateModal
    }
  },
}
</script>
