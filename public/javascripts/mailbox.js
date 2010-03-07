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
    this.message_store = config.message_store;
    this.recipient_store = config.recipient_store;
    this.message_tpl = config.message_tpl;
    this.message_view_tpl = config.message_view_tpl;
    this.new_message_url = config.new_message_url;
    this.show_message_url = config.show_message_url; 
    this.folders_url = config.folders_url;
    
    this.initFolderTree();
    this.initFolderView();
    this.initFolderViewPanel();

    this.initMessageViewPanel();
    this.initNewMessagePanel();
    
    this.initContentPanel();
    this.initContainerPanel();
    
    this.initRecipientGrid();
    this.initRecipientsPopup();
    
    this.waiting_el = $('mailbox_content_panel');
  },
  
  initFolderTree: function() {
    this.folder_tree = new Ext.tree.TreePanel({
      mailbox: this,
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
              this.mailbox.selectFolder(this.mailbox.config.initial_folder_id);
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
          this.showFolder(node.attributes.id);
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
        id: 'mailbox_content_panel'
      },
      width: 608,
      height: 500,
      items: [
        this.folder_view_panel,
        this.message_view_panel,
        this.new_message_panel
      ]
    });   
  },
  
  initMessageViewPanel: function() {
    this.message_view_panel = new Ext.Panel({
      width: 608,
      height: 500,
      id: 'message_view_panel',
      tbar: [
      {
        text: "Вернуться в папку",
        handler: function() {
          this.selectInbox();
        }.bind(this)
      },
      '-',
      {
        text: "Ответить",
        handler: function() {
          this.reply();
        }.bind(this)
      },
      {
        text: "Ответить всем",
        handler: function() {
          this.reply();
        }.bind(this)
      },
      {
        text: "Переслать",
        handler: function() {
          this.forward();
        }.bind(this)
      },
      '-',
      {
        text: "Удалить",
        iconCls: 'x-btn-text-icon cross',
        handler: function() {
          this.forward();
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
        click: function(view, index) {
          var record = this.message_store.getAt(index);
          Ext.Ajax.request({
            url: this.show_message_url + "/" + record.get("id"),
            method: 'GET',
            scripts: true,
            params: { copy: record.get("is_copy") },
            success: function() {
              this.folder_tree.getLoader().load(this.folder_tree.getRootNode(), function() {
                this.findFolderNodeById(record.get("folder_id")).select();
              }.bind(this));              
            }.bind(this)
          });
        }.bind(this)
      }
    });
  },
  
  initFolderViewPanel: function() {
    var header_panel = new Ext.Panel({
      contentEl: 'folder_header',
      border: false,
      bodyStyle: 'border-bottom: 1px solid #999',
      height: 30
    });
    
    this.folder_view_panel = new Ext.Panel({
      layout: {
  		  type: 'vbox',
  		  align: 'stretch' 
  		},
  		id: 'folder_view_panel',
      width: 608,
      height: 500,
      tbar: [{
        iconCls: 'x-btn-text-icon cross',
        text: 'Удалить',
        handler: function() {
          Ext.Ajax.request({
            method: 'DELETE', 
            url: '#{messages_path}/' + Global.subject_grid.getSelectionModel().getSelected().get('id')
          })
        }
      },
      ],
      items: [
        header_panel,
        this.folder_view
      ]
    });
  },
  
  initContainerPanel: function() {
    this.container_panel = new Ext.Panel({
      title: 'Сообщения',
      layout: {
        type: 'hbox',
        align: 'stretch' 
      },
      width: 760,
      height: 500,
      tbar: [{
        text: "Новое сообщение",
        handler: function() {
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
  
  findFolderById: function(id) {
    return this.folders.detect(function(folder) {
      return folder.id == id;
    });
  },
  
  showFolder: function(id) {
    var folder = this.findFolderById(id);
    if (folder) {
      this.waiting_el.startWaiting();
      Ext.Ajax.request({
        url: folder.url,
        method: 'POST',
        scripts: true,
        success: function() {
          this.waiting_el.stopWaiting();
        }.bind(this)
      });
    } 
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
  
  selectInbox: function() {
    this.selectFolder(this.config.inbox_id);
  },
  
  updateFolder: function(folder) {
    var f = this.findFolderById(folder.id);
    f.unread_count = folder.unread_count;
  },
  
  viewFolderMessages: function(messages) {
    this.content_panel.getLayout().setActiveItem('folder_view_panel');
    this.loadMessages(messages);
  },
  
  loadMessages: function(messages) {
    this.message_store.loadData(messages);
  },
  
  viewMessage: function(message) {
    this.current_message = message;
    this.content_panel.getLayout().setActiveItem('message_view_panel');
    this.message_view_panel.update(this.current_message);
  },
  
  showRecipientsPopup: function() {
    this.recipients_popup.show();
  },  
    
  setRecipients: function(selections) {
    if ($('hidden_to')) {
      var hidden = $('hidden_to');
      hidden.value = "";
      var field = Ext.getCmp("recipients");
      field.setValue("");
      var field_value = '';
      selections.each(function(sel) {
        hidden.value += sel.get("id") + ",";
        field_value += sel.get("full_name_abbr") + ", ";
      });
      hidden.value = hidden.value.substring(0, hidden.value.length - 1);
      field_value = field_value.substring(0, field_value.length - 2);
      field.setValue(field_value);
    }
  },
  
  reply: function() {

  },
  
  forward: function() {
    
  }
   
});

Observable.mixin(Mailbox);

