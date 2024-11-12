import Component from '@ember/component';
import { prettyPrintPrereqs } from './cod-chargen';

export default Component.extend({
  init() {
    this._super(...arguments);
    this.set('fields', {
      action: 'Action',
      cost: 'Cost',
      category: 'Category',
      pool: 'Pool',
    });
    this.set(
      'abilities',
      this.sheet.abilities
        .filter((a) => a.type === 'Embed')
        .map((a) => {
          const embed = { ...a.data };
          embed.reqs = prettyPrintPrereqs(embed.reqs);
          return embed;
        }),
    );
  },
});
