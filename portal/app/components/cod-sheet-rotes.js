import Component from '@ember/component';
import { prettyPrintPrereqs } from './cod-chargen';

export default Component.extend({
  init() {
    this._super(...arguments);
    this.set('fields', {
      practice: 'Practice',
      cost: 'Cost',
      primary_factor: 'Primary Factor',
      reqs: 'Prerequisites',
    });
    this.set(
      'abilities',
      this.sheet.abilities
        .filter((a) => a.type === 'Rote')
        .map((a) => {
          const rote = { ...a.data };
          rote.reqs = prettyPrintPrereqs(rote.reqs);
          return rote;
        }),
    );
  },
});
