SmsCheckbox = function(config){
  SmsCheckbox.superclass.constructor.call(this, config);
};
Ext.extend(SmsCheckbox, Ext.form.Checkbox, {
  onRender: function(ct, position) {
    Ext.apply(this, {
      inputValue: '1'
    });
    SmsCheckbox.superclass.onRender.call(this, ct, position);
    Ext.DomHelper.insertBefore(this.el, {
      tag: 'input',
      type: 'hidden',
      value: '0',
      name: this.getName()
    });
  }
});
Ext.reg('smscheckbox', SmsCheckbox);