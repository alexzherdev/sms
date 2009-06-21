Ext.override(Ext.data.GroupingStore, {
    applySort : function(){
        Ext.data.GroupingStore.superclass.applySort.call(this);
        if (!this.groupOnSort && !this.remoteGroup) {
            var gs = this.getGroupState();
            var si = this.sortInfo || {};

            if (gs && gs != si.field) {
                this.sortData(this.groupField);
            }
        }
    }
}); 
	

var ScheduleItem = Class.create({
	initialize: function(config) {
		this.id = config[0];
		this.i = config[1];
		this.j = config[2];
		this.subjectId = config[3];
		this.roomId = config[4];
		this.groupId = config[5];
	},
	
	markInvalid: function(message) {
		this.view.markInvalid(message);
	},
	
	markValid: function() {
		this.view.markValid();
	}
});


var ScheduleItemView = Class.create({
	initialize: function(config) {
		this.config = config;
		this.item = this.config.item;
		this.config.item.view = this;
		this.schedule = this.config.schedule;
		this.render();
	},
	
	render: function() {
		this.markup = {};
		this.markup.cell = document.createElement("div");
		this.markup.cell.className = "cell";
		if (this.config.lastInDay) {
			this.markup.cell.className += " last-in-day";
		}
		this.markup.cell.id = this.item.i + "_" + this.item.j + "_cell";
		
		this.markup.validationTarget = document.createElement("div");
		this.markup.validationTarget.className = "validationTarget";

		this.markup.cell.appendChild(this.markup.validationTarget);

		this.config.column.appendChild(this.markup.cell);
		this.refresh();
	},
	
	refresh: function() {
		if (this.item.subjectId != 0) {
			if (!this.markup.subjectDiv) {
				this.markup.subjectDiv = document.createElement("div");
				this.markup.subjectDiv.className = "subject";
				this.markup.cell.appendChild(this.markup.subjectDiv);
			}
			this.markup.subjectDiv.innerHTML = this.schedule.model.subjectStore.getById(this.item.subjectId).get("name");
		} else {
			if (this.markup.subjectDiv) {
				this.markup.subjectDiv.innerHTML = "";
			}
		}
		if (this.item.roomId != 0) {
			if (!this.markup.roomDiv) {
				this.markup.roomDiv = document.createElement("div");
				this.markup.roomDiv.className = "room";
				this.markup.cell.appendChild(this.markup.roomDiv);			
			}
			this.markup.roomDiv.innerHTML = this.schedule.model.roomStore.getById(this.item.roomId).get("name");
		} else {
			if (this.markup.roomDiv) {
				this.markup.roomDiv.innerHTML = "";
			}
		}
	},
	
	markValid: function() {
		var cellEl = Ext.get(this.markup.validationTarget);
		this.markup.validationTarget.removeClassName("x-form-invalid");
		cellEl.dom.qtip = "";
        cellEl.dom.qclass = "";
        if (Ext.QuickTips) {    
        	Ext.QuickTips.unregister(cellEl);
        }  
	},
		
	markInvalid: function(message) {
		Global.markInvalid(this.markup.validationTarget, message);
	}
});

var Schedule = Class.create({
	initialize: function(config) {
		this.config = config;
		this.initModel();
		this.config.renderTo = $(this.config.renderTo);
		this.renderMarkup();
		this.initPopup();
	},
	
	initModel: function() {
		this.model = {};
		this.model.roomStore = new Ext.data.SimpleStore({
			fields: ["id", "name"],
			id: 0
		});
		this.model.roomStore.loadData(this.config.rooms);
		
		this.model.yearSubjects = this.config.yearSubjects;
		this.model.groupStore = new Ext.data.SimpleStore({
			fields: ["id", "name", "year"],
			id: 0
		});
		this.model.groupStore.loadData(this.config.groups);
		
		this.model.dayTimeStore = new Ext.data.SimpleStore({
			fields: ["id", "day", "time"],
			id: 0
		});
		this.model.dayTimeStore.loadData(this.config.dayTimes);

		this.model.days = $H();
		this.model.dayTimeStore.each(function(dt) {
			var day = dt.get("day");
			if (!this.model.days.get(day)) {
				this.model.days.set(day, []);
			}
			var old = this.model.days.get(day);
			this.model.days.set(day, old.concat([dt.get("id")]));
		}.bind(this));
		
		this.model.items = [];
		this.model.itemStore = new Ext.data.SimpleStore({
			fields: [{name: "id", mapping: 0}, {name: "item", mapping: 1}],
			id: 0
		});
		
		var itemIndex = [];
		for (var i = 0; i < this.config.items.length; i++) {
			this.model.items[i] = [];
			for (var j = 0; j < this.config.items[i].length; j++) {
				this.model.items[i][j] = new ScheduleItem(this.config.items[i][j]);
				if (this.model.items[i][j].id != null) {
					itemIndex[itemIndex.length] = [this.model.items[i][j].id, this.model.items[i][j]];
				}
			}
		}
		this.model.itemStore.loadData(itemIndex);
		
		var subjects = [];
		this.model.yearSubjects.each(function(el) {
			subjects = subjects.concat(el[1]);
		});
		this.model.subjectStore = new Ext.data.SimpleStore({
			fields: ["id", "name"],
			id: 0
		});
		this.model.subjectStore.loadData(subjects);
		
	},
	
	renderMarkup: function() {
		this.markup = {};
		this.markup.container =  new Element("div", { "class": "schedule-container" });
		
		this.markup.dayTimeTableContainer = new Element("div", { "class": "daytime-table-container" });
		
		var dayTimeTable = new Element("table", { "cellspacing": "0" });
		var tr = new Element("tr");
		var upperLeftTd = new Element("td", { "class": "upper-left-corner" })
		upperLeftTd.innerHTML = "&nbsp;";
		tr.appendChild(upperLeftTd);
		dayTimeTable.appendChild(tr);
		tr = new Element("tr");
		
		this.markup.dayTimesContainer = new Element("td", { "class": "daytimes-container" });
		tr.appendChild(this.markup.dayTimesContainer);
		dayTimeTable.appendChild(tr);
		
		this.markup.dayTimeTableContainer.appendChild(dayTimeTable);
		this.markup.container.appendChild(this.markup.dayTimeTableContainer);
		
		this.markup.scrollableScheduleContainer = new Element("div", { "class": "scrollable-schedule-container" });
		
		this.markup.groupsContainer = new Element("div", { "class": "groups-container" });
		this.markup.groupsContainer.style.width = (this.model.groupStore.getCount() * 41) + "px";
		this.markup.scrollableScheduleContainer.appendChild(this.markup.groupsContainer);
		
		var scheduleTable = new Element("table", { "class": "schedule-table", "cellspacing": "0" });
		scheduleTable.style.width = this.markup.groupsContainer.style.width;
		tr = new Element("tr");
		
		this.markup.mainContainer = new Element("td", { "class": "main-container" });
		Event.observe(this.markup.mainContainer, "click", this.showPopup.bind(this));
		tr.appendChild(this.markup.mainContainer);
		scheduleTable.appendChild(tr);
		this.markup.scrollableScheduleContainer.appendChild(scheduleTable);
		
		this.markup.container.appendChild(this.markup.scrollableScheduleContainer);
		
		this.renderDayTimes();
		this.renderGroups();
		this.renderCells();
			
		$(this.config.renderTo).appendChild(this.markup.container);		
	},
	
	renderGroups: function() {
		var el;
		this.model.groupStore.each(function(g) {
			el = document.createElement("div");
			el.className = "group";
			el.innerHTML = g.get("name");
			this.markup.groupsContainer.appendChild(el);
		}.bind(this));
		if (el) {
			el.addClassName("last");
		}
	},
	
	renderDayTimes: function() {
		this.model.days.each(function(dt) {
			var day = dt[0];
			var times = dt[1];
			var dayDiv = document.createElement("div");
			dayDiv.className = "day";
			var caption = document.createElement("div");
			caption.className = "caption";
			//TODO: shit-shit-shit!
			var img = document.createElement("img");
			img.src = "/images/" + day + "_" + this.config.locale.toLowerCase() + ".png";
			caption.appendChild(img);
			dayDiv.appendChild(caption);
			var timesCount = times.length;
			var i = 0;
			$A(times).each(function(timeId) {				
				var time = this.model.dayTimeStore.getById(timeId);
				var timeDiv = document.createElement("div");
				timeDiv.className = "time" + (i == timesCount - 1 ? " last" : "");
				timeDiv.innerHTML = time.get("time");
				dayDiv.appendChild(timeDiv);
				i++;
			}.bind(this));
			this.markup.dayTimesContainer.appendChild(dayDiv);
		}.bind(this));
	},
	
	renderCells: function() {
		this.itemViews = [];
		var col;
		this.model.groupStore.each(function(g, i) {
			col = document.createElement("div");
			col.className = "group-column" + (i % 2 == 0 ? " even" : "");
			this.model.dayTimeStore.each(function(dt, j) {
				if (!this.itemViews[j]) {
					this.itemViews[j] = [];
				}
				var item = this.model.items[j][i];
				var day = dt.get("day");
				var timesInDay = this.model.days.get(day);
				this.itemViews[j][i] = new ScheduleItemView({ item: item, schedule: this, 
					column: col, lastInDay: (timesInDay[timesInDay.length - 1] == dt.id) });
				item.view = this.itemViews[j][i];
			}.bind(this));
			this.markup.mainContainer.appendChild(col);
		}.bind(this));
		if (col) {
			col.addClassName("last");
		}
	},
	
	scroll: function(delta) {
		this.markup.scrollableScheduleContainer.scrollLeft += delta;
	},
	
	saveItem: function(subjectId, roomId) {
		this.markup.scrollableScheduleContainer.startWaiting("bigWaiting");
		
		this.config.saveCallback(this.editItem.id, this.editItem.i, this.editItem.j, subjectId, roomId, 
			function(result) {
				this.model.itemStore.each(function(item) {
					item.get("item").markValid();					
				}.bind(this));
				//eval(result);
				this.editItem.subjectId = subjectId;
				this.editItem.roomId = roomId;
				this.editItem.view.refresh();
				this.markup.scrollableScheduleContainer.stopWaiting();
			}.bind(this));		
	},
	
	updateEditItemId: function(newId) {
		this.editItem.id = newId;
		this.model.itemStore.add(new Ext.data.Record({ id: newId, item: this.editItem }, newId));
	},
	
	deleteEditItem: function() {
		var oldRec = this.model.itemStore.getById(this.editItem.id);
		this.model.itemStore.remove(oldRec);
		
		this.editItem.id = null;
	},
	
	initPopup: function() {
		this.popup = new Ext.Window({
		    el: 'popup',
		    layout: 'fit',
		    width: 200,
		    height: 150,
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
		      { text: "Save",
		        handler: function() {
		        	var subjects = Ext.getCmp("popup_subjects");
		        	var rooms = Ext.getCmp("popup_rooms");	
		          	this.popup.hide();	        	
		          	this.saveItem(subjects.getValue(), rooms.getValue());
		        }.bind(this)},
		      { text: "Cancel",
		        handler: function() {
		        	this.popup.hide();  
		        }.bind(this)
		      }]
	  	});
	  	this.popup.on("beforeshow", this.preparePopup.bind(this));
	},
	
	itemFromCell: function(cell) {
		var i = cell.id.substring(0, cell.id.indexOf("_"));
		var j = cell.id.substring(cell.id.indexOf("_") + 1, cell.id.lastIndexOf("_"));
		return this.model.items[parseInt(i)][parseInt(j)];
	},
	
	groupRooms: function(store, currentItem) {
		store.each(function(room) {
			room.set("occupied", "false");
			var roomName = this.model.roomStore.getById(room.get("id")).get("name");
			room.set("name", roomName);
		}.bind(this));
		var occupiedIds = [];
		var occupiedBy = [];
		$A(this.model.items[currentItem.i] || []).each(function(item) {
			if (item.roomId != 0) {
				occupiedIds[occupiedIds.length] = item.roomId;
				occupiedBy[occupiedBy.length] = this.model.groupStore.getById(item.groupId).get("name");
			}
		}.bind(this));
		occupiedIds = $A(occupiedIds).uniq();
		occupiedIds.each(function(id, index) {
			var comboRoomRecord = store.getById(id);
			comboRoomRecord.set("occupied", "true");
			var roomName = this.model.roomStore.getById(id).get("name");
			comboRoomRecord.set("name", roomName + " (" + occupiedBy[index] + ")");
		}.bind(this));
		store.commitChanges();
		store.groupBy("occupied", true);
	},
	
	preparePopup: function() {
		//TODO: tight coupling
		var subjects = Ext.getCmp("popup_subjects");
		var group = this.model.groupStore.getById(this.editItem.groupId);
		subjects.store.loadData(this.model.yearSubjects.get(group.get("year")));
		if (this.editItem.subjectId) {
			var subject = this.model.subjectStore.getById(this.editItem.subjectId);
			subjects.setValue(subject.get("id"));
		} else {
			subjects.setValue(0);
		}
		var rooms = Ext.getCmp("popup_rooms");
		this.groupRooms(rooms.store, this.editItem);
		if (this.editItem.roomId) {
			var room = this.model.roomStore.getById(this.editItem.roomId);
			rooms.setValue(room.get("id"));
		} else {
			rooms.setValue(0);
		}
	},
	
	showPopup: function(e) {
		var el = e.target;
		while (!el.className.toLowerCase().include("cell")) {
			el = el.parentNode;
		}
		this.editItem = this.itemFromCell(el);
		var cellEl = Ext.get(el);
		this.popup.setPagePosition(cellEl.getRight() + 1, cellEl.getBottom() + 1);
		this.popup.show();
	},
	
	markValid: function(itemId) {
		var scheduleItem = this.model.itemStore.getById(itemId);
		scheduleItem.get("item").markValid();
	},
	
	markInvalid: function(itemId, message) {
		var scheduleItem = this.model.itemStore.getById(itemId);
		scheduleItem.get("item").markInvalid(message);
	}
});