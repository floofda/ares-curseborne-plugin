import { computed } from '@ember/object';
import Component from '@ember/component';
import { inject as service } from '@ember/service';

export default Component.extend({
  gameApi: service(),
  flashMessages: service(),
  selectAddRoll: false,
  selectAdjustHealth: false,
  selectAdjustResource: false,
  initModifier: 0,
  isFlyoutActive: false,
  showNpcForm: false,
  add: true,
  init() {
    this._super(...arguments);
    this.set('poseElement', document.querySelector('#live-scene-log'));
  },
  combatants: computed('combat', function () {
    return this.combat?.combatants || [];
  }),
  hasJoined: computed('combat', function () {
    return this.combat?.init_list?.includes(this.data?.char?.name);
  }),
  hasRolledInit: computed('combat', function () {
    return this.combat?.ordered_init_list?.includes(this.data?.char?.name);
  }),
  actions: {
    setIsFlyoutActive() {
      this.set('isFlyoutActive', !this.isFlyoutActive);
    },
    joinCombat() {
      this.gameApi
        .requestOne('joinCombat', {
          scene_id: this.scene.id,
          combat_id: this.combat.id,
        })
        .then((combat) => {
          this.set('combat', combat);
        });
    },
    leaveCombat() {
      this.gameApi
        .requestOne('leaveCombat', {
          scene_id: this.scene.id,
          combat_id: this.combat.id,
        })
        .then((combat) => {
          this.set('combat', combat);
        });
    },
    updateInitModifier(event) {
      this.set('initModifier', event.srcElement.value);
    },
    editNpc(npc) {
      this.set('add', false);
      this.set('formData', { ...npc });
      this.set('showNpcForm', true);
    },
    removeNpc(npc) {
      this.gameApi
        .requestOne('removeNpc', {
          combat_id: this.combat.id,
          npc: npc.name,
        })
        .then((res) => {
          if (res.error) return;
        });
    },
    rollInit() {
      this.gameApi
        .requestOne('combatRollInit', {
          scene_id: this.scene.id,
          combat_id: this.combat.id,
          modifier: this.initModifier,
        })
        .then((combat) => {
          this.set('initModifier', 0);
          this.set('combat', combat);
        });
    },
    nextChar() {
      this.gameApi
        .requestOne('combatNextChar', {
          scene_id: this.scene.id,
          combat_id: this.combat.id,
        })
        .then((combat) => {
          this.set('combat', combat);
        });
    },
    prevChar() {
      this.gameApi
        .requestOne('combatPrevChar', {
          scene_id: this.scene.id,
          combat_id: this.combat.id,
        })
        .then((combat) => {
          this.set('combat', combat);
        });
    },
  },
});
