(() => {

  class ESX {

    constructor() {

      this.frames = {};
      this.modulePath = '../modules';

      window.addEventListener('message', e => {

        for(let name in this.frames) {
          if(this.frames[name].iframe.contentWindow === e.source) {
            this.onFrameMessage(name, e.data);
            return;
          }
        }

        this.onMessage(e.data);

      });

      $.post('http://es_extended/nui_ready', '{}');

    }

    createFrame(name, url, visible = true) {

      const frame       = document.createElement('div');
      const iframe      = document.createElement('iframe');

      frame.appendChild(iframe);

      iframe.src        = url;
      this.frames[name] = {frame, iframe};

      this.frames[name].iframe.addEventListener('message', e => this.onFrameMessage(name, e.data));
      this.frames[name].frame.style.pointerEvents = 'none';

      document.querySelector('#frames').appendChild(frame);

      if(!visible)
        this.hideFrame(name);

      return this.frames[name];

    }

    destroyFrame(name) {
      document.querySelector('#frames').removeChild(this.frames[name].frame);
      this.frames[name].frame.remove();
    }

    showFrame(name) {
      this.frames[name].frame.style.display = 'block';
    }

    hideFrame(name) {
      this.frames[name].frame.style.display = 'none';
    }

    focusFrame(name) {

      for(let k in this.frames) {

        if(k === name)
          this.frames[k].frame.style.pointerEvents = 'all';
        else
          this.frames[k].frame.style.pointerEvents = 'none';
      }

      this.frames[name].iframe.contentWindow.focus();

    }

    onMessage(msg) {

      if(msg.target) {

        if(this.frames[msg.target])
          this.frames[msg.target].iframe.contentWindow.postMessage(msg.data);
        else
          console.error('[esx:nui] cannot find frame : ' + msg.target);

      } else {

        switch(msg.action) {

          case 'create_frame' : {
            this.createFrame(msg.name, msg.url, msg.visible);
            break;
          }

          case 'destroy_frame' : {
            this.destroyFrame(msg.name);
            break;
          }

          case 'focus_frame' : {
            this.focusFrame(msg.name);
            break;
          }

          default: break;
        }

      }


    }

    onFrameMessage(name, msg) {
      $.post('http://es_extended/frame_message', JSON.stringify({name, msg}));
    }

  }

  ESX = new ESX();

})();
