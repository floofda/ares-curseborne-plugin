import { computed } from '@ember/object';
import Component from '@ember/component';
import { inject as service } from '@ember/service';

export default Component.extend({
  gameApi: service(),
  tagName: '',
  selectAwardBeats: false,
  beats: null,
  message: null,
  selectedChar: null,
  init() {
    this._super(...arguments);
    this.set('selectedChar', this.job.author);
    console.log(this.job.author, this.get('selectedChar'));
  },
  clearForm() {
    this.set('selectAwardBeats', false);
    this.set('beats', null);
    this.set('message', null);
  },
  getSelectedChar(name) {
    return [this.job.author, ...this.job.participants].find(
      (c) => c.name === name,
    );
  },
  didReceiveAttrs() {
    this._super(...arguments);
    this.set('selectedChar', this.job.author);
  },
  selectableChars: computed('job.particpants,author', function () {
    return [this.job.author, ...this.job.participants].map((c) => c.name) || [];
  }),
  canSelect: computed('selectableChars', function () {
    return this.selectableChars?.length > 1;
  }),
  actions: {
    selectChar(name) {
      this.set('selectedChar', this.getSelectedChar(name));
    },
    awardBeats() {
      this.set('selectAwardBeats', false);
      this.gameApi
        .requestOne(
          'awardBeats',
          {
            id: this.job.id,
            char: this.selectedChar?.name,
            beats: this.beats,
            message: this.message,
          },
          null,
        )
        .then((res) => {
          if (res.c_error) {
            alertify.error(res.c_error);
            return;
          }
          this.clearForm();
        });
    },
  },
});
