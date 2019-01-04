<template>
  <div>
    <button :id="id" :class="calendarDayClass" @click="click">{{ date | dayOfMonth }}</button>
    <b-popover
      v-if="occupancies.length && !isOutOfRange && !disabled"
      :target="id"
      triggers="hover focus"
    >
      <dl class="my-1" v-for="occupancy in occupancies" :key="occupancy.id">
        <dt>{{ date_format(occupancy.begins_at) }} - {{ date_format(occupancy.ends_at) }}</dt>
        <dd>
          <a v-if="(occupancy.links || {}).handle" :href="occupancy.links.handle">
            <i class="fa fa-link"></i>
            {{ occupancy.ref }}
          </a>
          <span>{{ $t(`occupancy_types.${occupancy.occupancy_type}`) }}</span>
          <span v-if="occupancy.deadline">(bis {{ date_format(occupancy.deadline) }})</span>
        </dd>
      </dl>
    </b-popover>
  </div>
</template>

<script>
import moment from "moment";
import "moment-timezone";
export default {
  props: ["date", "occupancies", "disabled", "href"],
  i18n: {
    messages: {
      "de-CH": {
        occupancy_types: {
          tentative: "provisorisch Besetzt",
          occupied: "definitiv Besetzt",
          closed: "Geschlossen",
          free: ""
        },
        date_format: "DD.MM.Y HH:mm"
      }
    }
  },
  filters: {
    dayOfMonth: function(value) {
      return moment(value).format("D");
    }
  },
  methods: {
    date_format(value) {
      return moment(value).format(this.$t("date_format"));
    },
    click() {
      if (!this.disabled && !this.isOutOfRange && !this.occupancies.length > 0) {
        window.location.href = this.link;
      }
    }
  },
  computed: {
    id() {
      return this._uid + '_' + moment(this.date).format("Y-MM-DD");
    },
    isOutOfRange() {
      return (
        this.date.isBefore(moment().subtract(1, "day")) ||
        this.date.isAfter(moment().add(2, "years"))
      );
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
    link() {
      return this.href.replace(
        "__DATE__",
        moment(this.date)
          .startOf("day")
          .hour(13)
          .toISOString()
      );
    }
  }
};
</script>

<style lang="scss">
.calendar-day {
  button {
    width: 30px;
    height: 30px;
    margin: 1px auto;
    padding: 0.25rem;
    border: 1px solid transparent;
    transition: opacity 1s;
    cursor: pointer;

    &:focus {
      outline: none;
    }
  }

  @media (max-width: 575px) {
    button {
      width: 40px;
      height: 40px;
      font-size: 1.25rem;
      line-height: 2rem;
    }
  }

  .occupied-forenoon,
  .occupied-afternoon,
  .occupied-fullday {
    border: 1px solid #e85f5f;
    font-weight: bold;
    color: #9e2e2e;
  }
  .occupied-fullday {
    background: #ffa8a8;
  }

  .occupied-afternoon {
    background: linear-gradient(315deg, #ffa8a8 50%, white 50%);
    border-top-color: white;
    border-left-color: white;
  }
  .occupied-forenoon {
    background: linear-gradient(135deg, #ffa8a8 50%, white 50%);
    border-bottom: white;
    border-right: white;
  }
  .occupied-forenoon.occupied-afternoon {
    border: 1px solid #ffa8a8;
    background: linear-gradient(
      135deg,
      #ffa8a8 49%,
      white 49%,
      white 51%,
      #ffa8a8 51%
    );
  }

  .tentative-forenoon,
  .tentative-afternoon,
  .tentative-fullday {
    border: 1px solid #0033ff;
    font-weight: bold;
    color: #0033ff;
  }

  .tentative-fullday {
    background: #00bfff;
  }

  .tentative-afternoon {
    background: linear-gradient(315deg, #00bfff 50%, white 50%);
    border-top-color: white;
    border-left-color: white;
  }
  .tentative-forenoon {
    background: linear-gradient(135deg, #00bfff 50%, white 50%);
    border-bottom-color: white;
    border-right-color: white;
  }

  .tentative-forenoon.tentative-afternoon {
    border: 1px solid #0033ff;
    background: linear-gradient(
      135deg,
      #00bfff 49%,
      white 49%,
      white 51%,
      #00bfff 51%
    );
  }

  .occupied-forenoon.tentative-afternoon {
    border: 1px solid white;
    border-top-color: #e85f5f;
    border-right-color: #0033ff;
    border-bottom-color: #0033ff;
    border-left-color: #e85f5f;
    background: linear-gradient(
      135deg,
      #ffa8a8 49%,
      white 49%,
      white 51%,
      #00bfff 51%
    );
  }

  .tentative-forenoon.occupied-afternoon {
    border: 1px solid white;
    border-top-color: #0033ff;
    border-right-color: #e85f5f;
    border-bottom-color: #e85f5f;
    border-left-color: #0033ff;
    background: linear-gradient(
      135deg,
      #00bfff 49%,
      white 49%,
      white 51%,
      #ffa8a8 51%
    );
  }

  .closed {
    background: #ccc;
    border: 1px solid #999;
    color: #999;
  }

  .disabled {
    cursor: default;
    opacity: 0.2;
  }
}
</style>

