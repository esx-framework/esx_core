<template>
  <div id="app" v-if="visible">
    <Header />
    <Users @select-character="handleCharacterSelect" />
    <Stats />
  </div>
</template>

<script lang="ts">
import Vue from 'vue'
import Users from './components/Users.vue'
import Header from './components/Header.vue'
import Stats from './components/Stats.vue'
import { fetchNui } from './fetchNui'

/**
 * Character data structure that will be sent from the backend
 */
interface Character {
  name: string;
  dob: string;
  gender: string;
  job: string;
}

interface MessageEvent {
  data: {
    type: string;
    visible: boolean;
  }
}

export default Vue.extend({
  name: 'App',
  components: {
    Users,
    Header,
    Stats
  },
  data() {
    return {
      visible: false,
      characters: [] as Character[]
    }
  },
  mounted() {
    window.addEventListener('message', this.handleMessage);
  },
  beforeDestroy() {
    window.removeEventListener('message', this.handleMessage);
  },
  methods: {
    async handleMessage(event: MessageEvent) {
      if (event.data && event.data.type === 'setVisible') {
        this.visible = !!event.data.visible;
        if (this.visible) {
          try {
            const response = await fetchNui('getCharacters');
            this.characters = response.characters || [];
          } catch (error) {
            console.error('Failed to fetch characters:', error);
          }
        }
      }
    },
    /**
     * Sends selected character data to the backend
     */
    async handleCharacterSelect(characterData: Character) {
      await fetchNui('selectCharacter', characterData);
    }
  }
})
</script>

<style>
body {
  margin: 0;
  padding: 0;
  height: 100vh;
  width: 100vw;
  overflow: hidden;
}

#app {
  font-family: 'Poppins', sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  height: 100vh;
  width: 100vw;
}
</style> 