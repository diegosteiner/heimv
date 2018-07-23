<template>
  <a
    :class='calendarDayClass'
    :href='calendarDayLink'
    v-b-popover.hover.bottom="tooltip" variant="primary"
    >{{ date | dayOfMonth }}</a>
</template>

<script>
import moment from "moment";
import "moment-timezone";
export default {
  props: ["date", "occupancies", "disabled", "href"],
  i18n: {
    messages: {
      "de-CH": {
        occupancy: "%{begins_at} - %{ends_at}: %{occupancy_type}",
        occupancy_types: {
          tentative: "provisorisch Besetzt",
          occupied: "definitiv Besetzt",
          closed: "Geschlossen"
        },
        date_format: "DD.MM.Y HH:mm"
      }
    }
  },
  filters: {
    dayOfMonth: function(value) {
      return moment(value).format("D");
    },
    datetime(value) {
      return moment(value).format("Y-MM-DD");
    }
  },
  computed: {
    disabledOrOutOfRange() {
      return (
        this.disabled ||
        this.date.isBefore(moment().subtract(1, "day")) ||
        this.date.isAfter(moment().add(2, "years"))
      );
    },
    tooltip() {
      const date_format = this.$t("date_format");
      if (this.occupancies.some(o => true)) {
        return this.occupancies
          .filter(occupancy => occupancy.occupancy_type != "free")
          .map(occupancy =>
            this.$t("occupancy", {
              begins_at: moment(occupancy.begins_at).format(date_format),
              ends_at: moment(occupancy.ends_at).format(date_format),
              occupancy_type: this.$t(
                `occupancy_types.${occupancy.occupancy_type}`
              )
            })
          )
          .join(", ");
      } else {
        // return "Frei";
      }
    },
    calendarDayClass() {
      return {
        disabled: this.disabledOrOutOfRange,
        "occupied-allday": this.occupancies.some(
          occupancy => occupancy.occupancy_type == "occupied"
        ),
        "tentative-allday": this.occupancies.some(
          occupancy => occupancy.occupancy_type == "tentative"
        ),
        closed: this.occupancies.some(
          occupancy => occupancy.occupancy_type == "closed"
        )
      };
    },
    calendarDayLink() {
      if (this.disabledOrOutOfRange) {
        return false;
      } else {
        return this.href.replace(
          "__DATE__",
          moment(this.date)
            .startOf("day")
            .hour(13)
            .toISOString()
        );
      }
    }
  }
};
</script>

<style>
.calendar-day a {
  margin: 1px;
  padding: 0.25rem;
  border: 1px solid transparent;
}
.calendar-day a.occupied-allday {
  background: #ffa8a8;
  border: 1px solid #e85f5f;
  font-weight: bold;
  color: #9e2e2e;
}
.calendar-day a.tentative-allday {
  background: #ffd1d1;
  border: 1px solid #e69191;
  font-weight: bold;
  color: #9b6161;
}

.calendar-day a.closed {
  background: #ccc;
  border: 1px solid #999;
  color: #999;
}

.calendar-day a.disabled {
  cursor: default;
  opacity: 0.3;
}
</style>

