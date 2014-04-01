<?php

ignore_user_abort(true);
set_time_limit(0);

define( 'IC_SITEBASE', dirname(dirname(dirname(dirname(dirname(__FILE__))))) );
// print_r(IC_SITEBASE . '\wp-load.php');

if ( !defined('ABSPATH') ) {
	/** Set up WordPress environment */
	require_once(IC_SITEBASE . '\wp-load.php');
}


		$string_to_log = "\nimport-cron.php triggered.\n";
		pf_log( $string_to_log );

pressforward()->pf_feed_items->assemble_feed_for_pull();

pf_log( "import-cron.php compleated.\n\n\n" );
//do_action('get_more_feeds');

//print_r('<br /><br />Triggered <br />');
//print_r('Iteration active: ' . get_option( PF_SLUG . '_feeds_iteration') . '<br />');

?>
