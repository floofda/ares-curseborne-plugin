import EmberObject, { computed } from '@ember/object';
import { A } from '@ember/array';
import Component from '@ember/component';
import { inject as service } from '@ember/service';

export const prettyPrintPrereqs = (str = '') => {
  return str
    .replace(/Attribute:|Skill:|Merit:|Ability:|Field:|Special:/g, '')
    .replace(/:/g, ' ')
    .replace(/\|/g, 'or')
    .replace(/[ ]?&/g, ',');
};

export default Component.extend({
  tagName: '',
  fields: EmberObject.create({}),
  selectedTemplate: '',
  flashMessages: service(),
  gameApi: service(),

  init() {
    this._super(...arguments);
    this.set('selectedTemplate', this.get('char.custom.sheet.template'));
    this.set(
      'template_component',
      this.template_info.abilities
        ? `cod-chargen-${this.selectedTemplate.replace('-', '')}`.toLowerCase()
        : null,
    );
    if (!this.cg_sheet.concept) {
      this.set('cg_sheet.concept', '');
    }
    if (!this.cg_sheet.anchors) {
      this.set('cg_sheet.anchors', A());
    }
    if (!this.cg_sheet.fields && this.template_info.fields) {
      this.set(
        'cg_sheet.fields',
        A(this.template_info.fields.map((f) => ({ field: null, name: null }))),
      );
    }
    if (!this.cg_sheet.classifications) {
      this.set('cg_sheet.classifications', {});
    }

    if (this.template_info.classifications) {
      ['primary', 'secondary', 'tertiary'].forEach((c) => {
        if (!this.template_info.classifications[c]) return;
        this.set(
          `${c}ClassList`,
          this.template_info[
            this.template_info.classifications[c]?.toLowerCase()
          ]?.map((i) => i.name),
        );
      });
    }
  },

  didInsertElement() {
    this.set('updateCallback', () => this.onUpdate());
    this.set('validateCallback', () => this.validateChar());
    this.validateChar();
  },

  onUpdate: function () {},

  setupTemplate: function () {
    this.gameApi
      .requestOne(
        'setupTemplate',
        { id: this.get('char.id'), template: this.get('selectedTemplate') },
        null,
      )
      .then((response) => {
        if (response.error) {
          return;
        }
        this.flashMessages.success('New template set!');
        setTimeout(() => location.reload(), 300);
      });
  },

  validateChar: function () {},

  actions: {
    updateCgSheet() {
      this.onUpdate();
    },
    setupTemplate() {
      this.setupTemplate();
    },
    updateField(field, index, value) {
      this.set(`template_info.fields.${index}.selected`, value);
      value.field = field;
      this.set(`cg_sheet.fields.${index}`, value);
    },
    selectTemplate(template) {
      this.set('selectedTemplate', template);
    },
    setConcept(event) {
      this.set('cg_sheet.concept', event.srcElement.value);
    },
    addAnchor(index, event) {
      this.set(`cg_sheet.anchors.${index}`, event.srcElement.value);
    },
    setClassification(classification, type) {
      this.set(`cg_sheet.classifications.${classification}`, type);
    },
  },
});
