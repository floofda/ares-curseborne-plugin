import { computed } from '@ember/object';
import Component from '@ember/component';
import { inject as service } from '@ember/service';

export default Component.extend({
  gameApi: service(),
  flashMessages: service(),
  tagName: '',
  selectAdjustHealth: false,
  selectedChar: null,
  healthChar: null,
  healthStr: null,
  bashing: false,
  lethal: false,
  agg: false,
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
  getSelectedChar(name) {
    return name === this.data.char.name
      ? this.data.char
      : this.combat?.combatants.find((c) => c.name === name);
  },
  didReceiveAttrs() {
    this._super(...arguments);
    const defaultSelected =
      this.canSelect && this.selectableChars.includes(this.combat?.curr)
        ? this.combat.curr
        : this.data.char.name;

    this.set('healthChar', defaultSelected);
    this.set('selectedChar', this.getSelectedChar(this.healthChar));
  },
  didInsertElement() {
    this._super(...arguments);
    this.set('healthChar', this.data.char.name);
  },

  actions: {
    selectChar(name) {
      this.set('selectedChar', this.getSelectedChar(name));
      this.set('healthChar', name);
    },
    adjustHealth() {
      this.set('selectAdjustHealth', false);
      this.gameApi
        .requestOne(
          'adjustHealth',
          {
            id: this.get('scene.id'),
            char: this.healthChar,
            value: this.healthStr,
            bashing: this.bashing,
            lethal: this.lethal,
            agg: this.agg,
          },
          null,
        )
        .then((res) => {
          if (res.c_error) {
            alertify.error(res.c_error);
            return;
          }

          ['healthChar', 'healthStr'].forEach((s) => this.set(s, null));
          ['bashing', 'lethal', 'agg'].forEach((s) => this.set(s, false));
        });
    },
  },
});
