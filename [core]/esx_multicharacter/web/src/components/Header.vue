<template>
  <div class="header">
    <img class="logo" :src="logo" alt="ESX Logo" />
    <div class="title">CHARACTER SELECTION</div>
  </div>
</template>

<script lang="ts">
import Vue from 'vue'

interface HeaderData {
  logo: string;
}

export default Vue.extend({
  name: 'Header',
  data(): HeaderData {
    return {
      logo: require('../assets/common/esxLogo.png')
    }
  }
})
</script>

<style scoped>
.header {
  position: fixed;
  top: 53px;
  left: 200px;
  z-index: 1;
}

.header .logo {
  position: absolute;
  left: -165px;
  top: 50%;
  transform: translateY(-50%);
  height: 60px;
  width: auto;
}

.header .title {
  color: white;
  font-family: 'Poppins-Bold', Helvetica;
  font-size: 24px;
  font-weight: 700;
}
</style> 