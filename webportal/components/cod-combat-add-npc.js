import Component from '@ember/component';
import { inject as service } from '@ember/service';

function convertToFormFields(sheet) {
  const formSheet = {};
  for (const [k, v] of Object.entries(sheet)) {
    formSheet[k] = {
      key: k,
      value: v,
      display: k
        .split('_')
        .map((k) => k[0].toUpperCase() + k.slice(1))
        .join(' '),
    };
  }
  return formSheet;
}

export default Component.extend({
  gameApi: service(),
  editNpc: null,
  formData: null,
  displayNpcs: null,
  init() {
    this._super(...arguments);
    this.gameApi.requestMany('npcTemplates').then((res) => {
      if (res.error) return;
      this.clearForm();
      const templates = [];
      res.forEach((t) => {
        const sheet = convertToFormFields(t.sheet);
        templates.push({ ...t, sheet: sheet });
      });
      this.set('templates', templates);
      this.set('baseTemplates', res);
    });
  },
  didReceiveAttrs() {
    this._super(...arguments);
    if (this.formData) {
      const formSheet = convertToFormFields(this.formData.sheet);
      this.set('selectedTemplate', { ...this.formData, sheet: formSheet });
    }
  },
  clearForm() {
    this.set('selectedTemplate', null);
    this.set('formData', null);
    this.set('showNpcForm', false);
    this.set('add', true);
  },
  actions: {
    addNpc() {
      this.gameApi
        .requestOne('addNpc', {
          combat_id: this.combat.id,
          npc: { ...this.formData },
        })
        .then((res) => {
          if (res.error) return;
          this.clearForm();
        });
    },
    editNpc(edit) {
      this.set('add', !!edit);
    },
    updateNpc() {
      this.gameApi
        .requestOne('updateNpc', {
          combat_id: this.combat.id,
          npc: { ...this.formData },
        })
        .then((res) => {
          if (res.error) return;
          this.clearForm();
        });
    },
    updateNpcData(event) {
      this.set(`formData.${event.srcElement.name}`, event.srcElement.value);
    },
    updateSheetData(field, event) {
      this.set(`formData.sheet.${field}`, event.srcElement.value);
    },
    updateTemplate(template) {
      const npc = {
        ...this.baseTemplates?.find((t) => t.name === template.name),
      };
      this.set('selectedTemplate', template);
      this.set('formData', npc);
    },
  },
});
