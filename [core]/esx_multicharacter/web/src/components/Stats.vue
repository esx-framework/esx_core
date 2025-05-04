<template>
  <div class="stats-container" v-show="isVisible">
    <div class="stats-background" />
    <div class="stats-content">
      <div class="stats-info">
        <div class="stats-group">
          <div class="stats-job">
            <div class="stats-overlap-group">
              <div class="stats-text">{{ stats.job }}</div>
              <img class="stats-icon" alt="Job" :src="require('../assets/stats/job.svg')" />
            </div>
          </div>
          <div class="stats-play-button" @click="handlePlay">
            <div class="stats-play-rectangle">
              <div class="stats-play-content">
                <img class="stats-play-icon" alt="Play" :src="require('../assets/stats/play.svg')" />
                <div class="stats-play-text">PLAY</div>
              </div>
            </div>
          </div>
          <div class="stats-delete-button" @click="handleDelete">
            <div class="stats-delete-rectangle">
              <img class="stats-delete-icon" alt="Delete Character" :src="require('../assets/stats/trash.svg')" />
            </div>
          </div>
          <div class="stats-date">
            <div class="stats-overlap">
              <div class="stats-date-text">{{ stats.date }}</div>
              <img class="stats-date-icon" alt="Date" :src="require('../assets/stats/date.svg')" />
            </div>
          </div>
          <div class="stats-gender">
            <div class="stats-overlap">
              <div class="stats-gender-text">{{ stats.gender }}</div>
              <img class="stats-gender-icon" alt="Gender" :src="require('../assets/stats/gender.svg')" />
            </div>
          </div>
        </div>
        <div class="stats-header">
          <img class="stats-header-icon" alt="Info" :src="require('../assets/stats/info.svg')" />
          <div class="stats-header-text">CHARACTER INFO</div>
        </div>
      </div>
    </div>
  </div>
</template>

<script lang="ts">
import Vue from "vue";
import { fetchNui } from '../fetchNui';

interface StatsData {
  job: string;
  date: string;
  gender: string;
  [key: string]: any;
}

export default Vue.extend({
  name: "Stats",
  props: {
    isVisible: {
      type: Boolean,
      default: false
    },
    stats: {
      type: Object as () => StatsData,
      default: () => ({ job: '', date: '', gender: '' })
    }
  },
  methods: {
    async handlePlay(): Promise<void> {
      try {
        await fetchNui('playCharacter', this.stats);
      } catch (error) {
        console.error('Failed to play character:', error);
      }
    },
    async handleDelete(): Promise<void> {
      try {
        await fetchNui('deleteCharacter', this.stats);
      } catch (error) {
        console.error('Failed to delete character:', error);
      }
    }
  }
});
</script>

<style scoped>
.stats-container {
  height: 280px;
  width: 460px;
  position: absolute;
  left: 50%;
  top: 87px;
  transform: translateX(-50%);
  z-index: 2;
}

.stats-container .stats-background {
  background-color: #242424;
  border-radius: 10px;
  height: 280px;
  width: 460px;
  position: absolute;
  left: 0;
  top: 0;
}

.stats-content {
  height: 156px;
  position: relative;
  width: 420px;
  margin: 20px auto;
}

.stats-info {
  height: 156px;
  position: relative;
  width: 420px;
  padding-left: 0;
}

.stats-group {
  height: 115px;
  position: absolute;
  top: 41px;
  width: 420px;
}

.stats-job {
  height: 50px;
  position: absolute;
  top: 65px;
  width: 420px;
}

.stats-overlap-group {
  background-color: #161616;
  border-radius: 5px;
  height: 50px;
  position: relative;
  width: 420px;
}

.stats-text {
  color: #ffffff;
  font-family: "Poppins-SemiBold", Helvetica;
  font-size: 16px;
  font-weight: 600;
  left: 167px;
  letter-spacing: 0;
  line-height: normal;
  position: absolute;
  top: 50%;
  transform: translateY(-50%);
}

.stats-icon {
  height: 20px;
  left: 12px;
  position: absolute;
  top: 50%;
  transform: translateY(-50%);
  width: 20px;
}

.stats-date {
  height: 50px;
  position: absolute;
  top: 0;
  width: 200px;
}

.stats-overlap {
  background-color: #161616;
  border-radius: 5px;
  height: 50px;
  position: relative;
  width: 200px;
}

.stats-date-text {
  color: #ffffff;
  font-family: "Poppins-SemiBold", Helvetica;
  font-size: 16px;
  font-weight: 600;
  left: 72px;
  letter-spacing: 0;
  line-height: normal;
  position: absolute;
  top: 50%;
  transform: translateY(-50%);
}

.stats-date-icon {
  height: 20px;
  left: 12px;
  position: absolute;
  top: 50%;
  transform: translateY(-50%);
  width: 20px;
}

.stats-gender {
  height: 50px;
  left: 220px;
  position: absolute;
  top: 0;
  width: 200px;
}

.stats-gender-text {
  color: #ffffff;
  font-family: "Poppins-SemiBold", Helvetica;
  font-size: 16px;
  font-weight: 600;
  left: 85px;
  letter-spacing: 0;
  line-height: normal;
  position: absolute;
  top: 50%;
  transform: translateY(-50%);
}

.stats-gender-icon {
  height: 20px;
  left: 14px;
  position: absolute;
  top: 50%;
  transform: translateY(-50%);
  width: 20px;
}

.stats-header {
  height: 24px;
  left: 0px;
  position: absolute;
  top: 0;
  width: 171px;
  display: flex;
  align-items: center;
  gap: 10px;
}

.stats-header-icon {
  height: 28px;
  width: 28px;
  position: relative;
}

.stats-header-text {
  color: #ffffff;
  font-family: "Poppins-SemiBold", Helvetica;
  font-size: 16px;
  font-weight: 600;
  letter-spacing: 0;
  line-height: normal;
  position: relative;
  white-space: nowrap;
}

.stats-play-button {
  height: 50px;
  width: 358px;
  position: absolute;
  top: 135px;
  left: 0;
}

.stats-delete-button {
  height: 50px;
  width: 51px;
  position: absolute;
  top: 135px;
  left: 368px;
}

.stats-play-rectangle {
  background-color: #383838;
  border-radius: 5px;
  height: 50px;
  width: 358px;
  position: absolute;
  left: 0;
  top: 0;
}

.stats-delete-rectangle {
  background-color: #383838;
  border-radius: 5px;
  height: 50px;
  width: 51px;
  position: relative;
}

.stats-play-content {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 10px;
  height: 100%;
  width: 100%;
}

.stats-play-icon {
  height: 24px;
  width: 24px;
}

.stats-play-text {
  color: #f2eeee;
  font-family: "Poppins-SemiBold", Helvetica;
  font-size: 18px;
  font-weight: 600;
  letter-spacing: 0;
  line-height: normal;
}

.stats-delete-icon {
  height: 20px;
  left: 50%;
  position: absolute;
  top: 50%;
  transform: translate(-50%, -50%);
  width: 20px;
}
</style> 