import { computed } from '@ember/object';
import Component from '@ember/component';
import { inject as service } from '@ember/service';

export default Component.extend({
  gameApi: service(),
  gameSocket: service(),
  tagName: '',
  selectAddRoll: false,
  selectAdjustHealth: false,
  selectResourceSpend: false,
  selectAdjustResource: false,
  show3dDice: true,
  hasCombat: false,
  combat: null,
  isSceneFocus: !!window.location.pathname?.includes('scene-focus'),
  init() {
    this._super(...arguments);
    this.gameSocket.setupCallback('combat_update', (_, combat) => {
      combat = JSON.parse(combat);
      if (this.scene && this.scene.id !== combat?.scene_id) return;
      this.set('combat', combat);
      this.set('hasCombat', !!this.combat?.id);
    });
  },
  didReceiveAttrs() {
    this._super(...arguments);
    this.gameApi
      .requestOne('sceneCombatInfo', {
        scene_id: this.scene.id,
      })
      .then((combat) => {
        this.set('combat', combat.id ? combat : null);
        this.set('hasCombat', !!this.combat?.id);
      });
  },
  willDestroyElement() {
    this.gameSocket.removeCallback('combat_update');
  },
  actions: {
    combatStart() {
      if (this.hasCombat) return;
      this.gameApi
        .requestOne('combatStart', {
          scene_id: this.scene.id,
        })
        .then((combat) => {
          this.set('combat', combat);
          this.set('hasCombat', true);
        });
    },
    combatEnd() {
      if (!this.hasCombat) return;
      this.gameApi
        .requestOne('combatEnd', {
          scene_id: this.scene.id,
        })
        .then(() => {
          this.set('combat', null);
          this.set('hasCombat', false);
        });
    },
  },
});
