import { A } from '@ember/array';
import { computed } from '@ember/object';
import Component from '@ember/component';
import { inject as service } from '@ember/service';
import { prettyPrintPrereqs } from './cod-chargen';

export default Component.extend({
  tagName: '',
  flashMessages: service(),
  gameApi: service(),
  rote_fields: {
    practice: 'Practice',
    cost: 'Cost',
    primary_factor: 'Primary Factor',
    reqs: 'Prerequisites',
  },
  selectedOrder: computed('cg_sheet.classifications.secondary', function () {
    return this.cg_lists.template_info.order.find(
      (o) => o.name === this.cg_sheet.classifications?.secondary,
    );
  }),
  rotesList: computed(
    'cg_lists.rotes.@each.name',
    'cg_lists.praxes.@each.name',
    'cg_sheet.arcana.@each.rating',
    function () {
      const filter = this.cg_lists.rotes.filter((r) => {
        const arcanum = this.cg_sheet.arcana.find((a) =>
          r.reqs?.startsWith(`Ability:${a.name}`),
        );
        const req = parseInt(r.reqs.split(' ')[0]?.split(':')[2] || '5');
        return arcanum ? arcanum.rating >= req : false;
      });
      return filter.map((r) => r.name);
    },
  ),
  praxes: computed('cg_sheet.merits.@each', function () {
    let count = 1;
    count +=
      this.cg_sheet?.merits?.filter((m) => m.name === 'Gnosis Increase')
        ?.length || 0;
    for (let i = 0; i < count; i++) {
      if (!this.cg_sheet.praxes[i]) {
        this.get('cg_sheet.praxes').addObject(this.getNewPraxis());
      }
      this.set('cg_sheet.praxes', this.cg_sheet.praxes?.slice(0, count) || []);
    }
    return this.cg_sheet.praxes;
  }),
  getNewPraxis() {
    return {
      name: '',
      cost: null,
      practice: '',
      primary_factor: '',
      reqs: '',
      withstand: '',
      page: '',
      book: '',
    };
  },
  init() {
    this._super(...arguments);
    if (!this.cg_sheet.praxes) {
      this.set(
        'cg_sheet.praxes',
        this.cg_lists.praxes.map((c) => ({})),
      );
    }
    if (!this.cg_sheet.arcana) {
      this.set(
        'cg_sheet.arcana',
        this.cg_lists.arcana.map((c) => ({
          name: c.name,
          rating: 0,
        })),
      );
    }

    if (!this.cg_sheet.rotes) {
      this.set(
        'cg_sheet.rotes',
        A(Array(this.cg_lists.template_info.rotes).fill({ name: '' })),
      );
    }

    this.set(
      'rotes_list',
      this.cg_lists.rotes.map((c) => c.name),
    );
    const rotes = [];
    for (let i = 0; i < this.cg_lists.template_info.rotes; i++) {
      rotes.push({ type: 'rote', options: this.rotesList });
    }
    this.set('rotes', A(rotes));
  },

  validateChar() {},
  actions: {
    setRoteSkill(index, skill) {
      if (!this.cg_sheet.rotes[index]) return;
      this.set(`cg_sheet.rotes.${index}.spec`, skill);
    },
    setRote(index, rote) {
      const selected = this.cg_lists.rotes.find((a) => a.name === rote);
      selected.reqs = prettyPrintPrereqs(selected.reqs);
      this.set(`rotes.${index}.selected`, selected);
      this.set(`cg_sheet.rotes.${index}`, selected);
    },
    setPraxis(index, praxis) {
      const selected = this.cg_lists.praxes.find((a) => a.name === praxis);
      selected.reqs = prettyPrintPrereqs(selected.reqs);
      this.set(`praxes.${index}.selected`, selected);
      this.set(`cg_sheet.praxes.${index}`, selected);
    },
    arcanaChanged() {},
  },
});
