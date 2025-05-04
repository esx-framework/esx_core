<template>
  <div class="box">
    <div class="rectangle"></div>
    <div class="users">
      <div class="user" @click="handleCreateCharacter">
        <div class="group">
          <img class="create-icon" alt="Create Character" :src="createIcon" />
        </div>
      </div>

      <div v-for="(user, index) in users" 
           :key="user.id" 
           :class="`user-${index + 1}`" 
           @click="setActiveUser(user.id)"
           :style="getUserPosition(index)">
        <div v-if="activeUser === user.id" class="active-user">
          <div class="overlap">
            <div class="vector-wrapper">
              <img class="user-avatar" alt="User Avatar" :src="user.activeImage" />
            </div>

            <div class="div">
              <div class="overlap-group">
                <div class="text-wrapper">{{ user.name }}</div>
              </div>

              <div class="img-wrapper">
                <img class="play-icon" alt="Play" :src="playIcon" />
              </div>

              <div class="overlap-2" @click.stop="toggleStats">
                <img class="info-icon" alt="Information" :src="infoIcon" />
              </div>
            </div>
          </div>
          <Stats :isVisible="showStats" :stats="activeUserStats" />
        </div>
        <div v-else :style="{ opacity: 0.5, transition: 'opacity 0.2s ease' }">
          <div class="group-2">
            <img class="user-avatar" alt="User Avatar" :src="user.inactiveImage" />
          </div>

          <div class="overlap-group-wrapper">
            <div class="div-wrapper">
              <div class="text-wrapper-2">{{ user.name }}</div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script lang="ts">
import Vue from "vue";
import Stats from "./Stats.vue";
import { userConfig } from '../userConfig';
import { fetchNui } from '../fetchNui';

/**
 * Character stats interface
 */
interface UserStats {
  job?: string;
  date?: string;
  gender?: string;
  [key: string]: any;
}

interface User {
  id: string;
  name: string;
  activeImage: string;
  inactiveImage: string;
  stats: UserStats;
}

export default Vue.extend({
  name: "Users",
  components: {
    Stats
  },
  data() {
    return {
      activeUser: '',
      showStats: false,
      users: [] as User[],
      playIcon: require('../assets/users/play.svg'),
      infoIcon: require('../assets/users/information.svg'),
      createIcon: require('../assets/users/create.svg'),
    };
  },
  created() {
    this.initializeUsers();
  },
  methods: {
    initializeUsers(): void {
      this.users = userConfig.map(user => ({
        ...user,
        ...this.getUserImages(user.id)
      }));
      this.activeUser = this.users[0]?.id || '';
    },
    getUserImages(userId: string): { activeImage: string; inactiveImage: string } {
      const imageMap: Record<string, { active: string; inactive: string }> = {
        peter: {
          active: require('../assets/user1.svg'),
          inactive: require('../assets/user2.svg')
        },
        stan: {
          active: require('../assets/user1.svg'),
          inactive: require('../assets/user2.svg')
        },
        will: {
          active: require('../assets/user1.svg'),
          inactive: require('../assets/user3.svg')
        },
        abe: {
          active: require('../assets/user1.svg'),
          inactive: require('../assets/user4.svg')
        }
      };

      const images = imageMap[userId] || { active: '', inactive: '' };
      return {
        activeImage: images.active,
        inactiveImage: images.inactive
      };
    },
    async handleCreateCharacter(): Promise<void> {
      try {
        await fetchNui('createCharacter');
      } catch (error) {
        console.error('Failed to create character:', error);
      }
    },
    async setActiveUser(userId: string): Promise<void> {
      this.activeUser = userId;
      const user = this.users.find(u => u.id === userId);
      if (user) {
        try {
          await fetchNui('selectCharacter', {
            name: user.name,
            dob: user.stats.date || '',
            gender: user.stats.gender || '',
            job: user.stats.job || ''
          });
        } catch (error) {
          console.error('Failed to select character:', error);
        }
      }
    },
    toggleStats(): void {
      this.showStats = !this.showStats;
    },
    getUserPosition(index: number): { top: string } {
      const baseSpacing = 87;
      const statsHeight = 280;
      const statsGap = 20;
      const activeIndex = this.users.findIndex(user => user.id === this.activeUser);
      
      let position = index * baseSpacing;
      
      if (index > activeIndex && this.showStats) {
        position += statsHeight + statsGap;
      }
      
      return { top: `${position}px` };
    }
  },
  computed: {
    activeUserStats(): UserStats {
      const user = this.users.find(u => u.id === this.activeUser);
      return user ? user.stats : {};
    }
  }
});
</script>

<style>
.box {
  height: 1080px;
  width: 527px;
  position: relative;
}

.box .rectangle {
  background-color: #0f0f0ff2;
  height: 1080px;
  left: 0;
  position: fixed;
  top: 0;
  width: 527px;
  z-index: -1;
}

.box .users {
  height: 918px;
  left: 30px;
  position: fixed;
  top: 120px;
  width: 462px;
  z-index: 1;
}

.box .user {
  height: 70px;
  left: 0;
  position: absolute;
  top: 848px;
  width: 462px;
}

.box .group {
  background-color: #fb9b04;
  border-radius: 5px;
  height: 70px;
  left: 30px;
  position: fixed;
  top: 950px;
  width: 462px;
}

.box .create-icon {
  height: 20px;
  width: 20px;
  position: absolute;
  left: 50%;
  top: 50%;
  transform: translate(-50%, -50%);
}

.box .active-user {
  height: 65px;
  left: 0;
  position: absolute;
  top: 0;
  width: 462px;
}

.box .overlap {
  height: 65px;
  position: relative;
  width: 464px;
}

.box .vector-wrapper {
  height: 65px;
  left: 0;
  position: absolute;
  top: 0;
  width: 65px;
}

.box .user-avatar {
  height: 20px;
  left: 50%;
  position: absolute;
  top: 50%;
  transform: translate(-50%, -50%);
  width: 20px;
}

.box .div {
  height: 65px;
  left: 2px;
  position: absolute;
  top: 0;
  width: 462px;
}

.box .overlap-group {
  background-color: #fb9b0440;
  border: 2px solid;
  border-color: #fb9b04;
  border-radius: 5px;
  height: 65px;
  left: 0;
  position: absolute;
  top: 0;
  width: 311px;
}

.box .text-wrapper {
  color: #fb9b04;
  font-family: "Poppins-Bold", Helvetica;
  font-size: 24px;
  font-weight: 700;
  left: 95px;
  letter-spacing: 0;
  line-height: normal;
  position: absolute;
  top: 50%;
  transform: translateY(-50%);
  width: 200px;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.box .img-wrapper {
  background-color: #fb9b04;
  border-radius: 5px;
  height: 65px;
  left: 325px;
  position: absolute;
  top: 1px;
  width: 65px;
}

.box .play-icon {
  height: 20px;
  left: 25px;
  position: absolute;
  top: 23px;
  width: 16px;
}

.box .overlap-2 {
  background-color: #fb9b04;
  border-radius: 5px;
  height: 65px;
  left: 397px;
  position: absolute;
  top: 1px;
  width: 65px;
}

.box .info-icon {
  height: 20px;
  width: 20px;
  position: absolute;
  left: 50%;
  top: 50%;
  transform: translate(-50%, -50%);
}

.box .user-2 {
  height: 65px;
  left: 0;
  position: absolute;
  top: 365px;
  width: 462px;
}

.box .group-2 {
  background-color: #383838;
  border: 2px solid #ffffff80;
  border-right: none;
  border-radius: 5px 0 0 5px;
  height: 65px;
  left: 0;
  position: absolute;
  top: 0;
  width: 65px;
}

.box .vector-4 {
  height: 20px;
  left: 50%;
  position: absolute;
  top: 50%;
  transform: translate(-50%, -50%);
  width: 20px;
}

.box .overlap-group-wrapper {
  height: 65px;
  left: 65px;
  position: absolute;
  top: 0;
  width: 399px;
}

.box .div-wrapper {
  background-color: #383838;
  border: 2px solid #ffffff80;
  border-left: none;
  border-radius: 0 5px 5px 0;
  height: 65px;
  position: relative;
  width: 397px;
}

.box .text-wrapper-2 {
  color: #ffffff80;
  font-family: "Poppins-Bold", Helvetica;
  font-size: 24px;
  font-weight: 700;
  left: 50%;
  transform: translate(-50%, -50%);
  letter-spacing: 0;
  line-height: normal;
  position: absolute;
  top: 50%;
  width: auto;
  white-space: nowrap;
}

.box .user-3 {
  height: 65px;
  left: 0;
  position: absolute;
  top: 452px;
  width: 462px;
}

.box .overlap-group-2 {
  background-color: #2a2a2a;
  border: 2px solid #ffffff;
  border-left: none;
  border-radius: 0 5px 5px 0;
  height: 65px;
  position: relative;
  width: 397px;
}

.box .text-wrapper-3 {
  color: #ffffff;
  font-family: "Poppins-Bold", Helvetica;
  font-size: 24px;
  font-weight: 700;
  left: 50%;
  transform: translate(-50%, -50%);
  letter-spacing: 0;
  line-height: normal;
  position: absolute;
  top: 50%;
  width: auto;
  white-space: nowrap;
}

.box .group-3 {
  background-color: #2a2a2a;
  border: 2px solid #ffffff;
  border-right: none;
  border-radius: 5px 0 0 5px;
  height: 65px;
  left: 0;
  position: absolute;
  top: 0;
  width: 65px;
}

.box .user-4 {
  height: 65px;
  left: 0;
  position: absolute;
  top: 539px;
  width: 462px;
}

.box .text-wrapper-4 {
  color: #ffffff80;
  font-family: "Poppins-Bold", Helvetica;
  font-size: 24px;
  font-weight: 700;
  left: 50%;
  transform: translate(-50%, -50%);
  letter-spacing: 0;
  line-height: normal;
  position: absolute;
  top: 50%;
  width: auto;
  white-space: nowrap;
}

.active-group {
  background-color: #fb9b04 !important;
  border-color: #fb9b04 !important;
}

.active-wrapper {
  background-color: #fb9b0440 !important;
  border-color: #fb9b04 !important;
}

.active-text {
  color: #fb9b04 !important;
}

.box .user-1,
.box .user-2,
.box .user-3,
.box .user-4 {
  height: 65px;
  left: 0;
  position: absolute;
  width: 462px;
}
</style>