import { computed } from '@ember/object';
import Component from '@ember/component';
import { inject as service } from '@ember/service';

export default Component.extend({
  gameApi: service(),
  flashMessages: service(),
  tagName: '',
  selectAdjustResource: false,
  resChar: null,
  selectedChar: null,
  amount: null,
  type: 'Willpower',
  options: computed(
    'selectedChar.{resource_name,resource,morality}',
    function () {
      const opts = ['Willpower'];
      const resource = this.selectedChar?.sheet?.resource_name;
      if (resource) opts.push(resource);
      if (this.selectedChar?.sheet?.morality_name)
        opts.push(this.selectedChar.sheet.morality_name);
      return opts;
    },
  ),
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
    if (!this.combat) return { sheet: this.data.char };
    return this.combat.combatants.find((c) => c.name === name);
  },
  init() {
    this._super(...arguments);
    if (this.data?.char) {
      this.data.char.resource_name = this.data.char.resource;
      this.data.char.morality_name = this.data.char.morality;
    }
  },
  didReceiveAttrs() {
    this._super(...arguments);
    const defaultSelected =
      this.canSelect && this.selectableChars.includes(this.combat?.curr)
        ? this.combat.curr
        : this.data.char.name;

    this.set('resChar', defaultSelected);
    this.set('selectedChar', this.getSelectedChar(this.resChar));
  },

  actions: {
    selectChar(name) {
      this.set('selectedChar', this.getSelectedChar(name));
      this.set('resChar', name);
    },
    selectResourceType(type) {
      this.set('type', type);
    },
    adjustResource() {
      this.set('selectAdjustResource', false);
      this.gameApi
        .requestOne(
          'adjustResource',
          {
            id: this.get('scene.id'),
            char: this.resChar,
            value: this.amount,
            type: this.type,
          },
          null,
        )
        .then((res) => {
          if (res.c_error) {
            alertify.error(res.c_error);
            return;
          }
          this.set('type', 'Willpower');
          this.set('amount');
        });
    },
  },
});
