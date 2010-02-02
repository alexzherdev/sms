Ext.BLANK_IMAGE_URL = '/images/gray/s.gif';

var Observable = {
    /*
    * Mixes all neccessary event-related routines into the class given.
    */
    mixin: function(klass) {
        klass.prototype.fire = this.fire;
        klass.prototype.observe = this.observe;
        klass.prototype.stopObserving = this.stopObserving;
        klass.prototype.removeEventHandlers = this.removeEventHandlers;
    },

    /*
    * Fires the event nsamed eventName. Optional data argument is passed to
    * every handler. In case any of handlers return true, no more handlers are
    * invoked during this event.
    */
    fire: function(eventName, data) {
        this.eventMap = this.eventMap || $H({});
        var eventHandlers = this.eventMap.get(eventName) || $A();

        eventHandlers.each(function(entry) {
            if (entry.handler(data)) {
                throw $break;
            }
        });

        this.removeEventHandlers(eventName, function(entry) {
            return (entry.options || {}).once;
        });
    },

    /*
    * Subscribes the handler to the eventName event. If options is a Hash
    * and contains true-evaluted once key, the handler will be removed after the very first
    * invokation.
    */
    observe: function(eventName, handler, options) {
        this.eventMap = this.eventMap || $H({});
        var eventHandlers = this.eventMap.get(eventName) || $A();

        eventHandlers.push({handler: handler, options: options || {}});

        this.eventMap.set(eventName, eventHandlers);
    },

    /*
    * Cancels observing of the event eventName. If no handler is given, all handlers will
    * be removed.
    */
    stopObserving: function(eventName, key) {
        if (key) {
            this.removeEventHandlers(eventName, function(entry) {
                return entry.options.key == key;
            });
        } else {
            this.removeEventHandlers(eventName, function(entry) {
                return true;
            });
        }
    },

    /*
    * Removes event handlers on the event eventName judging by result of lambda.
    */
    removeEventHandlers: function(eventName, lambda) {
        this.eventMap = this.eventMap || $H({});
        var eventHandlers = this.eventMap.get(eventName) || $A();
        var newEventHandlers = $A();

        newEventHandlers = eventHandlers.reject(lambda);

        this.eventMap.set(eventName, newEventHandlers);
    }
}

var GlobalClass = Class.create({});
Observable.mixin(GlobalClass);

var Global = new GlobalClass();

Global.submitForm = function(element) {
    element = $(element);

    while (element != null) {
    	if (element.tagName.toLowerCase() == "form") {
        	break;
    	}
		element = element.parentNode;
 	}
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