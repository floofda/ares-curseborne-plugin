import { computed } from '@ember/object';
import Component from '@ember/component';

export default Component.extend({
  showDecrement: computed('cursor', function () {
    return this.get('cursor') !== 0;
  }),
  showIncrement: computed('cursor', function () {
    return this.get('cursor') < this.get('steps')?.length - 1;
  }),
  didReceiveAttrs() {
    if (!this.maxRating) {
      this.set('maxRating', this.steps.slice(-1)[0]);
    }
  },
  didInsertElement() {
    this._super(...arguments);

    if (!this.steps) {
      this.steps = [];
      for (let i = this.minRating; i <= this.maxRating; i++) {
        this.steps.push(i);
      }
    }

    this.set(
      'cursor',
      this.steps.indexOf(this.rating >= 0 ? this.rating : this.minRating),
    );
  },
  actions: {
    increment() {
      if (this.cursor < this.steps.length - 1) {
        this.set('cursor', this.cursor + 1);
        this.set('rating', this.steps[this.cursor]);
      }
      this.updated();
    },
    decrement() {
      if (this.cursor > 0) {
        this.set('cursor', this.cursor - 1);
        this.set('rating', this.steps[this.cursor]);
      }
      this.updated();
    },
  },
});
