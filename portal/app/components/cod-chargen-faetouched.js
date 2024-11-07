import { A } from '@ember/array';
import Component from '@ember/component';
import { inject as service } from '@ember/service';

export default Component.extend({
  tagName: '',
  flashMessages: service(),
  gameApi: service(),
  didInsertElement() {
    this._super(...arguments);

    if (!this.cg_sheet.contracts) {
      const total = Object.values(this.cg_lists.template_info.contracts).reduce(
        (a, n) => (a += n),
        0,
      );
      this.set('cg_sheet.contracts', A(Array(total).fill({ name: '' })));
    }

    this.set(
      'commonContracts',
      this.cg_lists.contracts
        .filter(
          (c) =>
            c.type === 'Common' ||
            (c.type === 'Common' && c.group === 'Regalia'),
        )
        .map((c) => c.name),
    );

    const contracts = [];
    for (const [t, c] of Object.entries(
      this.cg_lists.template_info.contracts,
    )) {
      for (let i = 0; i < c; i++) {
        contracts.push({ type: t, options: this[`${t}Contracts`] });
      }
    }
    this.set('contracts', A(contracts));
  },

  validateChar() {},
  actions: {
    setContract(index, contract) {
      const selected = this.cg_lists.contracts.find((a) => a.name === contract);
      this.set(`contracts.${index}.selected`, selected);
      this.set(`cg_sheet.contracts.${index}`, selected);
    },
  },
});
