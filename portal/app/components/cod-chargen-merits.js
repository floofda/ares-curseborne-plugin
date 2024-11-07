import { computed } from '@ember/object';
import { A } from '@ember/array';
import Component from '@ember/component';
import { inject as service } from '@ember/service';
import { prettyPrintPrereqs } from './cod-chargen';

export default Component.extend({
  tagName: '',
  flashMessages: service(),
  gameApi: service(),

  didInsertElement() {
    this._super(...arguments);

    if (!this.cg_sheet.merits) {
      this.set('cg_sheet.merits', A());
    }
    const options = [];
    this.cg_lists.merits.forEach((m) => {
      options.push({
        name: m.name,
        cost: Array.isArray(m.cost) ? m.cost : [m.cost],
        has_spec: m.has_spec,
        spec: '',
      });
    });
    this.set('meritOptions', options);
  },
  meritPoints: computed('cg_sheet.merits.@each.rating', function () {
    if (!this.cg_sheet.merits) return 0;
    return this.cg_sheet.merits.reduce(
      (curr, next) => (curr = curr + next.rating),
      0,
    );
  }),
  getMeritObject() {
    return {
      name: '',
      spec: '',
      cost: [0],
      rating: 0,
      has_spec: false,
      details: null,
      options: this.meritOptions,
    };
  },
  addMerit() {
    this.get('cg_sheet.merits').addObject(this.getMeritObject());
  },
  validateChar() {},

  actions: {
    addMerit() {
      this.addMerit();
    },
    deleteMerit(index) {
      this.get('cg_sheet.merits').removeAt(index);
    },
    meritChanged(index, m) {
      const selectedName = m.name;
      const merit = this.cg_lists.merits.find((m) => m.name === selectedName);
      const cost = Array.isArray(merit.cost) ? merit.cost : [merit.cost];
      const selected = this.getMeritObject();

      delete selected.options;
      selected.name = merit.name;
      selected.cost = cost;
      selected.dots = cost.join(', ');
      selected.has_spec = merit.has_spec;
      selected.rating = cost[0];
      selected.details = {};
      Object.assign(selected.details, merit);
      if (selected.details?.reqs) {
        selected.details.reqs = prettyPrintPrereqs(selected.details.reqs);
      }
      this.get('cg_sheet.merits').replace(index, 1, [selected]);
    },
    meritCostUpdated() {},
    addSpecifics(index, event) {
      this.set(`cg_sheet.merits.${index}.spec`, event.srcElement.value);
    },
  },
});
