import { A } from '@ember/array';
import { computed } from '@ember/object';
import Component from '@ember/component';
import { inject as service } from '@ember/service';

export default Component.extend({
  tagName: '',
  flashMessages: service(),
  gameApi: service(),
  modificationsList: computed('cg_lists.form_abilities', function () {
    return this.cg_lists.form_abilities
      ?.filter((a) => a.category === 'Modification')
      .map((a) => a.name);
  }),
  technologiesList: computed('cg_lists.form_abilities', function () {
    return this.cg_lists.form_abilities
      ?.filter((a) => a.category === 'Technology')
      .map((a) => a.name);
  }),
  propulsionsList: computed('cg_lists.form_abilities', function () {
    return this.cg_lists.form_abilities
      ?.filter((a) => a.category === 'Propulsion')
      .map((a) => a.name);
  }),
  processesList: computed('cg_lists.form_abilities', function () {
    return this.cg_lists.form_abilities
      ?.filter((a) => a.category === 'Process')
      .map((a) => a.name);
  }),
  selectedEmbeds: [],
  init() {
    this._super(...arguments);
    this.set(
      'embedsAndExploits',
      this.cg_lists.embeds.concat(this.cg_lists.exploits),
    );

    this.set('temp_sheet', []);
    this.set(
      'temp_sheet.embeds_and_exploits',
      this.cg_sheet.embeds?.concat(this.cg_sheet?.exploits || []) || [],
    );

    if (!this.cg_sheet.form_abilities) {
      const total = Object.values(
        this.cg_lists.template_info.form_abilities,
      ).reduce((a, n) => (a += n), 0);
      this.set('cg_sheet.form_abilities', A(Array(total).fill({ name: '' })));
    }

    this.set(
      'embeds_and_exploits_list',
      this.get('embedsAndExploits').map((c) => c.name),
    );

    const embeds_and_exploits = [];
    for (
      let i = 0;
      i < this.cg_lists.template_info.embeds_and_exploits.max;
      i++
    ) {
      embeds_and_exploits.push({
        type: 'embeds and exploits',
        options: this.get('embeds_and_exploits_list'),
      });
    }
    this.set('embeds_and_exploits', A(embeds_and_exploits));

    this.set(
      'form_abilities_list',
      this.cg_lists.form_abilities.map((c) => c.name),
    );
    const form_abilities = [];
    for (const [t, c] of Object.entries(
      this.cg_lists.template_info.form_abilities,
    )) {
      for (let i = 0; i < c; i++) {
        form_abilities.push({
          type: t,
          options: this.get(`${t}List`),
        });
      }
    }
    this.set('form_abilities', A(form_abilities));
  },

  validateChar() {},
  actions: {
    setExploitEmbed(index, embed) {
      this.set(`temp_sheet.embeds_and_exploits.${index}.spec`, embed);
      this.set(
        'cg_sheet.exploits',
        this.temp_sheet.embeds_and_exploits.filter(
          (e) => e.group === 'Exploit',
        ),
      );
      this.set(
        'cg_sheet.embeds',
        this.temp_sheet.embeds_and_exploits.filter((e) => e.group === 'Embed'),
      );
    },
    setEmbedAndExploit(index, embeds_and_exploits) {
      const selected = this.get('embedsAndExploits').find(
        (a) => a.name === embeds_and_exploits,
      );
      this.set(`embeds_and_exploits.${index}.selected`, selected);
      this.set(`temp_sheet.embeds_and_exploits.${index}`, selected);
      this.set(
        'selectedEmbeds',
        this.temp_sheet.embeds_and_exploits
          .filter((a) => a.group === 'Embed')
          .map((a) => a.name),
      );
      this.set(
        'cg_sheet.exploits',
        this.temp_sheet.embeds_and_exploits.filter(
          (e) => e.group === 'Exploit',
        ),
      );
      this.set(
        'cg_sheet.embeds',
        this.temp_sheet.embeds_and_exploits.filter((e) => e.group === 'Embed'),
      );
    },
    setFormAbility(index, form_ability) {
      const selected = this.cg_lists.form_abilities.find(
        (a) => a.name === form_ability,
      );
      this.set(`form_abilities.${index}.selected`, selected);
      this.set(`cg_sheet.form_abilities.${index}`, selected);
    },
  },
});
