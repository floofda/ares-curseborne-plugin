import { computed } from '@ember/object';
import { A } from '@ember/array';
import Component from '@ember/component';
import { inject as service } from '@ember/service';

export default Component.extend({
  tagName: '',
  flashMessages: service(),
  gameApi: service(),
  power: computed('cg_sheet.attributes.@each.rating', function () {
    return this.attributesByType('power');
  }),
  finesse: computed('cg_sheet.attributes.@each.rating', function () {
    return this.attributesByType('finesse');
  }),
  resistance: computed('cg_sheet.attributes.@each.rating', function () {
    return this.attributesByType('resistance');
  }),
  mentalPoints: computed('cg_sheet.attributes.@each.rating', function () {
    return this.pointsByCategory('mental');
  }),
  physicalPoints: computed('cg_sheet.attributes.@each.rating', function () {
    return this.pointsByCategory('physical');
  }),
  socialPoints: computed('cg_sheet.attributes.@each.rating', function () {
    return this.pointsByCategory('social');
  }),
  attributesByType(type) {
    return (this.cg_sheet.attributes || []).filter((a) => a.type === type);
  },
  pointsByCategory(category) {
    return (
      (this.get('cg_sheet.attributes') || [])
        .filter((a) => a.category === category)
        .reduce((curr, next) => (curr = curr + next.rating), 0) - 3
    );
  },
  didInsertElement() {
    this._super(...arguments);
    if (!this.cg_sheet.attributes) {
      const min = this.cg_info.min_attr;
      const sheet_attrs = [];
      this.cg_lists.attributes.forEach((a) => {
        const copy = {};
        Object.assign(copy, a);
        copy.rating = min;
        sheet_attrs.push(copy);
      });
      this.set('cg_sheet.attributes', A(sheet_attrs));
    }
  },
  actions: {
    attrChanged() {},
  },
});
