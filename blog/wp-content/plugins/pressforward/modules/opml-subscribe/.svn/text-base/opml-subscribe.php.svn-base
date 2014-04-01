<?php 

/**
 * This module will allow you to subscribe to OPML files.
 * These subscriptions will populate your feedlist with new feeds
 * as they are added to the OPML file. 
 **/
 
class PF_OPML_Subscribe extends PF_Module {

	/**
	 * Constructor 
	 */
	public function __construct(){
		
		global $pf;
		$this->feed_type = 'opml';
		parent::start();
		
		add_action ('admin_init', array($this, 'register_settings'));
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
		require_once(PF_ROOT . "/includes/opml-reader/opml-reader.php");
	}

	/**
	 * Gets the data from an OPML file and turns it into a data object
	 * as expected by PF
	 * Prefers a post object, but can take a post ID. 
	 *
	 * @global $pf Used to access the feed_object() method
	 *
	 */	
	public function get_data_object($aOPML){
		set_time_limit(0);
		$feed_obj = new PF_Feeds_Schema();
		if (is_numeric($aOPML)){
			$aOPML = get_post($aOPML);
		}
		pf_log( 'Invoked: PF_OPML_Subscribe::get_data_object()' );
		$aOPML_url = $aOPML->guid;
		if(empty($aOPML_url) || is_wp_error($aOPML_url) || !$aOPML_url){
			$aOPML_id = $aOPML->ID;
			$aOPML_url - get_post_meta($aOPML_id, 'feedUrl', true);
		}
		pf_log( 'Getting OPML Feed at '.$aOPML_url );
		$OPML_reader = new OPML_reader;
		$opml_array = $OPML_reader->get_OPML_data($aOPML_url, false);		
		$c = 0;
		$opmlObject = array();
		foreach($opml_array as $feedObj){
			$id = md5($aOPML_url . '_opml_sub_for_' . $feedObj['xmlUrl']);
			#if ( false === ( $rssObject['opml_' . $c] = get_transient( 'pf_' . $id ) ) ) {
				# Adding this as a 'quick' type so that we can process the list quickly.
				if ($feedObj['type'] == 'rss'){ $feedObj['type'] = 'rss-quick'; }
				
				if(!empty($feedObj['text'])){
					$contentObj = new pf_htmlchecker($feedObj['text']);
					$feedObj['text'] = $contentObj->closetags($feedObj['text']);					
				}
				
				if(!empty($feedObj['title'])){
					$contentObj = new pf_htmlchecker($feedObj['title']);
					$feedObj['title'] = $contentObj->closetags($feedObj['title']);					
				}				
				
				if ($feedObj['title'] == ''){ $feedObj['title'] = $feedObj['text']; }
				$check = $feed_obj->create(
					$feedObj['xmlUrl'], 
					array(
						'type' => $feedObj['type'],
						'title' => $feedObj['title'],
						'htmlUrl' => $feedObj['htmlUrl'],
						'description' => $feedObj['text'],
						'type'		=>	'rss-quick'
					)
				);
				pf_log( 'Creating subscription to '.$feedObj['xmlUrl'].' from OPML Feed at '.$aOPML_url );
				#var_dump($check); die();
				$content = 'Subscribed: ' . $feedObj['title'] . ' - ' . $feedObj['type'] . ' - ' . $feedObj['text'];
				$source = $feedObj['htmlUrl'];
				if (empty($source)){ $source = $feedObj['xmlUrl']; }
				$opmlObject['opml_'.$c] = pf_feed_object(
										$feedObj['title'],
										'OPML Subscription ' . $aOPML_url,
										date('r'),
										'OPML Subscription',
										$content,
										$source,
										'',
										$id,
										date('r'),
										'' #tags
										);
				
				pf_log('Setting new transient for ' . $feedObj['xmlUrl'] . ' of ' . $source . '.');
				set_transient( 'pf_' . $id, $opmlObject['opml_' . $c], 60*10 );
				$c++;
			
			#}
		}

		return $opmlObject;
		
	}
	
	public function add_to_feeder(){
		
        settings_fields( PF_SLUG . '_opml_group' );
		$feedlist = get_option( PF_SLUG . '_opml_module' );	
        ?>
			<br />
			<br />
		<div><?php _e('Subscribe to OPML', 'pf'); ?></div>
			<div>
				<input id="<?php echo PF_SLUG . '_opml_sub[list]'; ?>" class="regular-text" type="text" name="<?php echo PF_SLUG . '_opml_sub[list]'; ?>" value="" />
                <label class="description" for="<?php echo PF_SLUG . '_opml_sub[list]'; ?>"><?php _e('*Complete URL for an OPML subscription', 'pf'); ?></label>


            </div>
		<?php
	}
	
	static function pf_opml_subscriber_validate($input){
		$feed_obj = new PF_Feeds_Schema();
		if (!empty($input['list'])){
			if (!(is_array($input['list']))){
				if (!$feed_obj->has_feed($input['list'])){
					$check = $feed_obj->create(
						(string)$input['list'], 
						array(
							'title' => 'OPML Subscription at ' . $input['list'],
							'htmlUrl' => $input['list'],
							'type' => 'opml', 
							'tags' => 'OPML Subscription',
							'module_added' => get_called_class()
						)
					);
					if (is_wp_error($check) || !$check){
						wp_die($check);
					}
					self::get_data_object(get_post($check));
				} else {
					$feed_obj->update_url($input['list']);
				}
			} else {
				wp_die('Bad feed input. Why are you trying to place an array?');
			}
		}
	}
	
	function register_settings(){
		register_setting(PF_SLUG . '_opml_group', PF_SLUG . '_opml_sub', array('PF_OPML_Subscribe', 'pf_opml_subscriber_validate'));
	}	
	
	

} 