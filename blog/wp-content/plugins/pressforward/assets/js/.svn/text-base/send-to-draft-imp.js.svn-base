jQuery(window).load(function() {

	jQuery('.pf_container').on('click', ".nom-to-draft", function (evt){ 
		evt.preventDefault();
		
	var element			= jQuery(this);
	var itemID			= element.attr('form');
	var nom_title 		= jQuery("#nom_title_"+itemID).val();
	var nom_id			= jQuery("#nom_id_"+itemID).val(); //
	var nom_date 		= jQuery("#date_nominated_"+itemID).val(); //
	var nom_tags		= jQuery("#nom_tags_"+itemID).val(); //
	var nom_count		= jQuery("#nominators_"+itemID).val(); //
	var nom_users		= jQuery("#submitters_"+itemID).val(); //
	var nom_content 	= jQuery("#item_content_"+itemID).val();
	var nom_feat_img 	= jQuery("#nom_feat_img_"+itemID).val();
//	var source_repeats 	= jQuery("#source_repeat_"+itemID).val(); 	
	var source_title 	= jQuery("#source_title_"+itemID).val(); 
	var source_link 	= jQuery("#source_link_"+itemID).val(); //
	var source_slug 	= jQuery("#source_slug_"+itemID).val(); //
//	var item_id 		= jQuery("#item_id_"+itemID).val();
	var item_date 		= jQuery("#posted_date_"+itemID).val(); //
	var item_author 	= jQuery("#authors_"+itemID).val(); //
	var item_link 		= jQuery("#permalink_"+itemID).val(); //
	var nom_title		= jQuery("#item_title_"+itemID).val(); //
	var addl_tags		= jQuery("#tag_input_"+itemID).val();
//	var errorThrown		= 'Broken';
	var theNonce		= jQuery.trim(jQuery('#pf_drafted_nonce').val())
	jQuery('.loading-'+itemID).show();
	jQuery.post(ajaxurl, {
			action: 'build_a_nom_draft',
			nom_title: nom_title,
			nom_id: nom_id,
			nom_date: nom_date,
//			nom_modified_date: nom_mod_date,
			nom_tags: nom_tags,
			nom_count: nom_count,
			nom_users: nom_users,
			nom_content: nom_content,	
			nom_feat_img: nom_feat_img,			
			source_title: source_title,
			source_link: source_link,
			source_slug: source_slug,
			item_id: itemID,			
			item_date: item_date,
			item_author: item_author,
			item_link: item_link,
			nom_title: nom_title,
			addl_tags: addl_tags,
			//Nom comments will sit here eventually.
			pf_drafted_nonce: theNonce
		},
		function(response) {
			jQuery('.loading-'+itemID).hide();
			//jQuery(".result-status-"+itemID+" .msg-box").html(response);
			//alert(response);
			//jQuery("#test-div1").append(data);
		});
	  });
  	
});

jQuery(window).load(function() {
	jQuery('.pf_container').on('show', ".nom-item", function (){ 
		var element			= jQuery(this);
		var itemID			= element.attr('id');
		
		jQuery('#item-box-'+itemID).removeClass('span12');
		jQuery('#item-box-'+itemID).addClass('span9');
		jQuery('#action-box-'+itemID).addClass('span3');
		jQuery('#action-box-'+itemID).show();
		jQuery('#excerpt-graf-'+itemID).hide();
		
	});
	jQuery('.pf_container').on('hide', ".nom-item", function (){
		var element			= jQuery(this);
		var itemID			= element.attr('id');
		
		jQuery('#action-box-'+itemID).removeClass('span3');
		jQuery('#action-box-'+itemID).hide();		
		jQuery('#item-box-'+itemID).removeClass('span9');
		jQuery('#item-box-'+itemID).addClass('span12');
		jQuery('#excerpt-graf-'+itemID).show();
		
	}
	);
});	