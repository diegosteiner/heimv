<template>
  <div>
    <div v-if="loading">
      <button :disabled="true">{{ date | moment('D') }}</button>
    </div>
    <div v-else v-once>
      <button
        :id="id"
        name="booking[occupancy_attributes][begins_at]"
        :value="date.hour(11).toISOString()"
        :class="cssClasses"
        :disabled="disabled || loading"
        @click="$emit('input', date)"
      >{{ date | moment('D') }}</button>
      <b-popover
        v-if="occupancies.length && !disabled && !loading"
        :target="id"
        triggers="hover focus"
      >
        <dl class="my-1" v-for="occupancy in relevantOccupancies" :key="occupancy.id">
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
  </div>
</template>

<script>
import BPopover from 'bootstrap-vue/es/components/popover/popover'

export default {
  components: { 'b-popover': BPopover },
  props: {
    date: null,
    loading: true,
    disabled: true,
    active: false,
    occupancies: {
      type: Array,
      default: () => []
    },
  },
  i18n: {
    messages: {
      "de-CH": {
        occupancy_types: {
          tentative: "provisorisch Besetzt",
          occupied: "definitiv Besetzt",
          closed: "Geschlossen",
          free: " "
        },
        date_format: "DD.MM.Y HH:mm"
      }
    }
  },
  methods: {
    date_format(value) {
      return this.$moment(value).format(this.$t("date_format"));
    },
  },
  computed: {
    id() {
      return this._uid + '_' + this.$moment(this.date).format("Y-MM-DD");
    },
    tooltipText() {

    },
    relevantOccupancies(date) {
      return this.occupancies.filter(function(occupancy) {
        return occupancy.occupancy_type != "free";
      });
    },
    cssClasses() {
      if(this.disabled || this.loading) return ["disabled"]
      if(this.active) return ["bg-primary text-white"]
      const moment = this.$moment

      return this.occupancies.map((occupancy) => {
        let begins_at = moment(occupancy.begins_at, moment.ISO_8601);
        let ends_at = moment(occupancy.ends_at, moment.ISO_8601);

        if(ends_at.isBetween(moment(this.date.startOf("day")), moment(this.date.hour(12)), "minutes", "[)")) {
          return `${occupancy.occupancy_type}-forenoon`;
        }
        if(begins_at.isBetween(moment(this.date.hour(10)), moment(this.date.endOf("day")), "minutes", "(]")) {
          return `${occupancy.occupancy_type}-afternoon`;
        }
        return `${occupancy.occupancy_type}-fullday`;
      })
    },
  }
};
</script>

<style lang="scss">
$tentative-foreground-color: #0033ff;
$tentative-border-color: #0033ff;
$tentative-background-color: #00bfff;
$occupied-foreground-color: #9e2e2e;
$occupied-border-color: #e85f5f;
$occupied-background-color: #ffa8a8;

.calendar-day {
  text-align: center;
  button {
    width: 30px;
    height: 30px;
    margin: 1px auto;
    padding: 0.25rem;
    border: 1px solid transparent;
    transition: opacity 1s;
    background-color: white;
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
    border: 1px solid $occupied-border-color;
    font-weight: bold;
    color: $occupied-foreground-color;
  }
  .occupied-fullday {
    background: $occupied-background-color;
  }

  .occupied-afternoon {
    background: linear-gradient(
      315deg,
      $occupied-background-color 50%,
      white 50%
    );
    border-top-color: white;
    border-left-color: white;
  }
  .occupied-forenoon {
    background: linear-gradient(
      135deg,
      $occupied-background-color 50%,
      white 50%
    );
    border-bottom-color: white;
    border-right-color: white;
  }
  .occupied-forenoon.occupied-afternoon {
    border-top-color: $occupied-border-color;
    border-left-color: $occupied-border-color;
    border-bottom-color: $occupied-border-color;
    border-right-color: $occupied-border-color;
    background: linear-gradient(
      135deg,
      $occupied-background-color 49%,
      white 49%,
      white 51%,
      $occupied-background-color 51%
    );
  }

  .tentative-forenoon,
  .tentative-afternoon,
  .tentative-fullday {
    border: 1px solid $tentative-border-color;
    font-weight: bold;
    color: $tentative-foreground-color;
  }

  .tentative-fullday {
    background: $tentative-background-color;
  }

  .tentative-afternoon {
    background: linear-gradient(
      315deg,
      $tentative-background-color 50%,
      white 50%
    );
    border-top-color: white;
    border-left-color: white;
  }
  .tentative-forenoon {
    background: linear-gradient(
      135deg,
      $tentative-background-color 50%,
      white 50%
    );
    border-bottom-color: white;
    border-right-color: white;
  }

  .tentative-forenoon.tentative-afternoon {
    border-top-color: $tentative-border-color;
    border-right-color: $tentative-border-color;
    border-bottom-color: $tentative-border-color;
    border-left-color: $tentative-border-color;
    background: linear-gradient(
      135deg,
      $tentative-background-color 49%,
      white 49%,
      white 51%,
      $tentative-background-color 51%
    );
  }

  .occupied-forenoon.tentative-afternoon {
    border: 1px solid white;
    border-top-color: $occupied-border-color;
    border-right-color: $tentative-border-color;
    border-bottom-color: $tentative-border-color;
    border-left-color: $occupied-border-color;
    background: linear-gradient(
      135deg,
      $occupied-background-color 49%,
      white 49%,
      white 51%,
      $tentative-background-color 51%
    );
  }

  .tentative-forenoon.occupied-afternoon {
    border: 1px solid white;
    border-top-color: $tentative-border-color;
    border-right-color: $occupied-border-color;
    border-bottom-color: $occupied-border-color;
    border-left-color: $tentative-border-color;
    background: linear-gradient(
      135deg,
      $tentative-background-color 49%,
      white 49%,
      white 51%,
      $occupied-background-color 51%
    );
  }

  .closed {
    background: #ccc;
    border: 1px solid #999;
    color: #999;
  }

  .disabled,
  [disabled] {
    cursor: default;
    opacity: 0.2;
    // color: transparent;
    // text-shadow: 0 0 5px rgba(0, 0, 0, 1);
  }

  .active {
    font-weight: bold;
  }
}
</style>

