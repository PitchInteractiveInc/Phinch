

	//via http://stackoverflow.com/questions/1787322/htmlspecialchars-equivalent-in-javascript
	function escapeHtml(unsafe) {
	  return unsafe
		  .replace(/&/g, "&amp;")
		  .replace(/</g, "&lt;")
		  .replace(/>/g, "&gt;")
		  .replace(/"/g, "&quot;")
		  .replace(/'/g, "&#039;");
	}
	
	//via https://github.com/kvz/phpjs/blob/master/functions/strings/get_html_translation_table.js
	function get_html_translation_table (table, quote_style) {
	  // http://kevin.vanzonneveld.net
	  // + original by: Philip Peterson
	  // + revised by: Kevin van Zonneveld (http://kevin.vanzonneveld.net)
	  // + bugfixed by: noname
	  // + bugfixed by: Alex
	  // + bugfixed by: Marco
	  // + bugfixed by: madipta
	  // + improved by: KELAN
	  // + improved by: Brett Zamir (http://brett-zamir.me)
	  // + bugfixed by: Brett Zamir (http://brett-zamir.me)
	  // + input by: Frank Forte
	  // + bugfixed by: T.Wild
	  // + input by: Ratheous
	  // % note: It has been decided that we're not going to add global
	  // % note: dependencies to php.js, meaning the constants are not
	  // % note: real constants, but strings instead. Integers are also supported if someone
	  // % note: chooses to create the constants themselves.
	  // * example 1: get_html_translation_table('HTML_SPECIALCHARS');
	  // * returns 1: {'"': '&quot;', '&': '&amp;', '<': '&lt;', '>': '&gt;'}
	  var entities = {},
		hash_map = {},
		decimal;
	  var constMappingTable = {},
		constMappingQuoteStyle = {};
	  var useTable = {},
		useQuoteStyle = {};

	  // Translate arguments
	  constMappingTable[0] = 'HTML_SPECIALCHARS';
	  constMappingTable[1] = 'HTML_ENTITIES';
	  constMappingQuoteStyle[0] = 'ENT_NOQUOTES';
	  constMappingQuoteStyle[2] = 'ENT_COMPAT';
	  constMappingQuoteStyle[3] = 'ENT_QUOTES';

	  useTable = !isNaN(table) ? constMappingTable[table] : table ? table.toUpperCase() : 'HTML_SPECIALCHARS';
	  useQuoteStyle = !isNaN(quote_style) ? constMappingQuoteStyle[quote_style] : quote_style ? quote_style.toUpperCase() : 'ENT_COMPAT';

	  if (useTable !== 'HTML_SPECIALCHARS' && useTable !== 'HTML_ENTITIES') {
		throw new Error("Table: " + useTable + ' not supported');
		// return false;
	  }

	  entities['38'] = '&amp;';
	  if (useTable === 'HTML_ENTITIES') {
		entities['160'] = '&nbsp;';
		entities['161'] = '&iexcl;';
		entities['162'] = '&cent;';
		entities['163'] = '&pound;';
		entities['164'] = '&curren;';
		entities['165'] = '&yen;';
		entities['166'] = '&brvbar;';
		entities['167'] = '&sect;';
		entities['168'] = '&uml;';
		entities['169'] = '&copy;';
		entities['170'] = '&ordf;';
		entities['171'] = '&laquo;';
		entities['172'] = '&not;';
		entities['173'] = '&shy;';
		entities['174'] = '&reg;';
		entities['175'] = '&macr;';
		entities['176'] = '&deg;';
		entities['177'] = '&plusmn;';
		entities['178'] = '&sup2;';
		entities['179'] = '&sup3;';
		entities['180'] = '&acute;';
		entities['181'] = '&micro;';
		entities['182'] = '&para;';
		entities['183'] = '&middot;';
		entities['184'] = '&cedil;';
		entities['185'] = '&sup1;';
		entities['186'] = '&ordm;';
		entities['187'] = '&raquo;';
		entities['188'] = '&frac14;';
		entities['189'] = '&frac12;';
		entities['190'] = '&frac34;';
		entities['191'] = '&iquest;';
		entities['192'] = '&Agrave;';
		entities['193'] = '&Aacute;';
		entities['194'] = '&Acirc;';
		entities['195'] = '&Atilde;';
		entities['196'] = '&Auml;';
		entities['197'] = '&Aring;';
		entities['198'] = '&AElig;';
		entities['199'] = '&Ccedil;';
		entities['200'] = '&Egrave;';
		entities['201'] = '&Eacute;';
		entities['202'] = '&Ecirc;';
		entities['203'] = '&Euml;';
		entities['204'] = '&Igrave;';
		entities['205'] = '&Iacute;';
		entities['206'] = '&Icirc;';
		entities['207'] = '&Iuml;';
		entities['208'] = '&ETH;';
		entities['209'] = '&Ntilde;';
		entities['210'] = '&Ograve;';
		entities['211'] = '&Oacute;';
		entities['212'] = '&Ocirc;';
		entities['213'] = '&Otilde;';
		entities['214'] = '&Ouml;';
		entities['215'] = '&times;';
		entities['216'] = '&Oslash;';
		entities['217'] = '&Ugrave;';
		entities['218'] = '&Uacute;';
		entities['219'] = '&Ucirc;';
		entities['220'] = '&Uuml;';
		entities['221'] = '&Yacute;';
		entities['222'] = '&THORN;';
		entities['223'] = '&szlig;';
		entities['224'] = '&agrave;';
		entities['225'] = '&aacute;';
		entities['226'] = '&acirc;';
		entities['227'] = '&atilde;';
		entities['228'] = '&auml;';
		entities['229'] = '&aring;';
		entities['230'] = '&aelig;';
		entities['231'] = '&ccedil;';
		entities['232'] = '&egrave;';
		entities['233'] = '&eacute;';
		entities['234'] = '&ecirc;';
		entities['235'] = '&euml;';
		entities['236'] = '&igrave;';
		entities['237'] = '&iacute;';
		entities['238'] = '&icirc;';
		entities['239'] = '&iuml;';
		entities['240'] = '&eth;';
		entities['241'] = '&ntilde;';
		entities['242'] = '&ograve;';
		entities['243'] = '&oacute;';
		entities['244'] = '&ocirc;';
		entities['245'] = '&otilde;';
		entities['246'] = '&ouml;';
		entities['247'] = '&divide;';
		entities['248'] = '&oslash;';
		entities['249'] = '&ugrave;';
		entities['250'] = '&uacute;';
		entities['251'] = '&ucirc;';
		entities['252'] = '&uuml;';
		entities['253'] = '&yacute;';
		entities['254'] = '&thorn;';
		entities['255'] = '&yuml;';
	  }

	  if (useQuoteStyle !== 'ENT_NOQUOTES') {
		entities['34'] = '&quot;';
	  }
	  if (useQuoteStyle === 'ENT_QUOTES') {
		entities['39'] = '&#39;';
	  }
	  entities['60'] = '&lt;';
	  entities['62'] = '&gt;';


	  // ascii decimals to real symbols
	  for (decimal in entities) {
		if (entities.hasOwnProperty(decimal)) {
		  hash_map[String.fromCharCode(decimal)] = entities[decimal];
		}
	  }

	  return hash_map;
	}	
	
	//via https://github.com/kvz/phpjs/blob/master/functions/strings/html_entity_decode.js
	function html_entity_decode (string, quote_style) {
	  // http://kevin.vanzonneveld.net
	  // +   original by: john (http://www.jd-tech.net)
	  // +      input by: ger
	  // +   improved by: Kevin van Zonneveld (http://kevin.vanzonneveld.net)
	  // +    revised by: Kevin van Zonneveld (http://kevin.vanzonneveld.net)
	  // +   bugfixed by: Onno Marsman
	  // +   improved by: marc andreu
	  // +    revised by: Kevin van Zonneveld (http://kevin.vanzonneveld.net)
	  // +      input by: Ratheous
	  // +   bugfixed by: Brett Zamir (http://brett-zamir.me)
	  // +      input by: Nick Kolosov (http://sammy.ru)
	  // +   bugfixed by: Fox
	  // -    depends on: get_html_translation_table
	  // *     example 1: html_entity_decode('Kevin &amp; van Zonneveld');
	  // *     returns 1: 'Kevin & van Zonneveld'
	  // *     example 2: html_entity_decode('&amp;lt;');
	  // *     returns 2: '&lt;'
	  var hash_map = {},
		symbol = '',
		tmp_str = '',
		entity = '';
	  tmp_str = string.toString();

	  if (false === (hash_map = get_html_translation_table('HTML_ENTITIES', quote_style))) {
		return false;
	  }

	  // fix &amp; problem
	  // http://phpjs.org/functions/get_html_translation_table:416#comment_97660
	  delete(hash_map['&']);
	  hash_map['&'] = '&amp;';

	  for (symbol in hash_map) {
		entity = hash_map[symbol];
		tmp_str = tmp_str.split(entity).join(symbol);
	  }
	  tmp_str = tmp_str.split('&#039;').join("'");

	  return tmp_str;
	}
	//no longer via http://stackoverflow.com/questions/2440359/attaching-div-to-a-specific-element-for-showing-with-javascript

function allContentModal(){
	//http://stackoverflow.com/questions/14242227/bootstrap-modal-body-max-height-100
	//Need to fix this to only trigger on the specific model, but not sure how yet. 
	jQuery(".toplevel_page_pf-menu").on('shown', '.pfmodal.modal', function(evt){
		//alert('Modal Triggered.');
		document.body.style.overflow = 'hidden';
		var element = jQuery(this);		
		var modalID = element.attr('id');
		//alert(modalID);
		//showDiv(jQuery('#entries'), jQuery('#'+modalID));		
		var itemID = element.attr('pf-item-id');
		var postID = element.attr('pf-post-id');	
		var tabindex = element.parent().attr('tabindex');
		modalNavigator(tabindex);			
		//At this point it should have grabbed the direct feeditem hashed ID. That allows us to do things specifically to that item past this point.
		//BUG: Escaping everything incorrectly. <-one time issue?
		var content = jQuery("#"+itemID+" #modal-body-"+itemID).html();
		var url = jQuery("#"+itemID+" #item_link_"+itemID).val();
		var authorship = jQuery("#"+itemID+" #item_author_"+itemID).val();
		var read_status = element.attr('pf-readability-status');
		//I suppose I should nonce here right? 
		var theNonce		= jQuery.trim(jQuery('#pf_nomination_nonce').val());
		
		jQuery.post(ajaxurl, {
				action: 'ajax_get_comments',
				//We'll feed it the ID so it can cache in a transient with the ID and find to retrieve later.			
				id_for_comments: postID,
			}, 
			function(comment_response) {
				jQuery("#"+itemID+" #modal-"+itemID+" .modal-comments").html(comment_response);
			});		
		
		if (read_status != 1){
		//At some point a waiting graphic should go here. 
		jQuery("#"+itemID+" #modal-"+itemID+" #modal-body-"+itemID).html('Attempting to retrieve full article.');
			jQuery.post(ajaxurl, {
				action: 'make_it_readable',
				//We'll feed it the ID so it can cache in a transient with the ID and find to retrieve later.			
				read_item_id: itemID,
				url: url,
				content: escape(content),
				post_id: postID,
				//We need to pull the source data to determine if it is aggregation as well. 
				authorship: authorship,
				pf_nomination_nonce: theNonce,
				force: 'noforce'
			}, 
			function(response) {
				var read_content = html_entity_decode(jQuery(response).find("response_data").text());
				var status = jQuery(response).find("readable_status").text();
				
				//alert(read_content);
				// Don't bother doing anything if we don't need it.
				if (status != 'readable') {
					if (status == 'secured') {
						alert('The content cannot be retrieved. The post may be on a secure page or it may have been removed.');
						jQuery("#"+itemID+" #modal-"+itemID+" #modal-body-"+itemID).html(read_content);
						var safeResponse = escapeHtml(read_content);
						jQuery("#item_content_"+itemID).attr('value', safeResponse);
						element.attr('pf-readability-status', 1);
					} else if (status == 'already_readable') {
						jQuery("#"+itemID+" #modal-body-"+itemID).html(unescape(content));
						element.attr('pf-readability-status', 1);
					} else {
						jQuery("#"+itemID+" #modal-"+itemID+" #modal-body-"+itemID).html(read_content);
						var safeResponse = escapeHtml(read_content);
						jQuery("#item_content_"+itemID).attr('value', safeResponse);
					}
				} else {
						jQuery("#"+itemID+" #modal-"+itemID+" #modal-body-"+itemID).html(read_content);
						var safeResponse = escapeHtml(read_content);
						jQuery("#item_content_"+itemID).attr('value', safeResponse);
						element.attr('pf-readability-status', 1);
				}
			});
		}
	});
}

function modalReadReset(){	
	jQuery('.pf_container').on('click', ".modal-readability-reset", function(evt){
		evt.preventDefault();
		var element = jQuery(this);		
		var modalID = element.attr('pf-modal-id');
		var itemID = element.attr('pf-item-id');
		var postID = element.attr('pf-post-id');		
		//At this point it should have grabbed the direct feeditem hashed ID. That allows us to do things specifically to that item past this point.
		//BUG: Escaping everything incorrectly. <-one time issue?
		var content = jQuery("#"+itemID+" #modal-body-"+itemID).html();
		var url = jQuery("#"+itemID+" #item_link_"+itemID).val();
		var authorship = jQuery("#"+itemID+" #item_author_"+itemID).val();
		//I suppose I should nonce here right? 
		var theNonce		= jQuery.trim(jQuery('#pf_nomination_nonce').val());	
		//At some point a waiting graphic should go here. 
		//alert(content);
		jQuery("#"+itemID+" #modal-"+itemID+" #modal-body-"+itemID).html('Attempting to retrieve full article.');
			jQuery.post(ajaxurl, {
				action: 'make_it_readable',
				//We'll feed it the ID so it can cache in a transient with the ID and find to retrieve later.			
				read_item_id: itemID,
				url: url,
				content: escape(content),
				post_id: postID,
				//We need to pull the source data to determine if it is aggregation as well. 
				authorship: authorship,
				pf_nomination_nonce: theNonce,
				force: 'force'
				
			}, 
			function(response) {
				var check = jQuery(response).find("response_data").text();
				var read_content = html_entity_decode(jQuery(response).find("response_data").text());
				var status = jQuery(response).find("readable_status").text();
				
				//alert(read_content);
				// Don't bother doing anything if we don't need it.
				if (status != 'readable') {
					if (status == 'secured') {
						alert('The content cannot be retrieved. The post may be on a secure page or it may have been removed.');
						jQuery("#"+itemID+" #modal-"+itemID+" #modal-body-"+itemID).html(read_content);
						var safeResponse = escapeHtml(read_content);
						jQuery("#item_content_"+itemID).attr('value', safeResponse);
						jQuery(modalID).attr('pf-readability-status', 1);
					} else if (status == 'already_readable') {
						jQuery("#"+itemID+" #modal-"+itemID+" #modal-body-"+itemID).html(unescape(content));
						jQuery(modalID).attr('pf-readability-status', 1);
					} else {
						jQuery("#"+itemID+" #modal-"+itemID+" #modal-body-"+itemID).html(read_content);
						var safeResponse = escapeHtml(read_content);
						jQuery("#item_content_"+itemID).attr('value', safeResponse);
					}
				} else {
						//alert('readable')
						jQuery("#"+itemID+" #modal-"+itemID+" #modal-body-"+itemID).html(read_content);
						var safeResponse = escapeHtml(read_content);
						jQuery("#item_content_"+itemID).attr('value', safeResponse);
						jQuery(modalID).attr('pf-readability-status', 1);
				}
			});
			
	
	});
}	
jQuery(window).load(function() {
allContentModal(); 
modalReadReset();

});