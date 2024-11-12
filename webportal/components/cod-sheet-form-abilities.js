import Component from '@ember/component';

export default Component.extend({
  init() {
    this._super(...arguments);
    this.set(
      'abilities',
      this.sheet.abilities.filter((a) => a.type === 'Form Ability'),
    );
  },
});
