<template>
  <ul>
    <draggable v-model="tarifs">
      <tarif v-for='t in componentTarifs' :key='t.id' :tarif='t'></tarif>
    </draggable>
  </ul>
</template>
<script>
import Vue from "vue/dist/vue.js";
import TarifCategory from "./TarifCategory.vue";
import Tarif from "./Tarif.vue";
import draggable from "vuedraggable";

export default {
  components: { TarifCategory, Tarif, draggable },
  props: ["tarifs"],
  data() {
    return {
      // tarifCategories: []
      componentTarifs: Vue.util.extend({}, this.tarifs)
    };
  }
};
</script>
<style>
</style>
