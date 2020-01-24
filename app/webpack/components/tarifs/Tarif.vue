<template>
  <li class="row mb-2">
    <div class="col-1 px-2">
      <i class="fa fa-bars" />
    </div>
    <div class="col-2 px-2">
      <b-form-select v-model="tarif.tarif_type" :options="tarifTypeOptions" />
    </div>
    <div class="col-3 px-2">
      <b-form-input v-model="tarif.label" type="text" />
    </div>
    <div class="col-3 px-2">
      <b-form-input v-model="tarif.unit" type="text" />
    </div>
    <div class="col-3 px-2">
      <b-form-input v-model="tarif.price_per_unit" type="text" />
    </div>
    <div class="col-12">{{ tarif }}</div>
  </li>
</template>
<script>
import Vue from "vue";

export default {
  props: ["tarif", "tarifTypes"],
  data() {
    return {
      _tarif: tarif,
      tarifTypeOptions: this.tarifTypes,
      tarif_type: this.tarif.tarif_type,
      label: this.tarif.label,
      unit: this.tarif.unit,
      price_per_unit: this.tarif.pricePerUnit
    };
  }
};
</script>
<style>
</style>
