jQuery(document).ready(function($){
	function refresh_ab_feeds( start ) {
		$( "#calc_progress" ).progressbar('value', parseFloat(start));
		
		if ( 100 <= start ) {
			// Let WP know that we're done.
			$.post( ajaxurl, { action: 'finish_ab_feeds' } );
			alert('Refresh complete!');
			return false;
		}
		
		$.post( ajaxurl, {
				action: 'refresh_ab_feeds',
				'start': parseFloat(start)
			},
			function(response) {
				refresh_ab_feeds( response );
			}
		);
		
	}
	
	$('#calc_submit').click(function(){
		$( "#calc_progress" ).progressbar({
			value: 0
		});
		refresh_ab_feeds(0);
		
		return false;
	});
	
	$('a.delete-batch-confirm').click(function(){
		if ( confirm('Are you sure? There is NO UNDO for this action. (Click OK to delete the entire snapshot)') ) {
			return true;
		} else {
			return false;
		}
	});
},(jQuery));
