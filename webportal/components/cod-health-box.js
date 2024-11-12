import Component from '@ember/component';
import { computed } from '@ember/object';

export default Component.extend({
  tagName: 'span',

  getDamageType(i) {
    switch (true) {
      case i < this.agg:
        return 'agg';
      case i < this.agg + this.lethal:
        return 'lethal';
      case i < this.agg + this.lethal + this.bashing:
        return 'bashing';
      default:
        return 'empty';
    }
  },
  boxes: computed('health', function () {
    return new Array(this.health).fill({}).map((_, i) => {
      return { fill_type: this.getDamageType(i) };
    });
  }),
});
