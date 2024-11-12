import Component from '@ember/component';

export default Component.extend({
  tagName: '',

  didInsertElement() {
    this._super(...arguments);
    this.set('updateCallback', () => this.onUpdate());
  },

  onUpdate() {
    return {
      cg_sheet: this.get('char.custom.cg_sheet'),
    };
  },
});
