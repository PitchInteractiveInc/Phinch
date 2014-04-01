/**
 * Display transform for pf
**/


	//via http://stackoverflow.com/questions/1662308/javascript-substr-limit-by-word-not-char
	function trim_words(theString, numWords) {
		expString = theString.split(/\s+/,numWords);
		theNewString=expString.join(" ");
		return theNewString;
	}	


	function modalNavigator(tabindex){
		tabindex = parseInt(tabindex);
		var currentObj = jQuery('article[tabindex="'+tabindex+'"]');
		//alert(tabindex);
		var currentID = jQuery(currentObj).attr('id');
		var prevTab = tabindex-1;
		var nextTab = tabindex+1;
		var prevObj = jQuery('article[tabindex="'+prevTab+'"]');
		var nextObj = jQuery('article[tabindex="'+nextTab+'"]');
		var modalID = currentObj.children('header').children('h1').children('a').attr('href');

		//First lets assemble variables for the previous group.
		if (jQuery(prevObj).is('*')){
			var prevItemID = jQuery(prevObj).children('header').children('h1').children('a').attr('href');
			var prevTitle = jQuery(prevObj).children('header').children('h1').text();
			var prevSource = jQuery(prevObj).children('header').children('p.source_title').text();
			var prevAuthor = jQuery(prevObj).children('header').children('div.feed-item-info-box').children('span.item_authors').text();
			var prevExcerpt = jQuery(prevObj).children('div.content').children('div.item_excerpt').text();
			prevExcerpt = trim_words(prevExcerpt, 20);
			var prevDate = jQuery(prevObj).children('footer').children('p.pubdate').text();
		
			var prevHTML = '<h5 class="prev_title">Previously: <a href="'+prevItemID+'" role="button" class="modal-nav" data-dismiss="modal" data-toggle="modal" data-backdrop="false">'+prevTitle+'</a></h5>';
			prevHTML += '<p class="prev_source_title">'+prevSource+'</p>';
			prevHTML += '<p class="prev_author">'+prevAuthor+'</p>';
			prevHTML += '<p class="prev_excerpt">'+prevExcerpt+'</p>';
			prevHTML += '<p class="prev_date">'+prevDate+'</p>';
			//alert(modalID);
			jQuery(modalID+' div.modal-body-row div.modal-sidebar div.goPrev').html(prevHTML);	
			jQuery(modalID+' div.mobile-goPrev').html('<i class="icon-arrow-left"></i> <a href="'+prevItemID+'" role="button" data-dismiss="modal" class="mobile-modal-navlink modal-nav" data-toggle="modal" data-backdrop="false">'+prevTitle+'</a> ');	
	
			
		}
		//Next lets assemble variables for the next group.
		if (jQuery(nextObj).is('*')){
			var nextItemID = jQuery(nextObj).children('header').children('h1').children('a').attr('href');
			var nextTitle = jQuery(nextObj).children('header').children('h1').text();
			var nextSource = jQuery(nextObj).children('header').children('p.source_title').text();
			var nextAuthor = jQuery(nextObj).children('header').children('div.feed-item-info-box').children('span.item_authors').text();
			var nextExcerpt = jQuery(nextObj).children('div.content').children('div.item_excerpt').text();
			nextExcerpt = trim_words(nextExcerpt, 20);
			var nextDate = jQuery(nextObj).children('footer').children('p.pubdate').text();
		
			var nextHTML = '<h5 class="next_title">Next: <a href="'+nextItemID+'" role="button" class="modal-nav" data-dismiss="modal" data-toggle="modal" data-backdrop="false">'+nextTitle+'</a></h5>';
			nextHTML += '<p class="next_source_title">'+nextSource+'</p>';
			nextHTML += '<p class="next_author">'+nextAuthor+'</p>';
			nextHTML += '<p class="next_excerpt">'+nextExcerpt+'</p>';
			nextHTML += '<p class="next_date">'+nextDate+'</p>';
			//alert(modalID);
			jQuery(modalID+' div.modal-body-row div.modal-sidebar div.goNext').html(nextHTML);		
			jQuery(modalID+' div.mobile-goNext').html('&nbsp;| <a href="'+nextItemID+'" role="button" class="mobile-modal-navlink modal-nav" data-dismiss="modal" data-toggle="modal" data-backdrop="false">'+nextTitle+'</a> <i class="icon-arrow-right"></i>');	
		
		}
				
		
	}
	
function commentPopModal(){

	jQuery('.pf_container').on('shown', '.modal.comment-modal', function(evt){
		var elementC = jQuery(this);	
		var element = elementC.closest('article');	
		var modalID = elementC.closest('article').attr('id');		
		var modalIDString = '#'+modalID;
		//openModals.push(modalIDString);
		//alert(modalID);
		//showDiv(jQuery('#entries'), jQuery('#'+modalID));		
		var itemID = element.attr('pf-item-id');
		var postID = element.attr('pf-post-id');
		var item_post_ID = element.attr('pf-item-post-id');
		//alert(modalIDString);
		jQuery.post(ajaxurl, {
				action: 'ajax_get_comments',
				//We'll feed it the ID so it can cache in a transient with the ID and find to retrieve later.			
				id_for_comments: item_post_ID,
			}, 
			function(comment_response) {
				jQuery('#comment_modal_'+item_post_ID+' .modal-body').html(comment_response);
			});				
	});
}	
	
function reshowModal(){		
	jQuery('.pf_container').on('shown', '.modal.pfmodal', function(evt){
		jQuery('#wpadminbar').hide();
		var element = jQuery(this);	
		var modalID = element.attr('id');
		document.body.style.overflow = 'hidden';
		var bigModal = { 
			'display' : 'block',
			'position': 'fixed',
			'top': '0',
			'right': '0',
			'bottom': '100%',
			'left': '0',
			'margin': '0',
			'width': '100%',
			'height': '100%',
			'overflow' : 'hidden'
		};
		jQuery('#'+modalID+ '.pfmodal').css(bigModal);	
	});
} 
function reviewModal(){		
	//Need to fix this to only trigger on the specific model, but not sure how yet. 

	jQuery('.pressforward_page_pf-review .pf_container').on('shown', ".modal.pfmodal", function(evt){
		//alert('Modal Triggered.');

		var element = jQuery(this);		
		var modalID = element.attr('id');		
		var modalIDString = '#'+modalID;
		//openModals.push(modalIDString);
		//alert(modalID);
		//showDiv(jQuery('#entries'), jQuery('#'+modalID));		
		//var itemID = element.attr('pf-item-id');
		//var postID = element.attr('pf-post-id');
		var item_post_ID = element.parent().attr('pf-item-post-id');

		jQuery.post(ajaxurl, {
				action: 'ajax_get_comments',
				//We'll feed it the ID so it can cache in a transient with the ID and find to retrieve later.			
				id_for_comments: item_post_ID,
			}, 
			function(comment_response) {

				jQuery('#'+modalID+ '.pfmodal .modal-comments').html(comment_response);

			});		
			

		var tabindex = element.parent().attr('tabindex');

		modalNavigator(tabindex);
	});
}

function hideModal(){	
	jQuery('.pf_container').on('hide', ".modal.pfmodal", function(evt){
		jQuery(".pfmodal .modal-comments").html('');
		jQuery('#wpadminbar').show();
		document.body.style.overflow = 'visible';
	});		
}
function commentModal(){
	jQuery('.pf_container').on('show', '.comment-modal', function(evt){
		var element = jQuery(this);		
		var modalID = element.parent('article').attr('id');		
		var modalIDString = '#'+modalID;
		//openModals.push(modalIDString);
		//alert(modalID);
		//showDiv(jQuery('#entries'), jQuery('#'+modalID));		
		var itemID = element.attr('pf-item-id');
		var postID = element.attr('pf-post-id');
		var item_post_ID = element.parent().attr('pf-item-post-id');
		
		jQuery.post(ajaxurl, {
				action: 'ajax_get_comments',
				//We'll feed it the ID so it can cache in a transient with the ID and find to retrieve later.			
				id_for_comments: item_post_ID,
			}, 
			function(comment_response) {
				jQuery('#'+modalID+ '.comment-modal .modal-body').html(comment_response);
			});				
	});
}

function PFBootstrapInits() {

	jQuery('.nom-to-archive').tooltip({
		placement : 'top',
		trigger: 'hover',
		title: 'Item'
		
	});
	jQuery('.nom-to-draft').tooltip({
		placement : 'top',
		trigger: 'hover',
		title: 'Item'
		
	});
	jQuery('.nominate-now').tooltip({
		placement : 'top',
		trigger: 'hover',
		title: 'Nominate'
		
	});	
	jQuery('.itemInfobutton').popover({
		html : true,
		container : '.actions',
		content : function(){
			var idCode = jQuery(this).attr('data-target');
			var contentOutput = '<div class="feed-item-info-box">';
			contentOutput += jQuery('#info-box-'+idCode).html();
			contentOutput += '</div>';
			return contentOutput;
		}
	})
	.on("click", function(){
		jQuery('.popover').addClass(jQuery(this).data("class")); //Add class .dynamic-class to < div>
	});	
	
	jQuery(".modal.pfmodal").on('hide', function(evt){
		jQuery(".itemInfobutton").popover('hide');
	})	
	jQuery(".modal.pfmodal").on('show', function(evt){
		jQuery(".itemInfobutton").popover('hide');
	})		
	

}

jQuery(window).load(function() {

	
	jQuery('#gogrid').click(function (evt){ 
			evt.preventDefault();
			jQuery("div.pf_container").removeClass('list').addClass('grid');
		});

	jQuery('#golist').click(function (evt){ 
			evt.preventDefault();
			jQuery("div.pf_container").removeClass('grid').addClass('list');
			jQuery('.feed-item').each(function (index){
				var element		= jQuery(this);
				var itemID		= element.attr('id');
				jQuery('#'+itemID+' header .actions').appendTo('#'+itemID+' footer');
			});
		}
	);
	
	jQuery('#gomenu').toggle(function (evt){ 
			evt.preventDefault();
			var toolswin = jQuery('#tools');
			jQuery("div.pf_container").removeClass('full');
			jQuery(toolswin).show('slide',{direction:'right', easing:'linear'},150);
		}, function() {
			var toolswin = jQuery('#tools');
			jQuery(toolswin).hide('slide',{direction:'right', easing:'linear'},150);
			jQuery("div.pf_container").addClass('full');
		});	
		
	jQuery(".refreshfeed").click(function (evt){ 
		evt.preventDefault();
		jQuery('.loading-top').show();
		jQuery.post(ajaxurl, {
			action: 'assemble_feed_for_pull'
		},
		function(response) {
			jQuery('.loading-top').hide();
			jQuery('#errors').html(response);
			//jQuery("#test-div1").append(data);
		});
	
	});
	
	jQuery('#deletefeedarchive').click(function (evt) {
		evt.preventDefault();
		jQuery('.loading-top').show();
		jQuery.post(ajaxurl, {
			action: 'reset_feed'
		},
		function(response) {
			jQuery('.loading-top').hide();
			jQuery('#errors').html(response);
		});
	});
	
	jQuery('.pf_container').on('click', '#showMyNominations', function(evt){
		evt.preventDefault();
		window.open("?page=pf-menu&by=nominated", "_self")
	});	
	jQuery('.pf_container').on('click', '#showMyStarred', function(evt){    
		evt.preventDefault();
		window.open("?page=pf-menu&by=starred", "_self")
	});		
	jQuery('.pf_container').on('click', '#showNormal', function(evt){    
		evt.preventDefault();
		window.open("?page=pf-menu", "_self")
	});		
		
	reshowModal(); 
	reviewModal(); 
	hideModal();
	commentPopModal();
	PFBootstrapInits();
//	commentModal();
	
});