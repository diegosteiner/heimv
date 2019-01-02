<template>
  <a
    :class="calendarDayClass"
    :href="calendarDayLink"
    v-b-popover.hover.bottom="tooltip"
    variant="primary"
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
    isOutOfRange() {
      return (
        this.date.isBefore(moment().subtract(1, "day")) ||
        this.date.isAfter(moment().add(2, "years"))
      );
    },
    tooltip() {
      const date_format = this.$t("date_format");
      if (this.occupancies.length) {
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
      }
    },
    calendarDayClass() {
      if(this.disabled || this.isOutOfRange) {
        return ["disabled"];
      }

      return this.occupancies.map((occupancy) => {
        let begins_at = moment.tz(occupancy.begins_at, "UTC");
        let ends_at = moment.tz(occupancy.ends_at, "UTC");

        if(ends_at.isBetween(moment(this.date.startOf("day")), moment(this.date.hour(12)), "minutes", "[)")) {
          return `${occupancy.occupancy_type}-forenoon`;
        }
        if(begins_at.isBetween(moment(this.date.hour(10)), moment(this.date.endOf("day")), "minutes", "(]")) {
          return `${occupancy.occupancy_type}-afternoon`;
        }
        return `${occupancy.occupancy_type}-fullday`;
      })
    },
    calendarDayLink() {
      if (this.disabled || this.isOutOfRange) {
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

<style lang="scss">
.calendar-day {
  a {
    width: 30px;
    margin: 1px auto;
    padding: 0.25rem;
    border: 1px solid transparent;
    transition: opacity 1s;
  }
  a.occupied-forenoon,
  a.occupied-afternoon,
  a.occupied-fullday {
    border: 1px solid #e85f5f;
    font-weight: bold;
    color: #9e2e2e;

    &.occupied-fullday {
      background: #ffa8a8;
    }

    &.occupied-afternoon {
      background: linear-gradient(315deg, #ffa8a8 50%, white 50%);
      border-top-color: white;
      border-left-color: white;
    }
    &.occupied-forenoon {
      background: linear-gradient(135deg, #ffa8a8 50%, white 50%);
      border-bottom: white;
      border-right: white;
    }
    &.occupied-forenoon.occupied-afternoon {
      border: 1px solid #ffa8a8;
      background: linear-gradient(
        135deg,
        #ffa8a8 49%,
        white 49%,
        white 51%,
        #ffa8a8 51%
      );
    }
  }

  a.tentative-forenoon,
  a.tentative-afternoon,
  a.tentative-fullday {
    border: 1px solid #0033ff;
    font-weight: bold;
    color: #0033ff;

    &.tentative-fullday {
      background: #00bfff;
    }

    &.tentative-afternoon {
      background: linear-gradient(315deg, #00bfff 50%, white 50%);
      border-top-color: white;
      border-left-color: white;
    }
    &.tentative-forenoon {
      background: linear-gradient(135deg, #00bfff 50%, white 50%);
      border-bottom: white;
      border-right: white;
    }

    &.tentative-forenoon.tentative-afternoon {
      border: 1px solid #0033ff;
      background: linear-gradient(
        135deg,
        #00bfff 49%,
        white 49%,
        white 51%,
        #00bfff 51%
      );
    }
  }

  a.closed {
    background: #ccc;
    border: 1px solid #999;
    color: #999;
  }

  a.disabled {
    cursor: default;
    opacity: 0.2;
  }
}
</style>

