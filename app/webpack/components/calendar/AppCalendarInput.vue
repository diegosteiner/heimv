<template>
  <div>
    <b-form-group :label="label" :labelClass="required ? 'required' : ''">
      <b-input-group>
        <b-form-input :value="formattedDate" @change="setDate" :disabled="disabled" />
        <b-btn slot="append" variant="primary" @click="toggleModal">
          <i class="fa fa-calendar"></i>
        </b-btn>
        <input type="hidden" :name="name" :value="isoDate" />
      </b-input-group>
    </b-form-group>
    <b-modal v-model="showDateModal" size="sm" hide-footer hide-header>
      <calendar :firstDate="selectedDate.toISOString()" :displayMonths="1">
        <template v-slot="{ date }">
          <app-calendar-day
            :locale="$t('occupancy_calendar')"
            :active="isActive(date)"
            :date="date"
            :disabled="false"
            @input="setDate"
          ></app-calendar-day>
        </template>
      </calendar>
    </b-modal>
  </div>
</template>
<script>
import { Calendar } from "vue-occupancies-calendar";
import AppCalendarDay from "./AppCalendarDay.vue";
import { formatISO, format, parse, parseISO, startOfDay, isDate, isValid, isEqual } from 'date-fns'

const dateFormat = 'dd.MM.yyyy';

export default {
  components: { Calendar, AppCalendarDay },
  props: {
    value: null,
    label: null,
    name: null,
    disabled: false,
    required: false
  },
  data() {
    const value = parseISO(this.value)
    return {
      selectedDate: (isDate(value) && isValid(value)) ? value : new Date(),
      showDateModal: false,
    }
  },
  computed: {
    formattedDate() {
      if(isDate(this.selectedDate)) return format(this.selectedDate, dateFormat);
    },
    isoDate() {
      if(isDate(this.selectedDate)) return formatISO(this.selectedDate, { representation: 'date'});
    }
  },
  methods: {
    setDate(date) {
      this.showDateModal = false

      if(!isValid(date)) return;
      this.selectedDate = date
      this.$emit('input', date)
    },
    toggleModal() {
      if(!this.disabled) this.showDateModal = !this.showDateModal;
    },
    isActive(date) {
      return isEqual(startOfDay(date), startOfDay(this.selectedDate))
    }
  },
}
</script>
<style lang="scss" scoped>
/deep/ app-calendar-day:hover {
  background-color: red;
}
</style>
