import { computed } from '@ember/object';
import Component from '@ember/component';
import { inject as service } from '@ember/service';
import DiceBox from './dice-box-three';

export default Component.extend({
  gameApi: service(),
  flashMessages: service(),
  gameSocket: service(),
  tagName: '',
  selectAddRoll: false,
  rollChar: null,
  rollString: null,
  opposedRollChar: null,
  opposedRollString: null,
  rote: false,
  wp: false,
  strict: false,
  nineAgain: false,
  eightAgain: false,
  vs: false,
  at: false,
  actionType: 'scene',
  selectableChars: computed('combat', function () {
    return [this.data.char.name].concat(
      this.combat?.combatants
        .filter((c) => c.creator_id === this.data.char.id || this.data.is_st)
        .map((c) => c.name) || [],
    );
  }),
  canSelect: computed('selectableChars', function () {
    return this.selectableChars?.length > 1;
  }),
  selectableTargets: computed('combat', function () {
    return this.combat?.combatants.map((c) => c.name);
  }),
  clearForm() {
    [
      'rollChar',
      'rollString',
      'opposedRollChar',
      'opposedRollString',
      'selectedChar',
      'selectedTarget',
    ].forEach((s) => this.set(s, null));

    ['rote', 'wp', 'nineAgain', 'eightAgain', 'strict', 'vs', 'at'].forEach(
      (s) => this.set(s, false),
    );
    this.set('selectAddRoll', false);
  },
  getSelectedChar(name) {
    return this.combat?.combatants.find((c) => c.name === name);
  },
  init() {
    this._super(...arguments);
    const template = this.data.char?.template;

    if (!this.data?.settings?.dice?.use || !this.show3dDice) return;
    this.gameSocket.setupCallback('dice_roll', (_, roll) => {
      roll = JSON.parse(roll);
      if (this.scene && this.scene.id !== roll.scene_id) return;

      if (this.data?.settings?.dice?.use_others_themes) {
        this.Box.updateConfig({
          theme_customColorset: {
            background: roll.settings.background,
            foreground: roll.settings.foreground,
            texture: roll.settings.theme_texture,
            material: roll.settings.theme_material,
          },
        }).then(() =>
          this.Box.roll(`${roll.dice.length}d10@${roll.dice.join(',')}`),
        );
      } else {
        this.Box.roll(`${roll.dice.length}d10@${roll.dice.join(',')}`);
      }
    });

    const dice = this.data.settings.dice;
    const Box = new DiceBox('#live-scene-log', {
      assetPath: '/',
      theme_customColorset: {
        background: dice.background,
        foreground: dice.foreground,
        texture: dice.theme_texture,
        material: dice.theme_matrial,
      },
      sounds: dice.sounds,
      shadows: true,
      light_intensity: 1,
      gravity_multiplier: 400,
      baseScale: 100,
      strength: 2,
      onRollComplete: (results) => {
        const canvas = document.querySelector('#live-scene-log canvas');
        if (!canvas) return this.Box.clearDice();

        setTimeout(() => {
          canvas.classList.remove('fade-out');
          this.Box.clearDice();
        }, 400);
        canvas.classList.add('fade-out');
      },
    });

    Box.initialize().then(() => this.set('Box', Box));
  },
  didReceiveAttrs() {
    this._super(...arguments);
    const defaultSelected =
      this.canSelect && this.selectableChars.includes(this.combat?.curr)
        ? this.combat.curr
        : this.data.char.name;

    this.set('rollChar', defaultSelected);
    this.set('selectedChar', this.getSelectedChar(this.rollChar));
    this.set('selectedTarget', this.getSelectedChar(this.opposedRollChar));
  },
  willDestroyElement() {
    this.gameSocket.removeCallback('dice_roll');
    this.Box?.clearDice();
  },

  actions: {
    selectChar(name) {
      this.set('selectedChar', this.getSelectedChar(name));
      this.set('rollChar', name);
    },
    selectTarget(name) {
      this.set('selectedTarget', this.getSelectedChar(name));
      this.set('opposedRollChar', name);
    },
    setOpposed(state) {
      switch (state) {
        case 'vs':
          this.set('vs', true);
          this.set('at', false);
          break;
        case '@':
          this.set('at', true);
          this.set('vs', false);
          break;
        default:
          this.clearForm();
      }
    },
    addRoll() {
      this.set('selectAddRoll', false);
      this.gameApi
        .requestOne(
          this.actionType === 'job' ? 'addJobRoll' : 'addSceneRoll',
          {
            id: this.get(this.actionType === 'job' ? 'job.id' : 'scene.id'),
            char: this.rollChar,
            char_roll_str: this.rollString,
            target: this.opposedRollChar,
            target_roll_str: this.opposedRollString,
            opposed: this.vs,
            modified: this.at,
            wp: this.wp,
            rote: this.rote,
            again: this.strict
              ? 'strict'
              : this.nineAgain
              ? 9
              : this.eightAgain
              ? 8
              : 10,
          },
          null,
        )
        .then((res) => {
          if (res.c_error) {
            alertify.error(res.c_error);
            return;
          }
          this.clearForm();
        });
    },
  },
});
