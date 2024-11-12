import { computed } from '@ember/object';
import { A } from '@ember/array';
import Component from '@ember/component';
import { inject as service } from '@ember/service';

export default Component.extend({
  tagName: '',
  flashMessages: service(),
  gameApi: service(),

  didInsertElement() {
    this._super(...arguments);

    if (!this.cg_sheet.skills) {
      const sheet_skills = [];
      this.cg_lists.skills.forEach((s) => {
        const copy = {};
        Object.assign(copy, s);
        copy.rating = 0;
        sheet_skills.push(copy);
      });
      this.set('cg_sheet.skills', A(sheet_skills));
    }

    const skillList = this.cg_sheet.skills.map((s) => ({
      skill: s.name,
      specs: (s.specialties || []).join(', '),
    }));

    const specs = [];
    const cg_specs = [];
    const spec_count =
      this.cg_lists.template_info?.specialties || this.cg_info.specialties || 0;
    for (let i = 0; i < spec_count; i++) {
      specs.push({ options: skillList, examples: null });
      cg_specs.push({ skill: '', specialty: '' });
    }
    this.set('specialties', specs);
    if (!this.get('cg_sheet.specialties')) {
      this.set('cg_sheet.specialties', A(cg_specs));
    }
  },
  mental: computed('cg_sheet.skills.@each.rating', function () {
    return this.skillsByCategory('mental');
  }),
  physical: computed('cg_sheet.skills.@each.rating', function () {
    return this.skillsByCategory('physical');
  }),
  social: computed('cg_sheet.skills.@each.rating', function () {
    return this.skillsByCategory('social');
  }),
  mentalPoints: computed('cg_sheet.skills.@each.rating', function () {
    return this.pointsByCategory('mental');
  }),
  physicalPoints: computed('cg_sheet.skills.@each.rating', function () {
    return this.pointsByCategory('physical');
  }),
  socialPoints: computed('cg_sheet.skills.@each.rating', function () {
    return this.pointsByCategory('social');
  }),
  skillsByCategory(category) {
    return (this.get('cg_sheet.skills') || []).filter(
      (a) => a.category === category,
    );
  },
  pointsByCategory(category) {
    return this.skillsByCategory(category).reduce(
      (curr, next) => (curr = curr + next.rating),
      0,
    );
  },

  actions: {
    skillChanged() {},
    specSkillChanged(index, skill) {
      this.set(`cg_sheet.specialties.${index}.skill`, skill.skill);
      this.set(`specialties.${index}.examples`, `Examples: ${skill.specs}`);
    },
    addSpecialty(index, event) {
      const spec = this.get('cg_sheet.specialties').objectAt(index);
      spec.specialty = event.srcElement.value;
    },
  },
});
