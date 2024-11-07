import Component from '@ember/component';
import { computed } from '@ember/object';
import { inject as service } from '@ember/service';
import DiceBox from './dice-box-three';

export default Component.extend({
  gameApi: service(),
  tagName: '',
  dice: null,
  diceFormData: null,
  displaySettings: computed('diceFormData.@each', function () {
    return this.get('diceFormData');
  }),
  init() {
    this._super(...arguments);
    this.set('diceFormData', { ...this.settings?.settings?.dice });
  },
  didInsertElement() {
    this._super(...arguments);
    const interval = setInterval(() => {
      if (!window.Coloris) return;
      clearInterval(interval);
      Coloris({
        parent: '.cod-char-settings',
        themeMode: 'dark',
        alpha: false,
      });
    }, 50);

    const Box = new DiceBox('#dice-tray', {
      assetPath: '/',
      theme_customColorset: {
        background: this.diceFormData.background,
        foreground: this.diceFormData.foreground,
        texture: this.diceFormData.theme_texture,
        material: this.diceFormData.theme_material,
      },
      sounds: this.diceFormData.sounds,
      shadows: true,
      light_intensity: 1,
      gravity_multiplier: 400,
      baseScale: 100,
      strength: 2,
    });

    Box.initialize();
    this.set('Box', Box);
  },
  actions: {
    updateSettings() {
      this.gameApi
        .requestOne('codUpdateSettings', { dice: this.diceFormData })
        .then((res) => {
          if (res.error) {
            return alertify.error(res.error);
          }
          this.set('diceFormData', { ...res.dice });
          alertify.success('Updated');
        });
    },
    testRoll() {
      this.Box.updateConfig({
        theme_customColorset: {
          background: this.displaySettings?.background,
          foreground: this.displaySettings?.foreground,
          texture: this.displaySettings?.theme_texture,
          material: this.displaySettings?.theme_material,
        },
      })
        .then(async () => {
          if (this.displaySettings?.sounds) {
            this.Box.sounds = true;
            await this.Box.loadSounds();
          } else {
            this.Box.sounds = false;
          }
        })
        .then(() => this.Box.roll(`3d10`));
    },
    selectMaterial(m) {
      this.set('diceFormData.theme_material', m);
    },
    selectTexture(t) {
      this.set('diceFormData.theme_texture', t);
    },
    changeDiceSetting(field, event) {
      this.set(`diceFormData.${field}`, event.srcElement.value);
    },
  },
});
