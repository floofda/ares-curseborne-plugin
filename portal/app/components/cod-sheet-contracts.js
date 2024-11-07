import Component from '@ember/component';

export default Component.extend({
  init() {
    this._super(...arguments);
    this.set('fields', {
      category: 'Category',
      group: 'Group',
      type: 'Type',
      action: 'Action',
      cost: 'Cost',
      pool: 'Pool',
    });
    this.set(
      'abilities',
      this.sheet.abilities
        .filter((a) => a.type === 'Contract')
        .map((a) => {
          const contract = { ...a.data };
          return contract;
        }),
    );
  },
});
