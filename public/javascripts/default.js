Ext.BLANK_IMAGE_URL = '/images/gray/s.gif';

var Global = {};

Global.submitForm = function(element, event) {
    element = $(element);

    while (element != null) {
    	if (element.tagName.toLowerCase() == "form") {
        	break;
    	}
		element = element.parentNode;
 	}
 	var hiddenField = new Element("input", { type: "hidden", name: "_eventId" });
 	hiddenField.value = event; 
 	element.appendChild(hiddenField);
	if (element.onsubmit) {
		element.onsubmit();
	} else {
		element.submit();
	}
} 

Global.messageBox = function(content, autoHide) {
	if (autoHide == undefined) {
		autoHide = true;
	}
	var msgCt = Ext.get("message_container");
    msgCt.alignTo(document, 't-t'); 
    var m = Ext.get("message_content");
    m.update(content);
	msgCt.show();
    msgCt = msgCt.slideIn('t', {duration: 1});
    if (autoHide) {
    	//msgCt.pause(3).slideOut("t", {remove:false}); 
	}
}

Global.closeMessageBox = function() {
	var msgCt = Ext.get("message_container");
	msgCt.ghost("t", {remove:false});
}

Global.markInvalid = function(element, message) {
	element = Ext.get(element);
	element.addClass("x-form-invalid");
    if (Ext.QuickTips) {  
    	element.dom.qtip = element.dom.qtip ? (element.dom.qtip + "<br/>") : "";  
    	element.dom.qtip += message;
    	Ext.QuickTips.register({ target: element, text: element.dom.qtip, cls: "x-form-invalid-tip" });
    }  
}
	
Ext.onReady(function() {
	Ext.QuickTips.init(false);
});