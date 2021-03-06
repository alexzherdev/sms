var FolderTreeNodeUI = Ext.extend(Ext.tree.TreeNodeUI, {
  render: function() {
    FolderTreeNodeUI.superclass.render.call(this);
    if (this.node.attributes.unread_count > 0) {
      this.addClass("folder-with-unread");
    } else {
      this.removeClass("folder-with-unread");
    }
  },
});

var Mailbox = Class.create({
  initialize: function(config) {
    this.config = config;
    this.folders = $A(config.folders);
    
    this.observe("folderChanged", this.updateFolderToolbar.bind(this));
    this.observe("messageChanged", this.updateMessageToolbar.bind(this));

    Ext.apply(this, config);
    
    this.initFolderTree();
    this.initFolderView();
    this.initFolderViewPanel();

    this.initMessageViewPanel();
    this.initNewMessagePanel();
    
    this.initContentPanel();
    this.initContainerPanel();
    
    this.initRecipientGrid();
    this.initRecipientFilter();
    this.initRecipientsPopup();
    
    this.waiting_el = $('mailbox_content_panel');
  },
  
  initFolderTree: function() {
    this.folder_tree = new Ext.tree.TreePanel({
      mailbox: this,
      flex: 1,
      root: {
        expanded: true,
        draggable: false
      },
      loader: new Ext.tree.TreeLoader({
        initialLoad: true,      
        mailbox: this,
        dataUrl: this.folders_url,
        listeners: {
          load: function() {
            if (this.initialLoad) {
              this.mailbox.selectFolder(this.mailbox.initial_folder_id);
              this.initialLoad = false;
            }
          }
        }
      }),
      rootVisible: false,
      lines: false,
      width: 150,
      height: 500,
      listeners: {
        click: function(node) {
          this.showFolder(node.attributes);
        }.bind(this)
      },
      cls: 'folder-tree'
    });
  },
  
  initContentPanel: function() {
    this.content_panel = new Ext.Panel({
      autoDestroy: false,
      layout: 'card',
      bodyCfg: {
        id: 'mailbox_content_panel',
        cls: 'mailbox-content-panel'
      },
      flex: 4,
      height: 500,
      items: [
        this.new_message_panel,
        this.folder_view_panel,
        this.message_view_panel
      ]
    });   
  },
  
  initMessageViewPanel: function() {
    this.message_view_panel = new Ext.Panel({
      //width: 608,
      height: 500,
      id: 'message_view_panel',
      tbar: [
      {
        text: "Вернуться в папку",
        handler: function() {
          this.selectFolder(this.current_folder.id);
        }.bind(this)
      },
      '-',
      {
        text: "Ответить",
        iconCls: "x-btn-text-icon reply-message",
        handler: function() {
          this.reply();
        }.bind(this)
      },
      {
        text: "Ответить всем",
        iconCls: "x-btn-text-icon reply-all-message",
        handler: function() {
          this.replyAll();
        }.bind(this)
      },
      {
        text: "Переслать",
        iconCls: "x-btn-text-icon forward-message",
        handler: function() {
          this.forward();
        }.bind(this)
      },
      '-',
      {
        id: 'restore',
        iconCls: 'x-btn-text-icon restore-message',
        text: 'Восстановить',
        handler: function() {
          this.restoreMessages([this.message_store.getById(this.current_message.uid)]);
        }.bind(this)
      },
      {
        id: 'delete',
        text: "Удалить",
        iconCls: 'x-btn-text-icon cross',
        handler: function() {
          this.deleteMessages([this.message_store.getById(this.current_message.uid)]);
        }.bind(this)
      }
      ],
      tpl: new Ext.XTemplate(this.message_view_tpl)
    });
  },
  
  initNewMessagePanel: function() {
    this.new_message_panel = new Ext.Panel({
      id: 'new_message_panel',
      contentEl: 'new_message_form'
    });
    
    this.new_message_recipients = Ext.getCmp("new_msg_recipients");
    this.new_message_subject = Ext.getCmp("new_msg_subject");
    this.new_message_body = Ext.getCmp("new_msg_body");
    this.new_message_hidden_to = $("new_msg_hidden_to");
  },
  
  initRecipientGrid: function() {
    var sm = new Ext.grid.CheckboxSelectionModel();
    var cm = new Ext.grid.ColumnModel({
      columns: [
        sm,
        { hidden: true, dataIndex: "id" },
        { header: "", dataIndex: "full_name_abbr", width: 220 }
      ]
    });

    this.recipient_grid = new Ext.grid.GridPanel({
      store: this.recipient_store,
      cm: cm,
      sm: sm,
      renderTo: "recipient_grid_container",
      width: 280,
      height: 400
    });
  },

  initRecipientFilter: function() {
    this.recipient_filter_text = new Ext.form.TextField({
      renderTo: "recipient_filter_container",
      width: 237,
      enableKeyEvents: true,
      listeners: {
        keyup: function(ev) {
          filterCriteria = new RegExp("^" + this.recipient_filter_text.getValue());
          this.recipient_store.filter("full_name_abbr", filterCriteria, true, true);
        }.bind(this)
      }
    });
  },
  
  initRecipientsPopup: function() {
    this.recipients_popup = new Ext.Window({
      el: 'popup',
      title: "Выберите получателей",
      layout: 'fit',
      width: 300,
      height: 500,
      closeAction: 'hide',
      animateTarget: null,
      plain: true,
      modal: true,

      items: new Ext.Panel({
        el: 'popup_main',
        deferredRender: true,
        border: false
      }),

      listeners: {
        beforeshow: function() {
          this.recipient_grid.getSelectionModel().selectRecords(this.current_recipients || []);
        }.bind(this)
      },
      
      buttons: [
      { 
        text: "OK",
        handler: function() {
          this.recipients_popup.hide();
          this.setRecipients(this.recipient_grid.getSelectionModel().getSelections());
        }.bind(this)
      },
      { 
        text: "Отмена",
        handler: function() {
          this.recipients_popup.hide();  
        }.bind(this)
      }]
    });  
  },
  
  initFolderView: function() {
    this.folder_view = new Ext.DataView({
      tpl: new Ext.XTemplate(this.message_tpl),
      itemSelector: 'div.message-row',
      emptyText : '<div style="padding:10px;">Эта папка пуста.</div>',
      store: this.message_store,
      listeners: {
        click: function(view, index, node, event) {
          if (event.getTarget().tagName == "INPUT") {
            return false;
          }
          var record = this.message_store.getAt(index);
          Ext.Ajax.request({
            url: this.show_message_url + "/" + record.get("id"),
            method: 'GET',
            scripts: true,
            params: { copy: record.get("copy?") },
            success: function() {
              this.folder_tree.getLoader().load(this.folder_tree.getRootNode(), function() {
                this.findFolderNodeById(this.current_folder.id).select();
              }.bind(this));              
            }.bind(this)
          });
        }.bind(this)
      }
    });
  },
  
  initFolderViewPanel: function() {
    this.folder_view_panel = new Ext.Panel({
      layout: {
  		  type: 'vbox',
  		  align: 'stretch' 
  		},
  		id: 'folder_view_panel',
      //width: 608,
      height: 500,
      tbar: [{
        id: 'restore-checked',
        iconCls: 'x-btn-text-icon restore-message',
        text: 'Восстановить',
        handler: function() {
          this.restoreSelectedMessages();
        }.bind(this)
      },
      {
        id: 'delete-checked',
        iconCls: 'x-btn-text-icon cross',
        text: 'Удалить',
        handler: function() {
          this.deleteSelectedMessages();
        }.bind(this)
      }
      ],
      items: [
        this.folder_view
      ]
    });
  },
  
  initContainerPanel: function() {
    this.container_panel = new Ext.Panel({
      title: 'Мои сообщения',
      layout: {
        type: 'hbox',
        align: 'stretch' 
      },
      width: 788,
      height: 500,
      tbar: [{
        text: "Новое сообщение",
        iconCls: "x-btn-text-icon new-message",
        handler: function() {
          this.prepareNewMessagePanel("", "", "", []);
          this.content_panel.getLayout().setActiveItem('new_message_panel');
        }.bind(this)
      }],
      items: [
        this.folder_tree,
        this.content_panel
      ],
      renderTo: 'mailbox_container'
    }); 
  },
  
  prepareNewMessagePanel: function(recipients, subject, body, to) {
    this.new_message_subject.setValue(subject);
    this.new_message_body.setValue(body);
    var recipients = this.recipient_store.queryBy(function(rec, id) {
      return $A(to).include(id);
    });
    this.setRecipients(recipients.items);
  },
  
  updateFolderToolbar: function() {
    if (this.current_folder.id == this.trash_id) {
      this.folder_view_panel.getTopToolbar().items.get('restore-checked').show();
    } else {
      this.folder_view_panel.getTopToolbar().items.get('restore-checked').hide();
    }
  },
  
  updateMessageToolbar: function() {
    if (this.current_message.deleted == 1) {
      this.message_view_panel.getTopToolbar().items.each(function(item) {
        item.hide();
      });
      this.message_view_panel.getTopToolbar().items.get('delete').show();
      this.message_view_panel.getTopToolbar().items.get('restore').show();
    } else {
      this.message_view_panel.getTopToolbar().items.each(function(item) {
        item.show();
      });
      this.message_view_panel.getTopToolbar().items.get('delete').show();
      this.message_view_panel.getTopToolbar().items.get('restore').hide();
    }
  },
  
  findFolderById: function(id) {
    return this.folders.detect(function(folder) {
      return folder.id == id;
    });
  },
  
  showFolder: function(folder_attrs) {
    this.waiting_el.startWaiting();
    Ext.Ajax.request({
      url: folder_attrs.url,
      method: 'POST',
      scripts: true,
      success: function() {
        this.current_folder = folder_attrs;
        this.waiting_el.stopWaiting();
        this.fire("folderChanged");
      }.bind(this)
    });
  },
  
  findFolderNodeById: function(id) {
    var result;
    $A(this.folder_tree.root.childNodes).each(function(node) {
      if (node.attributes.id == id) {
        result = node;
        throw $break;
      }
    });
    return result;
  },
  
  selectFolder: function(id) {
    var node = this.findFolderNodeById(id);
    if (node) {
      node.fireEvent("click", node);
    }
  },
  
  updateFolder: function(folder) {
    var f = this.findFolderById(folder.id);
    f.unread_count = folder.unread_count;
  },

  showInboxFolder: function() {
    this.showFolder(this.findFolderNodeById(this.initial_folder_id).attributes);
    this.updateFolderTree();
  },

  updateFolderTree: function() {
    this.folder_tree.getLoader().load(this.folder_tree.getRootNode(), function() {
      this.findFolderNodeById(this.current_folder.id).select();
    }.bind(this));
  },
  
  viewFolderMessages: function(messages) {
    this.content_panel.getLayout().setActiveItem('folder_view_panel');
    this.loadMessages(messages);
    
    // Next chunk performs container expanding when there're a lot of letters.
    // This is temporary code while pagination is unimplemented (you can delete these lines at any time with no harm to app)
    if (messages.length > 20) {
      this.container_panel.setHeight(500 + (messages.length - 20) * 19);
      this.folder_view_panel.setHeight(500 + (messages.length - 20) * 19);
    } else {
      this.container_panel.setHeight(500);
      this.folder_view_panel.setHeight(500);
    }
  },
  
  loadMessages: function(messages) {
    this.message_store.loadData(messages);
  },
  
  viewMessage: function(message) {
    this.current_message = message;
    this.content_panel.getLayout().setActiveItem('message_view_panel');

    if (message.attachments_string != "") {
      var attSplit = message.attachments_string.split("|");
      var attFormatted = "<table><tr><td class=\"message-attachments\" width=\"40\"></td><td>Файлы:<br />";
      for(i = 0; i < attSplit.length; i+=2) {
          attFormatted += "<a href=\"" + attSplit[i + 1] + "\">" + attSplit[i] + "</a><br />"; 
      }
      attFormatted += "</td></tr></table>";
      message.attachments_string = attFormatted;
      s = "visible";
    } else {
      s = "hidden";
    }

    this.message_view_panel.update(this.current_message);

    document.getElementById("attachments_div").style.visibility = s;

    this.fire("messageChanged");
  },
  
  showRecipientsPopup: function() {
    this.recipients_popup.show();
  },  
    
  setRecipients: function(selections) {
    this.current_recipients = selections;
    this.new_message_hidden_to.value = "";
    this.new_message_recipients.setValue("");
    var field_value = '';
    $A(selections).each(function(sel) {
      this.new_message_hidden_to.value += sel.get("id") + ",";
      field_value += sel.get("full_name_abbr") + ", ";
    }.bind(this));
    this.new_message_hidden_to.value = this.new_message_hidden_to.value.substring(0, this.new_message_hidden_to.value.length - 1);
    field_value = field_value.substring(0, field_value.length - 2);
    this.new_message_recipients.setValue(field_value);
  },
  
  showMessageBox: function(text, icon) {
    Ext.MessageBox.show({ title: 'SMS', msg: text, icon: (icon || Ext.MessageBox.INFO), buttons: Ext.MessageBox.OK });
  },
  
  sendMessage: function(form) {
    if ((this.current_recipients || []).length == 0) {
      this.showMessageBox('Укажите получателей письма.');
      return false;
    }
    this.waiting_el.startWaiting();
    Global.submitForm(form);
  },
  
  reply: function() {
    this.waiting_el.startWaiting();
    Ext.Ajax.request({
      url: this.reply_url,
      params: { id: this.current_message.id, copy: this.current_message["copy?"] },
      success: function(response) {
        var json = Ext.decode(response.responseText);
        this.prepareNewMessagePanel(json.recipients_string, json.subject, json.body, json.recipient_ids);
        this.content_panel.getLayout().setActiveItem('new_message_panel');
        this.waiting_el.stopWaiting();
      }.bind(this)
    });
  },
  
  replyAll: function() {
    this.waiting_el.startWaiting();
    Ext.Ajax.request({
      url: this.reply_all_url,
      params: { id: this.current_message.id, copy: this.current_message["copy?"] },
      success: function(response) {
        var json = Ext.decode(response.responseText);
        this.prepareNewMessagePanel(json.recipients_string, json.subject, json.body, json.recipient_ids);
        this.content_panel.getLayout().setActiveItem('new_message_panel');
        this.waiting_el.stopWaiting();
      }.bind(this)
    });
  },
  
  forward: function() {
    this.waiting_el.startWaiting();
    Ext.Ajax.request({
      url: this.forward_url,
      params: { id: this.current_message.id, copy: this.current_message["copy?"] },
      success: function(response) {
        var json = Ext.decode(response.responseText);
        this.prepareNewMessagePanel(json.recipients_string, json.subject, json.body, json.recipient_ids);
        this.content_panel.getLayout().setActiveItem('new_message_panel');
        this.waiting_el.stopWaiting();
      }.bind(this)
    });
  },
  
  collectSelectedMessages: function() {
    var ids = $$('.message-checkbox').collect(function(cb) {
      if (cb.checked) {
        return parseInt(cb.id.substring(6));
      }
    });
    var records = this.message_store.queryBy(function(rec) {
      return $A(ids).include(rec.get("id"));
    });
    return records.items;
  },
  
  collectMessagesPropertyString: function(messages, property) {
    var ids = messages.inject("", function(memo, msg) {
      memo += msg.get(property) + ",";
      return memo;
    });
    ids = ids.substring(0, ids.length - 1);
    return ids;
  },
  
  deleteSelectedMessages: function() {
    var messages = this.collectSelectedMessages();
    if (messages.length == 0) {
      this.showMessageBox('Отметьте сообщения, которые хотите удалить.');
      return;
    }
    this.deleteMessages(messages);
  },
  
  deleteMessages: function(messages) {
    if (this.current_folder.id == this.trash_id) {
      Ext.MessageBox.confirm('SMS', 'Эту операцию нельзя будет отменить. Вы уверены?', function(btn) {
        if (btn == 'yes') {
          this.doDeleteMessages(messages);
        }
      }, this);
    } else {
      this.doDeleteMessages(messages);
    }
  },
  
  doDeleteMessages: function(messages) {
    this.waiting_el.startWaiting();
    var ids = this.collectMessagesPropertyString(messages, "id");
    Ext.Ajax.request({
      url: this.delete_messages_url,
      params: { ids: ids, copy: messages[0].get("copy?") },
      success: function() {
        this.selectFolder(this.current_folder.id);
        this.updateFolder(this.current_folder);
        this.fire("folderChanged");

        this.updateFolderTree();

      }.bind(this)
    });
  },
  
  restoreSelectedMessages: function() {
    var messages = this.collectSelectedMessages();
    if (messages.length == 0) {
      this.showMessageBox('Отметьте сообщения, которые хотите восстановить.');
      return;
    }
    this.restoreMessages(messages);
  },
  
  restoreMessages: function(messages) {
    this.waiting_el.startWaiting();
    var ids = this.collectMessagesPropertyString(messages, "id");
    var copy = this.collectMessagesPropertyString(messages, "copy?");
    Ext.Ajax.request({
      url: this.restore_messages_url,
      params: { ids: ids, copy: copy },
      success: function() {
        this.selectFolder(this.current_folder.id);
        this.updateFolderTree();
      }.bind(this)
    });
  }
});

Observable.mixin(Mailbox);

