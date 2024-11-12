import Component from '@ember/component';

export default Component.extend({
  didReceiveAttrs() {
    if (this.contract.data) {
      this.set('contract_data', { ...this.contract.data });
    } else {
      this.set('contract_data', { ...this.contract });
    }
  },
});
