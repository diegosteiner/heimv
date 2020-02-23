<template>
  <button
    :id="id"
    name="booking[occupancy_attributes][begins_at]"
    :value="value"
    :class="cssClasses"
    :disabled="disabled || loading"
    @click="$emit('input', date)"
  >
    {{ date.getDate() }}
    <b-popover
      v-if="occupancies.length && !disabled && !loading"
      :target="id"
      triggers="hover focus"
    >
      <dl class="my-1" v-for="occupancy in occupancies" :key="occupancy.id">
        <dt>{{ $d(occupancy.begins_at, 'short') }} - {{ $d(occupancy.ends_at, 'short') }}</dt>
        <dd>
          <a v-if="(occupancy.links || {}).handle" :href="occupancy.links.handle">
            <i class="fa fa-link"></i>
            {{ occupancy.ref }}
          </a>
          <span>{{ $t(`activerecord.enums.occupancy.occupancy_type.${occupancy.occupancy_type}`) }}</span>
          <span v-if="occupancy.deadline">(bis {{ $d(Date.parse(occupancy.deadline), 'short')}})</span>
        </dd>
      </dl>
    </b-popover>
  </button>
</template>

<script>
import { BPopover } from 'bootstrap-vue'
import { setHours, formatISO, startOfDay, endOfDay, isWithinInterval, parseISO } from 'date-fns'

export default {
  components: { 'b-popover': BPopover },
  props: {
    date: Date,
    loading: true,
    disabled: true,
    active: false,
    occupancies: {
      type: Array,
      default: () => []
    },
  },
  computed: {
    id() {
      return this._uid + '_' + formatISO(this.date);
    },
    value() {
      return formatISO(setHours(this.date, 11))
    },
    cssClasses() {
      if(this.disabled || this.loading) return ["disabled"]
      if(this.active) return ["bg-primary text-white"]

      const midDay = setHours(startOfDay(this.date), 12)

      return this.occupancies.map((occupancy) => {
        if(isWithinInterval(occupancy.ends_at, { start: startOfDay(this.date), end: midDay })) {
          return `${occupancy.occupancy_type}-forenoon`;
        }
        if(isWithinInterval(occupancy.begins_at, { start: midDay, end: endOfDay(this.date) })) {
          return `${occupancy.occupancy_type}-afternoon`;
        }
        return `${occupancy.occupancy_type}-fullday`;
      })
    },
  },
};
</script>

<style lang="scss">
$tentative-foreground-color: #0033ff;
$tentative-border-color: #0033ff;
$tentative-background-color: #00bfff;
$occupied-foreground-color: #9e2e2e;
$occupied-border-color: #e85f5f;
$occupied-background-color: #ffa8a8;

@media (max-width: 575px) {
  .calendar-main {
    font-size: 1.3rem !important;
  }
}

.calendar-day {
  button {
    background-color: white;
    border: 1px solid transparent;
    cursor: pointer;
    text-align: center;
    display: block;
    width: 100%;
    height: 100%;
    padding: 0;
    font-size: 0.9rem;
    transition: opacity 0.1s ease-in-out;
    opacity: 1;

    &:hover {
      opacity: 0.8;
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
  .occupied-forenoon.occupied-afternoon,
  .occupied-forenoon.occupied-fullday,
  .occupied-afternoon.occupied-fullday {
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

