import { computed } from '@ember/object';
import Component from '@ember/component';

export default Component.extend({
  didInsertElement() {
    this._super(...arguments);
  },
  basicInfo: computed('char.demographics', function () {
    return this.char.demographics
      .filter((d) => {
        return ['Full Name', 'Age'].includes(d.name);
      })
      .concat(...(this.char.custom.sheet?.anchors || []));
  }),
});
