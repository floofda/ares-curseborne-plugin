import Component from '@ember/component';
import { computed } from '@ember/object';

export default Component.extend({
  tagName: 'span',

  dots: computed('rating', function () {
    let rating = this.rating;
    return new Array(this.max).fill({}).map(function (fill, i) {
      return { fill: i + 1 <= rating };
    });
  }),
});
