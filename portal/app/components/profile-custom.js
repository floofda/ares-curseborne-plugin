import Component from '@ember/component';
import { computed } from '@ember/object';

export default Component.extend({
  tagName: '',
  template_components: computed('sheet', function () {
    return (
      this.char.custom.sheet.template_config.abilities?.reduce((a, b) => {
        a[b.key] = `cod-sheet-${b.key}`;
        return a;
      }, {}) || {}
    );
  }),
  actions: {
    reloadChar() {
      this.reloadChar();
    },
  },
});
