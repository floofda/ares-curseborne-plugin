import { computed } from '@ember/object';
import Component from '@ember/component';

export default Component.extend({
  tagName: '',
  ability_links: computed('sheet', function () {
    return (
      this.char.custom.sheet.template_config.abilities?.reduce((a, b) => {
        a[b.key] = b.plural;
        return a;
      }, {}) || {}
    );
  }),
});
