<?php

/**
 * Test of module base class
 */

define( 'FEED_LOG', PF_ROOT . "/modules/rss-import/rss-import.txt" );
class PF_RSS_Import extends PF_Module {
	
	/////////////////////////////
	// PARENT OVERRIDE METHODS //
	/////////////////////////////

	/**
	 * Constructor
	 */
	public function __construct() {
		$this->feed_type = 'rss';
		parent::start();

		//self::check_nonce = wp_create_nonce('retrieve-pressforward');
		add_action( 'admin_init', array($this, 'register_settings') );

		if( is_admin() )
		{
			add_action( 'wp_ajax_nopriv_remove_a_feed', array( $this, 'remove_a_feed') );
			add_action( 'wp_ajax_remove_a_feed', array( $this, 'remove_a_feed') );

		}
	}

	/**
	 * Run any setup that has to happen after initial module registration
	 */
	public function post_setup_module_info() {
		$this->includes();
	}

	/**
	 * Includes necessary files
	 */
	public function includes() {
	
	}
	
	/**
	 * Used to return a value in seconds that WordPress should be caching feeds
	 * before retrieval.
	 *
	 * Filters to 'wp_feed_cache_transient_lifetime'
	 */
	 
	 public function return_cachetime($seconds){
	 	
	 	return 1800;
	 }

	/**
	 * Gets the data from an RSS feed and turns it into a data object
	 * as expected by PF
	 *
	 * @global $pf Used to access the feed_object() method
	 */
	public function get_data_object($aFeed) {
		pf_log( 'Invoked: PF_RSS_Import::get_data_object()' );
		$aFeed_url = $aFeed->guid;
#		$aFeed_id = $aFeed->ID;
#		$aFeed_url = get_post_meta($aFeed_id, 'feedUrl', true);
#		if(empty($aFeed_url) || is_wp_error($aFeed_url) || !$aFeed_url){
#			$aFeed_url = $aFeed->post_title;
#			update_post_meta($aFeed_id, 'feedUrl', $aFeed_url);
#		}
		pf_log( 'Getting RSS Feed at '.$aFeed_url );
		add_filter('wp_feed_cache_transient_lifetime', array($this, 'return_cachetime'));
		$theFeed = fetch_feed($aFeed_url);
		remove_filter('wp_feed_cache_transient_lifetime', array($this, 'return_cachetime'));
#		pf_log( 'Getting RSS Feed at '.$aFeed_url );
		if (!$theFeed || empty($theFeed) || is_wp_error($theFeed)){
			pf_log('Can not use Simple Pie to retrieve the feed');
			pf_log($theFeed);
			return false;
		}
		$theFeed->set_timeout(60);
		$rssObject = array();
		$c = 0;
		pf_log('Begin processing the feed.');			

		foreach($theFeed->get_items() as $item) {
			pf_log('Feed looping through for the ' . $c . ' time.');
			$check_date = $item->get_date('U');
			$dead_date = time() - (60*60*24*60); //Get the unixdate for two months ago.
			if ($check_date <= $dead_date) {
				pf_log('Feed item too old. Skip it.');
			} else {
				$id = md5($item->get_link() . $item->get_title()); //die();
				pf_log('Now on feed ID ' . $id . '.');
				//print_r($item_categories_string); die();

				if ( false === ( $rssObject['rss_' . $c] = get_transient( 'pf_' . $id ) ) ) {
					if ($item->get_source()){
						$sourceObj = $item->get_source();
						# Get the link of what created the RSS entry.
						$source = $sourceObj->get_link(0,'alternate');
						# Check if the feed item creator is an aggregator.
						$agStatus = $this->is_from_aggregator($source);
					} else {
						# If we can't get source information then don't do anything.
						$agStatus = false;
					}
					# If there is less than 160 characters of content, than it isn't really giving us meaningful information.
					# So we'll want to get the good stuff from the source.
					if ((strlen($item->get_content())) < 160){
						$agStatus = true;
					}
					//override switch while rest is not working.
					//$agStatus = false;
					//This is where we switch off auto readability
					//And leave it to an AJAX function instead.
	//				if ($agStatus){
	//					# Get the origin post link.
	//					$realLink = $item->get_link();
	//					# Try and get the actual content of the post.
	//					$realContent = $pf->get_content_through_aggregator($realLink);
	//					# If we can't get the actual content, then just use what we've got from the RSS feed.
	//					if (!$realContent){
							$item_content = $item->get_content();
	//					} else {
	//						$item_content = $realContent;
							//print_r($realContent);
	//					}
	//				} else {
	//						$item_content = $item->get_content();
	//				}
					$iFeed = $item->get_feed();
					if (!$agStatus){
						$authors = $this->get_rss_authors($item);
					}
					else {
						$authors = 'aggregation';
					}
					$item_categories = array();
					$item_categories = $item->get_categories();
					$itemTerms = array();
					if (!empty($item_categories)){
						foreach ($item_categories as $item_category){
							$itemTerms[] = $item_category->get_term();
						}
						$item_categories_string = implode(',',$itemTerms);
					} else { $item_categories_string = ''; }
					//one final cleanup of the content.
					$contentObj = new pf_htmlchecker($item_content);
					$item_content = $contentObj->closetags($item_content);
					print_r($c);
					$rssObject['rss_' . $c] = pf_feed_object(
												$item->get_title(),
												$iFeed->get_title(),
												$item->get_date('r'),
												$authors,
												$item_content,
												$item->get_link(),
												'',
												$id,
												$item->get_date('Y-m-d'),
												$item_categories_string
												);
					pf_log('Setting new transient for ' . $item->get_title() . ' of ' . $iFeed->get_title() . '.');
					set_transient( 'pf_' . $id, $rssObject['rss_' . $c], 60*10 );

				}
			}
			$c++;
			# What the hell RSS feed? This is just ridiculous.
			if ($c > 300) {break;}

		}

		//$this->advance_feeds();

		return $rssObject;

	}

	/////////////////////////////
	// UTILITY METHODS         //
	/////////////////////////////

	# Retrieve the set of items. 
	public function pf_feed_fetcher($aFeed){
		
		# Control retrieval with a filtered array
		# Allow people to register types and handling functions
		# rss and rss-quick will both call fetch_feed
		
		$theFeed = fetch_feed($aFeed);

		if ((is_wp_error($theFeed))){
			print_r('<br />The Feed ' . $aFeed . ' could not be retrieved.');
				//$aFeed = call_user_func(array($this, 'step_through_feedlist'));
				//$theFeed = $this->pf_feed_fetcher($aFeed);
				return false;
		}

		return $theFeed;
	}

	# Tries to get the RSS item author for the meta.
	function get_rss_authors($item) {
		// This needs error checking.
		$authorArray = ($item->get_authors());
		if (!empty($authorArray)){
			foreach ($authorArray as $author) {

				$nameArray[] = $author->get_name();

			}
			$authors = implode(', ', $nameArray);
			$authors = $authors;

		} else {
			$authors = __('No author.', 'pf');
		}

		return $authors;
	}

	function add_to_feeder() {

		
        settings_fields( PF_SLUG . '_feedlist_group' );
		$feedlist = get_option( PF_SLUG . '_feedlist' );

        ?>
		<div class="pf-opt-group">
			<br />
			<br />
			<div><?php _e('Add Single RSS Feed', 'pf'); ?></div>
				<div>
					<input id="<?php echo PF_SLUG . '_feedlist[single]'; ?>" class="regular-text" type="text" name="<?php echo PF_SLUG . '_feedlist[single]'; ?>" value="" />
                    <label class="description" for="<?php echo PF_SLUG . '_feedlist[single]'; ?>"><?php _e('*Complete URL or RSS path', 'pf'); ?></label>


                </div>

			<div><?php _e('Add OPML File', 'pf'); ?></div>
				<div>
					<input id="<?php echo PF_SLUG . '_feedlist[opml]'; ?>" class="regular-text" type="text" name="<?php echo PF_SLUG . '_feedlist[opml]'; ?>" value="" />
                    <label class="description" for="<?php echo PF_SLUG . '_feedlist[opml]'; ?>"><?php _e('*Drop link to OPML here. No HTTPS allowed.', 'pf'); ?></label>


                </div>
		</div>
		<?php



	}

	public function feedlist_builder($feedlist){
		if (empty($feedlist)){
			echo __('No feeds added.', 'pf');
			return;
		}
		foreach ($feedlist as $feed){
			if ((!is_array($feed)) && $feed != ''){
				$feedID = md5($feed);
				echo '<li id="feed-' . $feedID . '" class="feed-list-item">' . $feed . ' <input id="' . $feedID . '" type="submit" class="removeMyFeed icon-remove-sign" value="   Remove"></input>';
				echo '<input type="hidden" name="feed_url" id="o_feed_url_' . $feedID . '" value="' . $feed . '"></li>';
			} elseif (is_array($feed)){
				$this->feedlist_builder($feed);
			}

		}

		return;
	}

	public static function pf_feedlist_validate($input){
		set_time_limit(0);
		pf_log('Add Feed Process Invoked: PF_RSS_IMPORT::pf_feedlist_validate');
		pf_log($input);
		if ( current_user_can('edit_post') ) {
 			pf_log('Yes, the current user can edit posts.');
		} else {
			pf_log('No, the current user can not edit posts.');
		}
		$feed_obj = pressforward()->pf_feeds;
		$subed = '';
		if (!empty($input['single'])){
			if (!(is_array($input['single']))){
				pf_log('The feed is not an array;');
				if (!$feed_obj->has_feed($input['single'])){
					pf_log('The feed does not already exist.');
					$check = $feed_obj->create($input['single'], array('type' => 'rss', 'module_added' => get_class($this)));
					if (is_wp_error($check) || !$check){
						pf_log('The feed did not enter the database.');
						#wp_die($check);
						$description = 'Feed failed initial attempt to add to database | ' . $check->get_error_message();
						$feed_obj->create($input['single'], array('type' => 'rss-quick', 'description' => $description, 'module_added' => get_called_class()));
					}
				} else {
					pf_log('The feed already exists, sending it to update.');
					$check = $feed_obj->update_url($input['single']);
					pf_log('Our attempt to update resulted in:');
					pf_log($check);
				}
				
				$subed = 'a feed ';
			} else {
				pf_log('The feed was an array, this does not work');
				wp_die('Bad feed input. Why are you trying to place an array?');
			}
		}
		#var_dump($input);
		#die();
		//print_r($inputSingle);

		if (!empty($input['opml'])){
			$OPML_reader = new OPML_reader;
			$opml_array = $OPML_reader->get_OPML_data($input['opml']);
			//print_r($opml_array); die();
			foreach($opml_array as $key=>$feedXml){
				# Adding this as a 'quick' type so that we can process the list quickly.
				pf_log('Adding this as a quick type so that we can process the list quickly');
				$opml_array = $feed_obj->progressive_feedlist_transformer($opml_array, $feedXml, $key);
				# @todo Tag based on folder structure
			}
			$check_up = update_option( PF_SLUG . '_feedlist', $opml_array );
			$subed = 'an OPML file ';
		}

		if (!empty($_POST['o_feed_url'])){
				$offender = array_search($_POST['o_feed_url'], $feedlist);
				if ($offender !== false){
					unset($feedlist[$offender]);
				}

		}
		
		add_settings_error('add_pf_feeds', 'pf_feeds_validation_response', 'You have submitted '.$subed.'.', 'updated');
		return $input;
		
	}

	public function remove_a_feed() {

		if (!empty($_POST['o_feed_url'])){
			$feedURL = $_POST['o_feed_url'];
			if ( !wp_verify_nonce($_POST[PF_SLUG . '_o_feed_nonce'], 'feedremove') )
				die( __( 'Nonce check failed. Please ensure you\'re supposed to be removing feeds.', 'pf' ) );
		/**
			$feedlist = get_option( PF_SLUG . '_feedlist' );

			$offender = array_search($feedURL, $feedlist);
			if ($offender !== false){
				unset($feedlist[$offender]);
			}
			//$modfeedlist = array_diff($feedlist, array($feedURL));
			//update_option( PF_SLUG . '_feedlist', '');
			//delete_option( PF_SLUG . '_feedlist' );
**/
			// The pf_feedlist setting is being filtered through the pf_feedlist_validate
			// method, as a result of being registered with register_setting(). We'll work
			// around this by unhooking the validation method during this update
			//remove_action( 'sanitize_option_pf_feedlist', array( 'PF_RSS_Import', 'pf_feedlist_validate' ) );
			$check = update_option( PF_SLUG . '_feedlist', $_POST);

			if (!$check){
				$result = __('The feedlist failed to update.', 'pf');
			} else {
				$result = $feedURL . __(' has been removed from your feedlist.', 'pf');
			}

			die($result);
		} else {
			die(__('Error', 'pf'));
		}

	}

	function register_settings(){
		register_setting(PF_SLUG . '_feedlist_group', PF_SLUG . '_feedlist', array('PF_RSS_Import', 'pf_feedlist_validate'));
	}

	# Checks the URL against a list of aggregators.
	public function is_from_aggregator($xmlbase){
		$c = 0;
		$urlParts = parse_url($xmlbase);

		$aggregators = array (
								'tweetedtimes',
								'tweetedtimes.com',
								'www.tweetedtimes.com',
								'pipes.yahoo.com'
							);
		foreach ($aggregators as $aggregator) {
			if (in_array($aggregator, $urlParts)){
				$c++;
			}
		}
		if ($c > 0){

			return true;


		} else {
			return false;
		}

	}

	public function admin_enqueue_scripts() {
		global $pagenow;
		$pf = pressforward();

		$hook = 0 != func_num_args() ? func_get_arg( 0 ) : '';

		if ( !in_array( $pagenow, array( 'admin.php' ) ) )
			return;

		if(!in_array($hook, array('pressforward_page_pf-feeder')) )
			return;		
		
		wp_enqueue_script( 'feed-manip-ajax', $pf->modules['rss-import']->module_url . 'assets/js/feed-manip-imp.js', array( 'jquery', PF_SLUG . '-twitter-bootstrap') );
		wp_enqueue_style( PF_SLUG . '-feeder-style', $pf->modules['rss-import']->module_url . 'assets/css/feeder-styles.css' );
	}


}


function pf_test_import() {
	if ( is_super_admin() && ! empty( $_GET['pf_test_import'] ) ) {
		var_dump( pf_get_starred_items_for_user( get_current_user_id(), 'simple' ) );
		return;
		$feed = fetch_feed( 'http://teleogistic.net/feed' );

		$source = $feed->subscribe_url();

		foreach ( $feed->get_items() as $item ) {
			$io = new PF_Feed_Item();

			// Check for existing items before importing
			$foo = $io->get( array(
				'url' => $item->get_link( 0 ),
				'foo' => 'bar',
			) );

			if ( empty( $foo ) ) {
				$tags = wp_list_pluck( $item->get_categories(), 'term' );
				$fi_id = $io->create( array(
					'title'   => $item->get_title(),
					'url'     => $item->get_link( 0 ),
					'content' => $item->get_content(),
					'source'  => $source,
					'date'    => strtotime( $item->get_date() ),
					'tags'    => $tags,
				) );
			} else {
				$fi_id = $foo[0]->ID;
			}

			pf_star_item_for_user( $fi_id, get_current_user_id() );
			if ( rand( 0, 1 ) ) {
				echo 'deleted:'; var_dump( pf_unstar_item_for_user( $fi_id, get_current_user_id() ) );
			}

			echo 'starred: ';
			var_dump( pf_is_item_starred_for_user( $fi_id, get_current_user_id() ) );
			var_dump( $fi_id );
		}
	}
}
add_action( 'admin_init', 'pf_test_import' );
