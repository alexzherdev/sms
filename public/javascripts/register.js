var Register = Class.create({
	EMPTY_MARK: -1,
	
	initialize: function(config) {
		this.config = config;
		this.editable = !this.config.readonly;
		this.markBox = this.config.markBox;
		this.initModel();
		this.config.renderTo = $(this.config.renderTo);
		this.renderMarkup();
	},
	
	initModel: function() {
		this.model = {};
		
		this.model.markStore = new Ext.data.SimpleStore({
			fields: ["id", "text"],
			id: 0
		});
		
		this.model.marks = this.config.marks;
		//this.model.markStore.loadData(this.config.marks);
				
		this.model.dateStore = new Ext.data.SimpleStore({
			fields: ["id", "text"],
			id: 0
		});
		this.model.dateStore.loadData(this.config.dates);
		
		this.model.studentStore = new Ext.data.SimpleStore({
			fields: ["id", "name"],
			id: 0
		});
		this.model.studentStore.loadData(this.config.students);
		
	},
	
	renderMarkup: function() {
		this.markup = {};
		this.markup.container =  new Element("div", { "class": "register-container" });
		
		this.markup.dayTimeTableContainer = new Element("div", { "class": "student-table-container" });
		
		var dayTimeTable = new Element("table", { "cellspacing": "0" });
		var tr = new Element("tr");
		var upperLeftTd = new Element("td", { "class": "upper-left-corner" })
		upperLeftTd.innerHTML = "&nbsp;";
		tr.appendChild(upperLeftTd);
		dayTimeTable.appendChild(tr);
		tr = new Element("tr");
		
		this.markup.studentsContainer = new Element("td", { "class": "students-container" });
		tr.appendChild(this.markup.studentsContainer);
		dayTimeTable.appendChild(tr);
		
		this.markup.dayTimeTableContainer.appendChild(dayTimeTable);
		this.markup.container.appendChild(this.markup.dayTimeTableContainer);
		
		this.markup.scrollableRegisterContainer = new Element("div", { "class": "scrollable-register-container" });
		
		this.markup.datesContainer = new Element("div", { "class": "dates-container" });
		this.markup.scrollableRegisterContainer.appendChild(this.markup.datesContainer);
		
		var registerTable = new Element("table", { "class": "register-table", "cellspacing": "0" });
		registerTable.style.width = (this.model.dateStore.getCount() * 41) + "px";
		tr = new Element("tr");
		
		this.markup.mainContainer = new Element("td", { "class": "main-container" });
		this.markup.mainContainer.style.width = registerTable.style.width;
		this.markup.datesContainer.style.width = this.markup.mainContainer.style.width;
		if (this.editable) {
			this.setListeners();
		}
		tr.appendChild(this.markup.mainContainer);
		registerTable.appendChild(tr);
		this.markup.scrollableRegisterContainer.appendChild(registerTable);
		
		this.markup.container.appendChild(this.markup.scrollableRegisterContainer);
		
		this.renderStudents();
		this.renderDates();
		this.renderCells();
			
		$(this.config.renderTo).appendChild(this.markup.container);		
	},
	
	renderDates: function() {
		var el;
		this.model.dateStore.each(function(g) {
			el = document.createElement("div");
			el.className = "date";
			el.innerHTML = g.get("text");
			this.markup.datesContainer.appendChild(el);
		}.bind(this));
		if (el) {
			el.addClassName("last");
		}
	},
	
	renderStudents: function() {
		this.model.studentStore.each(function(s) {
			var studentDiv = document.createElement("div");
			studentDiv.className = "student";
			studentDiv.innerHTML = s.get("name");
			
			this.markup.studentsContainer.appendChild(studentDiv);
		}.bind(this));
	},
	
	renderCells: function() {
		this.model.dateStore.each(function(d, i) {
			var col;
			col = document.createElement("div");
			col.className = "date-column" + (i % 2 == 0 ? " even" : "");
			this.model.studentStore.each(function(s, j) {
				var mark = this.model.marks[j][i];
				var cell = document.createElement("div");
				cell.className = "cell";		
				cell.id = mark.i + "_" + mark.j + "_cell";		
				if (mark.mark != this.EMPTY_MARK) {
					this.renderMark(cell, mark.mark);
				}
				col.appendChild(cell);
			}.bind(this));
			if (col) {
				col.addClassName("last");
			}
			this.markup.mainContainer.appendChild(col);
		}.bind(this));
	},
	
	renderMark: function(cell, mark) {
		var markDiv = document.createElement("div");
		markDiv.className = "mark";
		markDiv.innerHTML = mark;
		cell.appendChild(markDiv);
	},
	
	moveMarkBox: function(e) {
		var target = $(e.target);
		if (!target.hasClassName("cell")) {
			target = target.up('.cell');
		}
		if (target == null) {
			return;
		}
		if (target.hasClassName("cell")) {
			if (target.down(".mark") != null) {
				this.blurMarkBox(null);
				return;
			}
			this.editCell = target;
			var markBoxContainer = $("markBoxContainer");
			markBoxContainer.className = "";
			if (markBoxContainer.parentNode != target) {
				target.appendChild(markBoxContainer);
			}
		}
	},
	
	blurMarkBox: function(e) {
		if (e != null) {
			if (e.explicitOriginalTarget && e.explicitOriginalTarget.className
				&& e.explicitOriginalTarget.className.match("trigger") != null
				|| e.explicitOriginalTarget && e.explicitOriginalTarget.className.match("text") != null
				&& e.target.className.match("trigger") != null) {
				return;
			}
		}
		var markBoxContainer = $("markBoxContainer");
		markBoxContainer.className = "x-hide-display";
		document.body.appendChild(markBoxContainer);
		this.editCell = null;
	},
		
	clearListeners: function() {
		Event.stopObserving(this.markup.mainContainer, "mouseover");
		Event.stopObserving(this.markup.mainContainer, "mouseout");
	},
	
	setListeners: function() {
		Event.observe(this.markup.mainContainer, "mouseover", this.moveMarkBox.bind(this));
		Event.observe(this.markup.mainContainer, "mouseout", this.blurMarkBox.bind(this));
	},
	
	chooseMark: function(cell, mark) {
		var i = cell.id.substring(0, cell.id.indexOf("_"));
		var j = cell.id.substring(cell.id.indexOf("_") + 1, cell.id.lastIndexOf("_"));
		this.blurMarkBox(null);
		this.markup.scrollableRegisterContainer.startWaiting("bigWaiting");
		
		TeacherRegisterAction.putMark(i, j, mark, Global.flowExecutionKey, function(result) {
			eval(result);
			this.markup.scrollableRegisterContainer.stopWaiting();
		}.bind(this));
	},
	
	putMark: function(i, j, mark) {
		this.model.marks[i][j] = mark;
		var cell = $(i + "_" + j + "_" + "cell");
		this.renderMark(cell, mark);
		this.markBox.setValue(null);
	}	
});