// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
var ttv = {
	// Messages API. We use rails flash. Clear messages
	notice: function(msg) {
		msg = msg || "";
		$('flash_notice').innerHTML = msg;
		$('flash_notice').show();
		return this;
	},
	error: function(msg, append) {
		msg = msg || "";
		if (append)
			$('flash_error').innerHTML += msg;
		else
			$('flash_error').innerHTML = msg;
		$('flash_error').show();
		return this;
	},
	clearMessages: function(msg) {
		$$('.flash').each( function(el) {
			el.innerHTML = "";
			el.hide();
		});
		return this;
	},
	startAjax: function(msg) {
		this.clearMessages();
		this.notice(msg);
		return this;
	},
	endAjax: function() {
		$('spinner').hide();
		return this;
	},
	initialize: function() {
		Event.observe(document, 'click', ttv.inlineClick);
		Ajax.Responders.register({
		  onCreate: function() {
			if (Ajax.activeRequestCount++ == 1) {
				$('spinner').show();
				ttv.suspendEditHover();
			}
		  },
		  onComplete: function(request) {
			Ajax.activeRequestCount = Math.max(Ajax.activeRequestCount--, 0); // never go below 0
			if (Ajax.activeRequestCount == 0)
				$('spinner').hide();
			if ($$('form[inlineEditor="1"]').size() == 0)
				ttv.resumeEditHover();
			var status = request.transport.status;
			if (status == 0 || !(status >= 200 && status < 300))
				ttv.error("Unexpected error has occured. Try again.<br>" + request.transport.statusText);
			// populate messages from JSON headers
			var jsonHeader = request.transport.getResponseHeader('X-JSON');
			if (jsonHeader) {
				try {
					var json = jsonHeader.evalJSON(true);
					ttv.notice(json['notice']);
					ttv.error(json['error']);
				}
				catch (ex) {
					alert(ex.message);
				}
			}
		  },
		  onException: function(request, e) {
			alert(e.message.replace(/</g, "&lt;"));
		    ttv.error(e.message.replace(/</g, "&lt;"), true);
			debugger;
		  }
		});
	},
	pluralize: {
		candidate: 'candidates',
		contest: 'contests',
		district: 'districts',
		election: 'elections',
		party: 'parties',
		precinct: 'precincts',
		question: 'questions',
		user: 'users'
	},
	htmlToElement: function(selector, html) {
		var tmp = document.createElement('div');
		tmp.innerHTML = html;
		var retVal = Element.select(tmp, selector).first();
		if (!retVal)
			this.error("Internal error: htmlToElement fail. Could not create \'" + selector + "\' out of\n" + html );
		if (retVal.parentNode)
			retVal.parentNode.removeChild(retVal);
		return retVal;
	},
	replaceElement: function(oldElement, newElement) {
		oldElement = $(oldElement);
		oldElement.parentNode.insertBefore(newElement, oldElement);
		oldElement.parentNode.removeChild(oldElement);
	},
	suspendEditHover: function() {
		$$('.canEdit').each( function(el) {
			el.removeClassName('canEdit');
			el.addClassName('cannotEdit');
		});
	},
	resumeEditHover: function() {
		$$('.cannotEdit').each( function(el) {
			el.removeClassName('cannotEdit');
			el.addClassName('canEdit');
		});		
	},
	findClickedEditor: function(el) {
		while (el) {
			if (el == document)
				return null;
			if (el.onclick || el.nodeName == 'A') { // do not process handled clicks
				return null;
			}
			if (el.hasClassName('canEdit')) { // search for parent node that is a div
				while (el && el != document && el.nodeName != "DIV")
					el = el.parentNode;
				if (!el || el == document)
					return null;
				else
					return el;
			}
			el = el.parentNode;
		}
		return null;
	},
	inlineClick: function(ev) {
		var el = Event.element(ev);
		// search for an element whose class is "canEdit". Avoid clickable elements
		el = ttv.findClickedEditor(el);
		if (!el)
			return true;
		ev.stop();
		var match = el.id.match(/^(.+)_(\d+)_static$/);
		var url = "/" + ttv.pluralize[match[1]] + "/" + match[2] + "/edit"
		new Ajax.Request(url, {
			parameters: { model_id: el.id},
			method: 'get',
			onSuccess: function(transport, json) {
				if (transport.status == 0)	// Prototype calls onSuccess when my local server is down
					return this.onFailure(transport, json);
				var editor = ttv.htmlToElement('.isEditor', transport.responseText);
				el.parentNode.insertBefore(editor, el);
				el.hide();
				ttv.clearMessages();
			},
			onFailure: function(transport, json) {
				ttv.error("Could not get an editor from the server<br>" + transport.responseText);
			},
			onCreate: function(transport) {
				ttv.notice("Loading editor...");
			}
			});
		return false;
	},
	makeCandidateForm: function(contest_id) {
		var editor = $(contest_id + "_candidates_new");
		if (editor  && editor.moreNewCandidates)
			editor.moreNewCandidates();
		else {
			var url = contest_id.replace(/contest_/, "/contests/") + "/candidates/new";
			new Ajax.Request(url, {asynchronous:true,  evalScripts:true, method:'get'});
		}
	},
	cancelEdit: function(div_id) {
		// remove inline editor, and its containing div, show the real div
		var el = $(div_id);
		el.parentNode.removeChild(el);
		$(div_id.replace(/_edit$/, "_static")).show();
		ttv.resumeEditHover();
	},
	cancelNew: function(div_id) {
		$(div_id).remove();
		ttv.resumeEditHover();
	}
};

Event.observe(window, 'load', ttv.initialize);
