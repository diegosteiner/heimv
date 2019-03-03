<script>
import AppCalendarInput from './AppCalendarInput.vue'

export default {
  components: { AppCalendarInput },
  mounted() {
    const begins_at_date_component = this.$refs.begins_at_date
    const ends_at_date_component = this.$refs.ends_at_date
    begins_at_date_component.$on('input', date => { ends_at_date_component.selectedDate = date })
  },
}
</script>
