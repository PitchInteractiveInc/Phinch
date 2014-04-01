<?php 

/**
 * Feed 'slurping' class
 *
 * This class handles the functions for iterating through
 * a feed list and retrieving the items in those feeds. 
 * This class should only contain those functions that
 * can be generalized to work on multiple content 
 * retrieval methods (not just RSS).
 *
 */

class PF_Feed_Retrieve {

	/**
	 * Constructor
	 */
	public function __construct() {
		add_action( 'wp_head', array($this, 'get_chunk_nonce'));
		add_action( 'init', array($this, 'alter_for_retrieval'), 999);

		// Schedule our cron actions for fetching feeds
		add_action( 'init', array($this, 'schedule_feed_in' ) );
		add_action( 'init', array($this, 'schedule_feed_out' ) );

		add_action( 'take_feed_out', array( 'PF_Feed_Item', 'disassemble_feed_items' ) );
		add_action( 'pull_feed_in', array( $this, 'trigger_source_data') );
		add_filter( 'cron_schedules', array($this, 'cron_add_short' ));
		
		if (is_admin()){
			add_action( 'wp_ajax_nopriv_feed_retrieval_reset', array( $this, 'feed_retrieval_reset') );
			add_action( 'wp_ajax_feed_retrieval_reset', array( $this, 'feed_retrieval_reset') );
			add_action( 'get_more_feeds', array( 'PF_Feed_Item', 'assemble_feed_for_pull' ) );
		}
	}	
	
	 function cron_add_short( $schedules ) {
		// Adds once weekly to the existing schedules.
		$schedules['halfhour'] = array(
			'interval' => 30*60,
			'display' => __( 'Half-hour' )
		);
		return $schedules;
	 }	
	 
	
	/**
	 * Schedules the half-hour wp-cron job
	 */
	public function schedule_feed_in() {
		if ( ! wp_next_scheduled( 'pull_feed_in' ) ) {
			wp_schedule_event( time(), 'halfhour', 'pull_feed_in' );
		}
	}

	/**
	 * Schedules the monthly feed item cleanup
	 */
	function schedule_feed_out() {
		if ( ! wp_next_scheduled( 'take_feed_out' ) ) {
			wp_schedule_event( time(), 'monthly', 'take_feed_out' );
		}
	}

	
	/**
	 * Creates a custom nonce in order to secure feed
	 * retrieval requests.
	 */
	public function get_chunk_nonce(){
		$create_nonce = wp_create_nonce('chunkpressforward');
		update_option('chunk_nonce', $create_nonce);
	}

	# A function to make absolutely sure options update
	public function update_option_w_check($option_name, $option_value){
				pf_log('Did the '.$option_name.' option update?');
				$option_result = update_option( PF_SLUG . $option_name, $option_value);
				pf_log($option_result);
			if (!$option_result) {
			
				# Occasionally WP refuses to set an option.
				# In these situations we will take more drastic measures
				# and attempt to set it again. 
			
				pf_log('For no apparent reason, the option did not update. Delete and try again.');
				pf_log('Did the option delete?');
				$deleteCheck = delete_option( PF_SLUG . $option_name );
				pf_log($deleteCheck);
				$second_check = update_option( PF_SLUG . $option_name, $option_value);
				pf_log('Did the new option setup work?');
				pf_log($second_check);
			}				
	}	

	public function step_through_feedlist() {
		# Log the beginning of this function.
		
		pf_log('step_through_feedlist begins.');
		
		# Retrieve the list of feeds. 
		
		$feedlist = $this->pf_feedlist();
		
		# Move array internal pointer to end.
		
		end($feedlist);
		
		# Because the internal pointer is now at the end
		# we can find the key for the last entry.
		
		$last_key = key($feedlist);
		
		# Log the key we retrieved. This allows us to compare
		# to the iteration state in order to avoid multiple
		# processes spawning at the same time. 
		
		pf_log('The last key is: ' . $last_key);
		
		# Get the option that stores the current step of iteration. 
		
		$feeds_iteration = get_option( PF_SLUG . '_feeds_iteration');
		
		# We will now set the lock on the feed retrieval process.
		# The logging here is to insure that lock is set. 
		
		# We begin the process of getting the next feed. 
		# If anything asks the system, from here until the end of the feed
		# retrieval process, you DO NOT attempt to retrieve another feed.
		
		# A check to see if the lock has been set.
		$this->update_option_w_check('_feeds_go_switch', 0);

		# We want to insure that we are neither skipping ahead or
		# overlapping with a previous process. To do so we store two
		# options. The first tells us the current state of iteration.
		# We don't reset the pf_feeds_iteration option until we have actually
		# begun to retrieve the feed. The pf_prev_iteration stores the 
		# last time it was set. When the feed retrieval checks begin, we set the
		# prev_iteration. When they are completed and ready to progress we
		# set the pf_feeds_iteration option. 
		#
		# At this point the last run was started (and, we assume,
		# completed, checks for that later.) but we have not advanced
		# so the two options should match.
		
		$prev_iteration = get_option( PF_SLUG . '_prev_iteration', 0);
		pf_log('Did the option properly iterate so that the previous iteration count of ' . $prev_iteration . ' is not equal to the current of ' . $feeds_iteration . '?');
		
		/* @todo This appears to be reporting with the wrong messages.
		 * We need to resolve what is going on here with the right log.
		 */
		
		// This is the fix for the insanity caused by the planet money feed - http://www.npr.org/rss/podcast.php?id=510289.
		if ( (int) $prev_iteration == (int) $feeds_iteration && (0 != $feeds_iteration)){
			
			# In some cases the option fails to update for reasons that are not
			# clear. In those cases, we will risk skipping a feed rather 
			# than get caught in an endless loop. 
			
			pf_log('Nope. Did the step_though_feedlist iteration option emergency update work here?');
			
			# Make an attempt to update the option to its appropriate state. 
			
			$this->update_option_w_check('_feeds_iteration', $feeds_iteration+1);
			# Regardless of success, iterate this process forward.
			
			$feeds_iteration++;
		} elseif ((0 == $feeds_iteration)) {
			pf_log('No, but we are at the beginning, so all is well here.');
		
		} else {
			
			# No rest for the iterative, so on we go. 
			
			pf_log('Yes');
		}
		
		# If everything goes wrong, we need to know what the iterate state is.
		# At this point $feeds_iteration should be one greater than prev_iteration.
		
		pf_log('The current iterate state is: ' . $feeds_iteration);
		
		# Insure that the function hasn't gone rogue and is not past the
		# last element in the array. 
		
		if ($feeds_iteration <= $last_key) {
			
			# The iteration state is not beyond the limit of the array
			# which means we can move forward. 
			
			pf_log('The iteration is less than the last key.');

			# Get the basic URL for the feed. 
			
			$aFeed = $feedlist[$feeds_iteration];
			pf_log('Retrieved feed');
#			$feed_url = get_post_meta($aFeed->ID, 'feedUrl', true);
#			if (empty($feed_url)){
#				update_post_meta($aFeed->ID, 'feedUrl', $aFeed->post_title);
#				$feed_url = $aFeed->post_title;
#			}
#			pf_log($feed_url);
			pf_log(' from ');
			pf_log($aFeed->guid);
			
			# @todo the above log may not work what what is being retrieved is an object.
			
			# Check the option to insure that we are currently inside the 
			# iteration process. The 'going' switch is used elsewhere to check
			# if the iteration process is active or ended.
			
			$are_we_going = get_option(PF_SLUG . '_iterate_going_switch', 1);
			pf_log('Iterate going switch is set to: ' . $are_we_going);
			
			# The last key of the array is equal to our current key? Then we are 
			# at the end of the feedlist. Set options appropriately to indicate to 
			# other processes that the iterate state will soon be terminated. 
			
			if (($last_key === $feeds_iteration)){
				pf_log('The last key is equal to the feeds_iteration. This is the last feed.');
				
				# If we're restarting after this, we need to tell the system 
				# to begin the next retrieve cycle at 0.
				
				$feeds_iteration = 0;
				$this->update_option_w_check('_iterate_going_switch', 0);

			} elseif ($are_we_going == 1) {
				pf_log('No, we didn\'t start over.');
				pf_log('Did we set the previous iteration option to ' . $feeds_iteration . '?');
				
				# We should have advanced the feeds_iteration by now, 
				# it is the active array pointer. To track this action for
				# future iterations, we store the current iteration state as
				# prev_iteration.

				$this->update_option_w_check('_prev_iteration', $feeds_iteration);
				
				# Now we advance the feeds_iteration var to the array pointer
				# that represents the next feed we will need to retrieve. 
				
				$feeds_iteration = $feeds_iteration+1;
				$this->update_option_w_check('_iterate_going_switch', 1);
				pf_log('We are set to a reiterate state.');
			} else {
				# Oh noes, what has occurred!?
				pf_log('There is a problem with the iterate_going_switch and now the program does not know its state.');
			}

			pf_log('Did the feeds_iteration option update to ' . $feeds_iteration . '?');
			
			# Set and log the update that gives us the future feed retrieval. 
			$this->update_option_w_check('_feeds_iteration', $feeds_iteration);
			
			# Log a (hopefully) successful update. 
			
			pf_log('The feed iteration option is now set to ' . $feeds_iteration);

			# If the feed retrieved is empty and we haven't hit the last feed item.
			
			if (((empty($aFeed)) || ($aFeed == '')) && ($feeds_iteration <= $last_key)){
				pf_log('The feed is either an empty entry or un-retrievable AND the iteration is less than or equal to the last key.');
				$theFeed = call_user_func(array($this, 'step_through_feedlist'));
			} elseif (((empty($aFeed)) || ($aFeed == '')) && ($feeds_iteration > $last_key)){
				pf_log('The feed is either an empty entry or un-retrievable AND the iteration is greater than the last key.');
				$this->update_option_w_check('_feeds_iteration', 0);

				$this->update_option_w_check('_feeds_go_switch', 0);

				$this->update_option_w_check('_iterate_going_switch', 0);

				pf_log('End of the update process. Return false.');
				return false;
			}

			# If the feed isn't empty, attempt to retrieve it. 
			$theFeed = self::feed_handler($aFeed);
			if (!$theFeed){
				$aFeed = '';
				pf_log('Could not get the feed.');
				pf_log('feed_handler returned ');
				pf_log($aFeed);
				#pf_log($theFeed->get_error_message());
			}
			# If the array entry is empty and this isn't the end of the feedlist,
			# then get the next item from the feedlist while iterating the count.
			if (((empty($aFeed)) || ($aFeed == '') || (is_wp_error($theFeed))) && ($feeds_iteration <= $last_key)){
				pf_log('The feed is either an empty entry or un-retrievable AND the iteration is less than or equal to the last key.');
				
				# The feed is somehow bad, lets get the next one. 
				
				$theFeed = call_user_func(array($this, 'step_through_feedlist'));
			} elseif (((empty($aFeed)) || ($aFeed == '') || (is_wp_error($theFeed))) && ($feeds_iteration > $last_key)){
			
				# The feed is somehow bad and we've come to the end of the array.
				# Now we switch all the indicators to show that the process is
				# over and log the process. 
			
				pf_log('The feed is either an empty entry or un-retrievable AND the iteration is greater then the last key.');
				$this->update_option_w_check('_feeds_iteration', 0);

				$this->update_option_w_check('_feeds_go_switch', 0);

				$this->update_option_w_check('_iterate_going_switch', 0);

				pf_log('End of the update process. Return false.');
				return false;
			}
			return $theFeed;
		} else {
			//An error state that should never, ever, ever, ever, ever happen.
			pf_log('The iteration is now greater than the last key.');
				$this->update_option_w_check('_feeds_iteration', 0);

				$this->update_option_w_check('_feeds_go_switch', 0);

				$this->update_option_w_check('_iterate_going_switch', 0);
				pf_log('End of the update process. Return false.');
				return false;
			//return false;
		}

	}	

	# Where we store a list of feeds to check.
	# We need this to handle some sort of subsets of feeds
	# Eventually it should be going through these queries
	# as pages to decrease server load from giant query
	# results.
	public function pf_feedlist($startcount = 0) {
		pf_log( 'Invoked: PF_Feed_Retrieve::pf_feedlist()' );
		$args = array(
				'posts_per_page'=>-1
			);
		$theFeeds = pressforward()->pf_feeds->get( $args );
		$feedlist = array();
		
		if ( !isset($theFeeds)){
			# @todo a better error report
			return false;
		} elseif (is_wp_error($theFeeds)) {
			return $theFeeds;
		} else {
			foreach ($theFeeds as $aFeed) {
			
				$feedlist[] = $aFeed;
			
			}
		}
		$all_feeds_array = apply_filters( 'imported_rss_feeds', $feedlist );
		pf_log('Sending feedlist to function.');
		$ordered_all_feeds_array = array_values($all_feeds_array);
		#$tidy_all_feeds_array = array_filter( $ordered_all_feeds_array, 'strlen' );
		return $ordered_all_feeds_array;

	}
	
	/*
	 * Check if the requested feed_type exists
	 *
	 */
	public function does_type_exist($type){
		$type_check = false;
		$module_to_use = false;
		if ($type == 'rss-quick'){
			$type = 'rss';
		}
		foreach ( pressforward()->modules as $module ) {
			if ($type_check){
				return $module_to_use;
			}
			$module_type = $module->feed_type;
			if ($module_type == $type){
				# id and slug should be the same right?
				$module_to_use = $module->id;
				$type_check = true;
			}
		}

		if (!$type_check) {
			# Needs to be a better error.
			return false;
		}
	}
	
	
	/*
	 *
	 * This will attempt to retrieve the feed
	 * based on an available module function.
	 *
	*/
	public function get_the_feed_object($module_to_use, $aFeedObj){
		
		$module = pressforward()->modules[$module_to_use];
		$feedObj = $module->get_data_object($aFeedObj);
		if (empty($feedObj) || !$feedObj){
			return false;
		} else {
			$feedObj['parent_feed_id'] = $aFeedObj->ID;
			return $feedObj;
		}
		
	}

	# Take the feed type and the feed id
	# and apply filters so that we know which 
	# function to call to handle the feed
	# and handle the item correctly. 
	# If check = true than this is just a validator for feeds.
	public function feed_handler($obj, $check = false){
		global $pf;
		$Feeds = new PF_Feeds_Schema();	
		pf_log( 'Invoked: PF_Feed_retrieve::feed_handler()' );
		pf_log( 'Are we just checking?' );
		pf_log( $check );
		#setup_postdata($obj);
		$id = $obj->ID;
		pf_log( 'Feed ID ' . $id );
		$type = $Feeds->get_pf_feed_type($id);
		pf_log( 'Checking for feed type ' . $type );	
		$module_to_use = $this->does_type_exist($type);
		if (!$module_to_use){
			# Be a better error.
			pf_log( 'The feed type does not exist.' );
			return false;
		}
		
		pf_log('Begin the process to retrieve the object full of feed items.');
		//Has this process already occurring?
		$feed_go = update_option( PF_SLUG . '_feeds_go_switch', 0);
		pf_log('The Feeds go switch has been updated?');
		pf_log($feed_go);
		$is_it_going = get_option(PF_SLUG . '_iterate_going_switch', 1);
		if ($is_it_going == 0){
			//WE ARE? SHUT IT DOWN!!!
			update_option( PF_SLUG . '_feeds_go_switch', 0);
			update_option( PF_SLUG . '_feeds_iteration', 0);
			update_option( PF_SLUG . '_iterate_going_switch', 0);
			//print_r('<br /> We\'re doing this thing already in the data object. <br />');
			if ( (get_option( PF_SLUG . '_ready_to_chunk', 1 )) === 0 ){
				pf_log('The chunk is still open because there are no more feeds. [THIS SHOULD NOT OCCUR except at the conclusion of feeds retrieval.]');
				# Wipe the checking option for use next time. 
				update_option(PF_SLUG . '_feeds_meta_state', array());
				update_option( PF_SLUG .  '_ready_to_chunk', 1 );
			} else {
				pf_log('We\'re doing this thing already in the data object.', true);
			}
			//return false;
			die();
		}

		if ('rss-quick' == $type){
			# Let's update the RSS-Quick so it has real data.
			$rq_update = array(
				'type'		=>		'rss-quick',
				'ID'		=>		$id,
				'url'		=>		$obj->guid
			);
			$Feeds->update($id, $rq_update);
		}
		
		# module function to return a set of standard pf feed_item object
		# Like get_items in SimplePie
		$feedObj = $this->get_the_feed_object($module_to_use, $obj);
		
		if ($check){
			# Be a better error.
			if (!$feedObj){
				return false;
			} else {
				return true;
			}
		} else {
		
			# We've completed the feed retrieval, the system should know it is now ok to ask for another feed.
			$feed_go = update_option( PF_SLUG . '_feeds_go_switch', 1);
			pf_log('The Feeds go switch has been updated to on?');
			pf_log($feed_go);
			$prev_iteration = get_option( PF_SLUG . '_prev_iteration', 0);
			$iterate_op_check = get_option( PF_SLUG . '_feeds_iteration', 1);
			pf_log('Did the option properly iterate so that the previous iteration count of ' . $prev_iteration . ' is not equal to the current of ' . $iterate_op_check . '?');
			if ($prev_iteration === $iterate_op_check){
				pf_log('Nope. Did the iteration option emergency update function here?');
				$check_iteration = update_option( PF_SLUG . '_feeds_iteration', $iterate_op_check+1);
				pf_log($check_iteration);

			} else {
				pf_log('Yes');
			}		
		
			return $feedObj;
		}
		
		#foreach ($feedObj as $item) {
			
		#	$item
			
		#}
		
	}
	
	public function is_feed($obj){
			# By passing true, we're making it return
			# a bool.
			return $this->feed_handler($obj, true);
	}
	
	public function is_feed_by_id($id){
		$obj = get_post($id);
		return $this->feed_handler($obj, true);
	}
	
	public function advance_feeds(){
		pf_log('Begin advance_feeds.');
		//Here: If feedlist_iteration is not == to feedlist_count, scheduale a cron and trigger it before returning.
				$feedlist = self::pf_feedlist();
		//The array keys start with zero, as does the iteration number. This will account for that.
		$feedcount = count($feedlist) - 1;
		//Get the iteration state. If this variable doesn't exist the planet will break in half.
		$feeds_iteration = get_option( PF_SLUG . '_feeds_iteration');

		$feed_get_switch = get_option( PF_SLUG . '_feeds_go_switch');
		if ($feed_get_switch != 0) {
			pf_log('Feeds go switch is NOT set to 0.');
			pf_log('Getting import-cron.');

			//http://codex.wordpress.org/Function_Reference/wp_schedule_single_event
			//add_action( 'pull_feed_in', array($this, 'assemble_feed_for_pull') );
			//wp_schedule_single_event(time()-3600, 'get_more_feeds');
			//print_r('<br /> <br />' . PF_URL . 'modules/rss-import/import-cron.php <br /> <br />');
			$theRetrievalLoop = add_query_arg( 'press', 'forward',  site_url() );
			$pfnonce = get_option('chunk_nonce');
			$theRetrievalLoopNounced = add_query_arg( '_wpnonce', $pfnonce,  $theRetrievalLoop );
			pf_log('Checking remote get at ' . $theRetrievalLoopNounced . ' : ');
			$wprgCheck = wp_remote_get($theRetrievalLoopNounced);


			return;
			//pf_log($wprgCheck);
			//Looks like it is scheduled properly. But should I be using wp_cron() or spawn_cron to trigger it instead?
			//wp_cron();
			//If I use spawn_cron here, it can only occur every 60 secs. That's no good!
			//print_r('<br />Cron: ' . wp_next_scheduled('get_more_feeds') . ' The next event.');
			//print_r(get_site_url() . '/wp-cron.php');
			//print_r($wprgCheck);
		} else {
			pf_log('Feeds go switch is set to 0.');
		}
	}

	public function alter_for_retrieval() {
		#print_r('alter_ready');
		//$nonce = isset( $_REQUEST['_wpnonce'] ) ? $_REQUEST['_wpnonce'] : '';
		//$nonce_check = get_option('chunk_nonce');
		if ( isset( $_GET['press'] ) && $_GET['press'] == 'forward'){
			# Removing this until we decide to replace or eliminate. It isn't working.
			//if ( $nonce === $nonce_check){
				pf_log('Pressing forward.');
				include(PF_ROOT . '/includes/import-cron.php');
				exit;
			//} else {
			//	$verify_val = wp_verify_nonce($nonce, 'retrieve-pressforward');
			//	pf_log('Nonce check of ' . $nonce . ' failed. Returned: ');
			//	pf_log($verify_val);
			//	pf_log('Stored nonce:');
			//	pf_log($nonce_check);
			//}
		}
	}
	
	function feed_retrieval_reset(){
		$feed_go = update_option( PF_SLUG . '_feeds_go_switch', 0);
		$feed_iteration = update_option( PF_SLUG . '_feeds_iteration', 0);
		$retrieval_state = update_option( PF_SLUG . '_iterate_going_switch', 0);
		$chunk_state = update_option( PF_SLUG . '_ready_to_chunk', 1 );
		
 	}

	public function trigger_source_data(){
			$feed_go = get_option( PF_SLUG . '_feeds_go_switch', 0);
			$feed_iteration = get_option( PF_SLUG . '_feeds_iteration', 0);
			$retrieval_state = get_option( PF_SLUG . '_iterate_going_switch', 0);
			$chunk_state = get_option( PF_SLUG . '_ready_to_chunk', 1 );		
		pf_log( 'Invoked: PF_Feed_Retrieve::trigger_source_data()' );
		pf_log( 'Feeds go?: ' . $feed_go );
		pf_log( 'Feed iteration: ' . $feed_iteration );
		pf_log( 'Retrieval state: ' . $retrieval_state );
		pf_log( 'Chunk state: ' . $chunk_state );
		if ($feed_iteration == 0 && $retrieval_state == 0 && $chunk_state == 1){
			$status = update_option( PF_SLUG . '_iterate_going_switch', 1);

			pf_log( __('Beginning the retrieval process', 'pf'), true, true );

			if ( $status ) {
				pf_log( __( 'Iterate switched to going.', 'pf' ) );
			} else {
				pf_log( __( 'Iterate option not switched.', 'pf') );
			}

			pressforward()->pf_feed_items->assemble_feed_for_pull();
		} else {
			
			$feeds_meta_state = get_option(PF_SLUG . '_feeds_meta_state', array());
			if (empty($feeds_meta_state)){
				$feeds_meta_state = array(
											'feed_go' => $feed_go,
											'feed_iteration' =>	$feed_iteration,
											'retrieval_state' => $retrieval_state,
											'chunk_state'	=> $chunk_state,
											'retrigger'		=>	time() + (2 * 60 * 60)
										);
				update_option(PF_SLUG . '_feeds_meta_state', $feeds_meta_state);						
				pf_log(__('Created new metastate.', 'pf'), true);						
			} else {
				pf_log(__('Metastate saved and active for check.', 'pf'), true);
				pf_log($feeds_meta_state);
			}
			
			if ($feeds_meta_state['retrigger'] > time()){
					pf_log(__('The sources are already being retrieved.', 'pf'), true);
			} else {		
					if (($feed_go == $feeds_meta_state['feed_go']) && ($feed_iteration == $feeds_meta_state['feed_iteration']) && ($retrieval_state == $feeds_meta_state['retrieval_state']) && ($chunk_state == $feeds_meta_state['chunk_state'])){
						pf_log(__('The sources are stuck.', 'pf'), true);
						# Wipe the checking option for use next time. 
						update_option(PF_SLUG . '_feeds_meta_state', array());
						update_option( PF_SLUG . '_ready_to_chunk', 1 );
						update_option(PF_SLUG . '_iterate_going_switch', 1);
						pressforward()->pf_feed_items->assemble_feed_for_pull();
					} elseif (($feeds_meta_state['retrigger'] < (time() + 86400)) && !(empty($feeds_meta_state))) {
						# If it has been more than 24 hours and retrieval has been frozen in place
						# and the retrieval state hasn't been reset, reset the check values and reset
						# the meta state. If it is actually mid-process things should progress.
						# Otherwise next meta-state check will iterate forward.
						update_option( PF_SLUG . '_feeds_go_switch', 0);
						update_option( PF_SLUG . '_ready_to_chunk', 1 );
						update_option(PF_SLUG . '_feeds_meta_state', array());
						update_option(PF_SLUG . '_iterate_going_switch', 0);
						update_option( PF_SLUG . '_feeds_iteration', 0);
						$double_check = array(
													'feed_go' => 0,
													'feed_iteration' =>	0,
													'retrieval_state' => 0,
													'chunk_state'	=> 1,
													'retrigger'		=>	$feeds_meta_state['retrigger']
												);
						update_option(PF_SLUG . '_feeds_meta_state', $double_check);
						pf_log(__('The meta-state is too old. It is now reset. Next time, we should start over.', 'pf'), true);
					} else {
						$double_check = array(
													'feed_go' => $feeds_meta_state['feed_go'],
													'feed_iteration' =>	$feed_iteration,
													'retrieval_state' => $feeds_meta_state['retrieval_state'],
													'chunk_state'	=> $feeds_meta_state['chunk_state'],
													'retrigger'		=>	$feeds_meta_state['retrigger']
												);
						update_option(PF_SLUG . '_feeds_meta_state', $double_check);
						pf_log($double_check);						
						pf_log(__('The sources are already being retrieved.', 'pf'), true);
					}
				
			}
		}
	}	
	
	
}