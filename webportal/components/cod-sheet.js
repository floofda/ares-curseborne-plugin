import Component from '@ember/component';
import { computed } from '@ember/object';

export default Component.extend({
  tagName: '',
  xp: computed('sheet', function () {
    return `${this.sheet.curr_xp} / ${this.sheet.xp}`;
  }),
  mentalAttrs: computed('sheet.attributes', function () {
    return this.sheet.attributes?.filter((a) => a.category === 'mental');
  }),
  physicalAttrs: computed('sheet.attributes', function () {
    return this.sheet.attributes?.filter((a) => a.category === 'physical');
  }),
  socialAttrs: computed('sheet.attributes', function () {
    return this.sheet.attributes?.filter((a) => a.category === 'social');
  }),

  mentalSkills: computed('sheet.skills', function () {
    return this.sheet.skills?.filter((s) => s.category === 'mental');
  }),
  physicalSkills: computed('sheet.skills', function () {
    return this.sheet.skills?.filter((s) => s.category === 'physical');
  }),
  socialSkills: computed('sheet.skills', function () {
    return this.sheet.skills?.filter((s) => s.category === 'social');
  }),
});
