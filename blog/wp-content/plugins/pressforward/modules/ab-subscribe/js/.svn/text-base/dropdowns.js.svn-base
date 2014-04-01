jQuery(document).ready(function($){
	ab_refresh_dropdown( 'ab-cats' );

	$('select.ab-dropdown').on( 'change', function(e) {
		ab_refresh_dropdown( e.target.id );
	});
},(jQuery));

function ab_refresh_dropdown( id ) {
	if ( 'ab-blogs' == id ) {
		return;
	}

	var dd, ddval, cats, options, opts, child_id, child_dd, cat_id;
	dd = document.getElementById( id );

	if ( null === dd ) {
		return;
	}

	ddval = dd.value;
	if ( 0 == ddval.length || '-' == ddval ) {
		return;
	}

	cats = JSON.parse( ABLinksArray );

	if ( 'ab-cats' == id ) {
		opts = cats.categories[ddval].links;
		child_id = 'ab-subcats';
		child_dd = document.getElementById( child_id );
	} else if ( 'ab-subcats' == id ) {
		cat_id = document.getElementById( 'ab-cats' ).value;
		opts = cats.categories[cat_id].links[ddval].blogs;
		child_id = 'ab-blogs';
		child_dd = document.getElementById( child_id );
	}

	options += '<option>-</option>';
	jQuery.each( opts, function( optslug, opt ) {
		options += '<option value="' + optslug + '">' + opt.title + '</option>';
	} );

	child_dd.innerHTML = options;
	jQuery(child_dd).removeAttr( 'disabled' );
	
	// If refreshing the top level, refresh subsequent levels too
	if ( 'ab-cats' == id ) {
		ab_refresh_dropdown( 'ab-subcats' );
	}
}
