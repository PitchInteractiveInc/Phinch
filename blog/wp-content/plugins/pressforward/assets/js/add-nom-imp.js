jQuery(window).load(function() {

	//jQuery('#pf-nominations').addClass('closed');
	jQuery('#publish').removeClass('button-primary').addClass('button to-check').attr('value', 'Send to Draft');
	jQuery('#save-post').addClass('button-primary to-check').attr('value', 'Nominate');
	
	jQuery('#save-action').on('click', '#save-post', function(e){
		e.preventDefault();
		var youFail = false;
		jQuery('#pf-nominations input').each( function(i){
			if( !jQuery(this).val()){
				youFail = true;
			}
		});
		if (youFail){
			alert('Please fill out all nomination data.');
			jQuery('.button-primary-disabled').removeClass('button-primary-disabled');
			//jQuery('#draft-ajax-loading').hide();
		}
	});

});