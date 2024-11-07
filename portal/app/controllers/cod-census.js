import { computed } from '@ember/object';
import Controller from '@ember/controller';

export default Controller.extend({
  filter: null,
  order_by: null,
  order: computed('order_by', function () {
    return this.order_by !== null;
  }),
  titles: computed('filter', function () {
    const titles = this.model.census.titles[this.filter] || {};
    const titleList = {
      name: 'Name',
      template: 'Template',
      primary: titles.primary || 'Primary',
      secondary: titles.secondary || 'Secondary',
      tertiary: titles.tertiary || 'Tertiary',
      age: 'Age',
    };
    return titleList;
  }),

  orderedList: computed('filter', 'order_by', function () {
    const charList = [...this.get('model.census.chars')];
    const list = !this.filter
      ? charList
      : charList.filter((c) => c.template === this.filter);

    if (!this.order_by) return list;
    if (['template', 'age', 'name'].includes(this.order_by)) {
      const field = this.order_by;
      return list.sort((a, b) => {
        if (a[field] < b[field]) return -1;
        if (a[field] > b[field]) return 1;
        return 0;
      });
    } else if (['primary', 'secondary', 'tertiary'].includes(this.order_by)) {
      const field = this.order_by;
      return list.sort((a, b) => {
        if (a[field]?.value < b[field]?.value) return -1;
        if (a[field]?.value > b[field]?.value) return 1;
        return 0;
      });
    }
  }),
  actions: {
    filterOnTemplate(template) {
      this.set('filter', template);
      if (template === null && ![null, 'template'].includes(this.order_by)) {
        this.set('order_by', null);
      }
    },
    orderBy(field) {
      if (field !== null && field.toLowerCase() === this.order_by) {
        this.set('order_by', null);
      } else {
        this.set('order_by', field);
      }
    },
  },
});
