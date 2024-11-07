import { A } from '@ember/array';
import { computed } from '@ember/object';
import Component from '@ember/component';
import { inject as service } from '@ember/service';

export default Component.extend({
  tagName: '',
  flashMessages: service(),
  gameApi: service(),
  blessing_fields: {
    practice: 'Practice',
    cost: 'Cost',
    primary_factor: 'Primary Factor',
    reqs: 'Prerequisites',
  },
  blessingsList: computed('cg_lists.blessings.@each', function () {
    const filter = this.cg_lists.blessings.filter((r) => {
      const req = parseInt(r.reqs.split(' ')[0]?.split(':')[2] || '5');
      return 3 >= req;
    });
    return filter.map((r) => r.name);
  }),
  blessings: computed('cg_sheet.fields', function () {
    const count = this.cg_lists.template_info.blessings;
    for (let i = 0; i < count; i++) {
      if (!this.cg_sheet.blessings[i]) {
        this.get('cg_sheet.blessings').addObject(this.getNewBlessing());
      }
    }
    return this.cg_sheet.blessings;
  }),
  getNewBlessing() {
    return {
      name: '',
      cost: null,
      practice: '',
      primary_factor: '',
      withstand: '',
      page: '',
      book: '',
    };
  },
  init() {
    this._super(...arguments);
    if (!this.cg_sheet.blessings) {
      this.set(
        'cg_sheet.blessings',
        A(Array(this.cg_lists.template_info.blessings).fill({ name: '' })),
      );
    }
    this.set(
      'blessings_list',
      this.cg_lists.blessings.map((c) => c.name),
    );
  },

  validateChar() {},
  actions: {
    setBlessing(index, blessing) {
      const selected = {
        ...this.cg_lists.blessings.find((a) => a.name === blessing),
      };

      selected.rating = parseInt(
        selected.reqs.split(' ')[0]?.split(':')[2] || '5',
      );
      delete selected.reqs;
      delete selected.rote_skills;
      this.set(`blessings.${index}.selected`, selected);
      this.set(`cg_sheet.blessings.${index}`, selected);
    },
    arcanaChanged() {},
  },
});
