import Component from '@ember/component';

export default Component.extend({
  didReceiveAttrs() {
    this._super(...arguments);
    if (this.ability?.data) {
      this.set('ability_data', { ...this.ability.data });
    } else {
      this.set('ability_data', { ...this.ability });
    }
  },
});
