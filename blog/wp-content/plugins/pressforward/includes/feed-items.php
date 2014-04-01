<?php

/**
 * Classes and functions for dealing with feed items
 */

/**
 * Database class for manipulating feed items
 */
class PF_Feed_Item {
	protected $filter_data = array();

	public function __construct() {
		add_action( 'pressforward_init', array( $this, 'init' ) );
	}

	public function init() {
		$this->post_type = pf_feed_item_post_type();
		$this->tag_taxonomy = pf_feed_item_tag_taxonomy();
	}

	public static function get( $args = array() ) {
		$wp_args = array(
			'post_type'        => $this->post_type,
			'post_status'      => 'publish',
			'suppress_filters' => false,
		);

		$query_filters = array();

		// WP_Query does not accept a 'guid' param, so we filter hackishly
		if ( isset( $args['url'] ) ) {
			$this->filter_data['guid'] = $args['url'];
			unset( $args['url'] );
			$query_filters['posts_where'][] = '_filter_where_guid';
		}

		foreach ( $query_filters as $hook => $filters ) {
			foreach ( $filters as $f ) {
				add_filter( $hook, array( $this, $f ) );
			}
		}

		// Other WP_Query args pass through
		$wp_args = wp_parse_args( $args, $wp_args );

		$posts = get_posts( $wp_args );

		foreach ( $query_filters as $hook => $filters ) {
			foreach ( $filters as $f ) {
				remove_filter( $hook, array( $this, $f ) );
			}
		}

		// Fetch some handy pf-specific data
		if ( ! empty( $posts ) ) {
			foreach ( $posts as &$post ) {
				$post->word_count = get_post_meta( $post->ID, 'pf_feed_item_word_count', true );
				$post->source     = get_post_meta( $post->ID, 'pf_feed_item_source', true );
				$post->tags       = wp_get_post_terms( $post->ID, $this->tag_taxonomy );
			}
		}

		return $posts;
	}

	public static function create( $args = array() ) {
		$r = wp_parse_args( $args, array(
			'item_title'   => '',
			'item_link'     => '',
			'item_content' => '',
			'source_title'  => '',
			'item_wp_date'    => '',
			'post_parent'    => '',
			'item_tags'    => array(),
		) );

		// Sanitization
		// Conversion should be done upstream
		if ( ! is_numeric( $r['item_wp_date'] ) ) {
			$r['item_wp_date'] = strtotime($r['item_wp_date']);
			if (!$r['item_wp_date']){
				return new WP_Error( 'Date should be in UNIX format' );
			}
		}



		$wp_args = array(
			'post_type'    => pf_feed_item_post_type(),
			'post_status'  => 'publish',
			'post_title'   => $r['item_title'],
			'post_content' => wp_specialchars_decode( $r['item_content'], ENT_COMPAT ), // todo
			'guid'         => $r['item_link'],
			'post_date'    => date( 'Y-m-d H:i:s', $r['item_wp_date'] ),
			'tax_input'    => array( pf_feed_item_tag_taxonomy() => $r['item_tags'] ),
			'post_parent'	=> $r['post_parent']
		);

		$post_id = wp_insert_post( $wp_args );

		if ( is_numeric($post_id) ) {
			self::set_word_count( $post_id, $r['item_content'] );
			self::set_source( $post_id, $r['source_title'] );

		}

		return $post_id;
	}

	public function _filter_where_guid( $where ) {
		global $wpdb;
		$where .= $wpdb->prepare( " AND {$wpdb->posts}.guid = %s ", $this->filter_data['guid'] );
		return $where;
	}

	// STATIC UTILITY METHODS

	public static function set_word_count( $post_id, $content = false ) {
		if ( false === $content ) {
			$post = get_post( $post_id );
			$content = $post->post_content;
		}

		$content_array = explode( ' ', strip_tags( $content ) );
		$word_count = count( $content_array );

		return update_post_meta( $post_id, 'pf_feed_item_word_count', $word_count );
	}

	public static function set_source( $post_id, $source ) {
		return update_post_meta( $post_id, 'pf_feed_item_source', $source );
	}

	# This function feeds items to our display feed function pf_reader_builder.
	# It is just taking our database of rssarchival items and putting them into a
	# format that the builder understands.
	public static function archive_feed_to_display($pageTop = 0, $pagefull = 20, $fromUnixTime = 0, $limitless = false, $limit = false) {
		global $wpdb, $post;
		#var_dump($fromUnixTime); die();
		if ( !isset($fromUnixTime) || (!$fromUnixTime) || ($fromUnixTime < 100)){$fromUnixTime = 0;}

		//$args = array(
		//				'post_type' => array('any')
		//			);
		//$pageBottom = $pageTop + 20;
		$args = pf_feed_item_post_type();

		//$archiveQuery = new WP_Query( $args );
		if ($limitless){
		 $dquerystr = $wpdb->prepare("
			SELECT {$wpdb->posts}.*, {$wpdb->postmeta}.*
			FROM {$wpdb->posts}, {$wpdb->postmeta}
			WHERE {$wpdb->posts}.ID = {$wpdb->postmeta}.post_id
			AND {$wpdb->posts}.post_type = %s
			AND {$wpdb->posts}.post_status = 'publish'
			AND {$wpdb->postmeta}.meta_key = 'sortable_item_date'
			AND {$wpdb->postmeta}.meta_value > {$fromUnixTime}
			ORDER BY {$wpdb->postmeta}.meta_value DESC
		 ", pf_feed_item_post_type());
		} elseif ($limit == 'starred') {
			$pageTop = $pageTop-1;
			$relate = new PF_RSS_Import_Relationship();
			$rt = $relate->table_name;
			$user_id = get_current_user_id();
			$read_id = pf_get_relationship_type_id('star');
			 $dquerystr = $wpdb->prepare("
				SELECT {$wpdb->posts}.*, {$wpdb->postmeta}.*
				FROM {$wpdb->posts}, {$wpdb->postmeta}
				WHERE {$wpdb->posts}.ID = {$wpdb->postmeta}.post_id
				AND {$wpdb->postmeta}.meta_key = 'sortable_item_date'
				AND {$wpdb->postmeta}.meta_value > {$fromUnixTime}
				AND {$wpdb->posts}.post_type = %s
				AND {$wpdb->posts}.post_status = 'publish'
				AND {$wpdb->posts}.ID
				IN (
					SELECT item_id
					FROM {$rt}
					WHERE {$rt}.user_id = {$user_id}
					AND {$rt}.relationship_type = {$read_id}
					AND {$rt}.value = 1
				)
				GROUP BY {$wpdb->postmeta}.meta_key
				ORDER BY {$wpdb->postmeta}.meta_value DESC
				LIMIT {$pagefull} OFFSET {$pageTop}
			 ", pf_feed_item_post_type());
		} elseif ($limit == 'nominated') {
			$pageTop = $pageTop-1;
			$relate = new PF_RSS_Import_Relationship();
			$rt = $relate->table_name;
			$user_id = get_current_user_id();
			$read_id = pf_get_relationship_type_id('nominate');
			 $dquerystr = $wpdb->prepare("
				SELECT {$wpdb->posts}.*, {$wpdb->postmeta}.*
				FROM {$wpdb->posts}, {$wpdb->postmeta}
				WHERE {$wpdb->posts}.ID = {$wpdb->postmeta}.post_id
				AND {$wpdb->postmeta}.meta_key = 'sortable_item_date'
				AND {$wpdb->postmeta}.meta_value > {$fromUnixTime}
				AND {$wpdb->posts}.post_type = %s
				AND {$wpdb->posts}.post_status = 'publish'
				AND {$wpdb->posts}.ID
				IN (
					SELECT item_id
					FROM {$rt}
					WHERE {$rt}.user_id = {$user_id}
					AND {$rt}.relationship_type = {$read_id}
					AND {$rt}.value = 1
				)
				GROUP BY {$wpdb->postmeta}.meta_key
				ORDER BY {$wpdb->postmeta}.meta_value DESC
				LIMIT {$pagefull} OFFSET {$pageTop}
			 ", pf_feed_item_post_type());
		} elseif (is_user_logged_in() && (isset($_GET['action']) && ('post' == $_GET['action']) &&(isset($_POST['search-terms'])))){
			$relate = new PF_RSS_Import_Relationship();
			$rt = $relate->table_name;
			$user_id = get_current_user_id();
			$read_id = pf_get_relationship_type_id('archive');
			$search = $_POST['search-terms'];
			 $dquerystr = $wpdb->prepare("
				SELECT {$wpdb->posts}.*, {$wpdb->postmeta}.*
				FROM {$wpdb->posts}, {$wpdb->postmeta}
				WHERE {$wpdb->posts}.ID = {$wpdb->postmeta}.post_id
				AND {$wpdb->postmeta}.meta_key = 'sortable_item_date'
				AND {$wpdb->postmeta}.meta_value > {$fromUnixTime}
				AND {$wpdb->posts}.post_type = %s
				AND {$wpdb->posts}.post_status = 'publish'			
				AND ((({$wpdb->posts}.post_title LIKE '%s') OR ({$wpdb->posts}.post_content LIKE '%s')))				
				AND {$wpdb->posts}.ID
				NOT
				IN (
					SELECT item_id
					FROM {$rt}
					WHERE {$rt}.user_id = {$user_id}
					AND {$rt}.relationship_type = {$read_id}
					AND {$rt}.value = 1
				)
				GROUP BY {$wpdb->posts}.ID
				ORDER BY {$wpdb->postmeta}.meta_value DESC
				LIMIT {$pagefull} OFFSET {$pageTop}
			 ", pf_feed_item_post_type(), '%'.$search.'%', '%'.$search.'%');
			 
			 #var_dump($dquerystr);

		} elseif (is_user_logged_in()){
			$relate = new PF_RSS_Import_Relationship();
			$rt = $relate->table_name;
			$user_id = get_current_user_id();
			$read_id = pf_get_relationship_type_id('archive');
			 $dquerystr = $wpdb->prepare("
				SELECT {$wpdb->posts}.*, {$wpdb->postmeta}.*
				FROM {$wpdb->posts}, {$wpdb->postmeta}
				WHERE {$wpdb->posts}.ID = {$wpdb->postmeta}.post_id
				AND {$wpdb->posts}.post_type = %s
				AND {$wpdb->posts}.post_status = 'publish'
				AND {$wpdb->postmeta}.meta_key = 'sortable_item_date'
				AND {$wpdb->postmeta}.meta_value > {$fromUnixTime}
				AND {$wpdb->posts}.ID
				NOT
				IN (
					SELECT item_id
					FROM {$rt}
					WHERE {$rt}.user_id = {$user_id}
					AND {$rt}.relationship_type = {$read_id}
					AND {$rt}.value = 1
				)
				ORDER BY {$wpdb->postmeta}.meta_value DESC
				LIMIT {$pageTop}, {$pagefull}
			 ", pf_feed_item_post_type());

		} else {
		 $dquerystr = $wpdb->prepare("
			SELECT {$wpdb->posts}.*, {$wpdb->postmeta}.*
			FROM {$wpdb->posts}, {$wpdb->postmeta}
			WHERE {$wpdb->posts}.ID = {$wpdb->postmeta}.post_id
			AND {$wpdb->posts}.post_type = %s
			AND {$wpdb->posts}.post_status = 'publish'
			AND {$wpdb->postmeta}.meta_key = 'sortable_item_date'
			AND {$wpdb->postmeta}.meta_value > {$fromUnixTime}
			ORDER BY {$wpdb->postmeta}.meta_value DESC
			LIMIT {$pageTop}, {$pagefull}
		 ", pf_feed_item_post_type());
		}
		// print_r($dquerystr);
		 # DESC here because we are sorting by UNIX datestamp, where larger is later.
		 //Provide an alternative to load by feed date order.
		# This is how we do a custom query, when WP_Query doesn't do what we want it to.
		$archivalposts = $wpdb->get_results($dquerystr, OBJECT);
		//print_r(count($rssarchivalposts)); die();
#		 var_dump($archivalposts);
		$feedObject = array();
		$c = 0;
		#var_dump($dquerystr);
		if ($archivalposts):

			foreach ($archivalposts as $post) :
			# This takes the $post objects and translates them into something I can do the standard WP functions on.
			setup_postdata($post);
			# I need this data to check against existing transients.
			$post_id = get_the_ID();
			$id = get_post_meta($post_id, 'item_id', true); //die();
			//Switch the delete on to wipe rss archive posts from the database for testing.
			//wp_delete_post( $post_id, true );
			//print_r($id);
			# If the transient exists than there is no reason to do any extra work.
			if ( false === ( $feedObject['rss_archive_' . $c] = get_transient( 'pf_archive_' . $id ) ) ) {

				$item_id = get_post_meta($post_id, 'item_id', true);
				$source_title = get_post_meta($post_id, 'source_title', true);
				$item_date = get_post_meta($post_id, 'item_date', true);
				$item_author = get_post_meta($post_id, 'item_author', true);
				$item_link = get_post_meta($post_id, 'item_link', true);
				$item_feat_img = get_post_meta($post_id, 'item_feat_img', true);
				$item_wp_date = get_post_meta($post_id, 'item_wp_date', true);
				$item_tags = get_post_meta($post_id, 'item_tags', true);
				$source_repeat = get_post_meta($post_id, 'source_repeat', true);
				$readable_status = get_post_meta($post_id, 'readable_status', true);
				$contentObj = new pf_htmlchecker(get_the_content());
				$item_content = $contentObj->closetags(get_the_content());

				$feedObject['rss_archive_' . $c] = pf_feed_object(
											get_the_title(),
											$source_title,
											$item_date,
											$item_author,
											$item_content,
											$item_link,
											$item_feat_img,
											$item_id,
											$item_wp_date,
											$item_tags,
											//Manual ISO 8601 date for pre-PHP5 systems.
											get_the_date('o-m-d\TH:i:sO'),
											$source_repeat,
											$post_id,
											$readable_status
											);
				set_transient( 'pf_archive_' . $id, $feedObject['rss_archive_' . $c], 60*10 );

			}
			$c++;
			endforeach;


		endif;
		wp_reset_postdata();
		return $feedObject;
	}

	#via http://wordpress.stackexchange.com/questions/109793/delete-associated-media-upon-page-deletion
	public static function disassemble_feed_item_media( $post_id ) {

		$attachments = get_posts( array(
			'post_type'      => 'attachment',
			'posts_per_page' => -1,
			'post_status'    => 'any',
			'post_parent'    => $post_id
		) );

		foreach ( $attachments as $attachment ) {
			if ( false === wp_delete_attachment( $attachment->ID ) ) {
				pf_log('Failed to delete attachment for '.$post_id);
			}
		}
	}


	# The function we add to the action to clean our database.
	public static function disassemble_feed_items() {
		//delete rss feed items with a date past a certain point.
		add_filter( 'posts_where', array( 'PF_Feed_Item', 'filter_where_older_sixty_days') );
		$queryForDel = new WP_Query( array( 'post_type' => pf_feed_item_post_type() ) );
		remove_filter( 'posts_where', array( 'PF_Feed_Item', 'filter_where_older_sixty_days') );

		// The Loop
		while ( $queryForDel->have_posts() ) : $queryForDel->the_post();
			# All the posts in this loop are older than 60 days from 'now'.
			# Delete them all.
			$postid = get_the_ID();
			wp_delete_post( $postid, true );

		endwhile;

		// Reset Post Data
		wp_reset_postdata();

	}

	# Method to manually delete rssarchival entries on user action.
	public static function reset_feed() {
		global $wpdb, $post;
		//$args = array(
		//				'post_type' => array('any')
		//			);
		$args = 'post_type=' . pf_feed_item_post_type();
		//$archiveQuery = new WP_Query( $args );
		$dquerystr = $wpdb->prepare("
			SELECT $wpdb->posts.*, $wpdb->postmeta.*
			FROM $wpdb->posts, $wpdb->postmeta
			WHERE $wpdb->posts.ID = $wpdb->postmeta.post_id
			AND $wpdb->posts.post_type = %s
		 ", pf_feed_item_post_type() );
		# This is how we do a custom query, when WP_Query doesn't do what we want it to.
		$rssarchivalposts = $wpdb->get_results($dquerystr, OBJECT);
		//print_r(count($rssarchivalposts)); die();
		$feedObject = array();
		$c = 0;

		if ($rssarchivalposts):

			foreach ($rssarchivalposts as $post) :
			# This takes the $post objects and translates them into something I can do the standard WP functions on.
			setup_postdata($post);
			$post_id = get_the_ID();
			//Switch the delete on to wipe rss archive posts from the database for testing.
			wp_delete_post( $post_id, true );
			endforeach;


		endif;
		wp_reset_postdata();
		print_r(__('All archives deleted.', 'pf'));

	}

	public static function get_the_feed_object(){
		pf_log( 'Invoked: PF_Feed_Item::get_the_feed_object()' );
		#$PF_Feed_Retrieve = new PF_Feed_Retrieve();
		# This pulls the RSS feed into a set of predetermined objects.
		# The rss_object function takes care of all the feed pulling and item arraying so we can just do stuff with the feed output.
		$theFeed = pressforward()->pf_retrieve->step_through_feedlist();
		if ((!$theFeed) || is_wp_error($theFeed)){
			pf_log('The feed is false, exit process. [THIS SHOULD NOT OCCUR except at the conclusion of feeds retrieval.]');
			# Wipe the checking option for use next time.
			update_option(PF_SLUG . '_feeds_meta_state', array());
			$chunk_state = update_option( PF_SLUG . '_ready_to_chunk', 1 );
			exit;
		}

		return $theFeed;
	}

	public static function assemble_feed_for_pull($feedObj = 0) {
		pf_log( 'Invoked: PF_Feed_Item::assemble_feed_for_pull()' );

		ignore_user_abort(true);
		set_time_limit(0);
		# Chunking control, the goal here is to ensure that no feed assembly occurs while the feed assembly is already occuring.
		# Option: If true (1), the system is ready to assemble a chunk. If false (0), the system is already assembling a chunk.
		$ready_for_chunk_assembly = get_option( PF_SLUG . '_ready_to_chunk', 1);

		if ( $ready_for_chunk_assembly === 0 ){
			pf_log( 'Chunk already in progress.' );
			return;
		} else {
			pf_log( 'Beginning next import chunk.' );
			pf_log( 'The chunk state is set?' );
			$chunk_state = update_option( PF_SLUG . '_ready_to_chunk', 0 );
			pf_log( $chunk_state );
		}

		if ($feedObj == 0){
			$theFeed = self::get_the_feed_object();
			$feedObj = $theFeed;
		}

		# We need to init $sourceRepeat so it can be if 0 if nothing is happening.
		$sourceRepeat = 0;
		# We'll need this for our fancy query.
		global $wpdb;
		# Since rss_object places all the feed items into an array of arrays whose structure is standardized throughout,
		# We can do stuff with it, using the same structure of items as we do everywhere else.
		pf_log('Now beginning check and processing for entering items into the database.');
		$parent = $feedObj['parent_feed_id'];
		unset($feedObj['parent_feed_id']);
		foreach($feedObj as $item) {
			$thepostscheck = 0;
			$thePostsDoubleCheck = 0;
			$item_id 		= $item['item_id'];
			$sourceRepeat = 0;
			//$queryForCheck = new WP_Query( array( 'post_type' => 'rssarchival', 'meta_key' => 'item_id', 'meta_value' => $item_id ) );
			 # Originally this query tried to get every archive post earlier than 'now' to check.
			 # But it occured to me that, since I'm doing a custom query anyway, I could just query for items with the ID I want.
			 # Less query results, less time.

			 //Perhaps I should do this outside of the foreach? One query and search it for each item_id and then return those not in?
			 $querystr = $wpdb->prepare("
				SELECT {$wpdb->posts}.*, {$wpdb->postmeta}.*
				FROM {$wpdb->posts}, {$wpdb->postmeta}
				WHERE {$wpdb->posts}.ID = {$wpdb->postmeta}.post_id
				AND {$wpdb->postmeta}.meta_key = 'item_id'
				AND {$wpdb->postmeta}.meta_value = %s
				AND {$wpdb->posts}.post_type = %s
				ORDER BY {$wpdb->posts}.post_date DESC
			 ", $item_id, pf_feed_item_post_type() );
			 // AND $wpdb->posts.post_date < NOW() <- perhaps by removing we can better prevent simultaneous duplications?
			 # Since I've altered the query, I could change this to just see if there are any items in the query results
			 # and check based on that. But I haven't yet.
			$checkposts = $wpdb->get_results($querystr, OBJECT);
			//print_r($checkposts);
				if ($checkposts):
					global $post;
					foreach ($checkposts as $post):
						setup_postdata($post);
						//print_r(get_the_ID());
						//print_r('< the ID');
						if ((get_post_meta($post->ID, 'item_id', $item_id, true)) === $item_id){
							$thepostscheck++;
							pf_log('We already have post ' . $item_id);
						}

					endforeach;
				endif;
				wp_reset_query();
				if ($thepostscheck === 0){
					$queryMoreStr = $wpdb->prepare("
						SELECT {$wpdb->posts}.*, {$wpdb->postmeta}.*
						FROM {$wpdb->posts}, {$wpdb->postmeta}
						WHERE {$wpdb->posts}.ID = {$wpdb->postmeta}.post_id
						AND {$wpdb->postmeta}.meta_key = 'item_link'
						AND {$wpdb->postmeta}.meta_value = %s
						AND {$wpdb->posts}.post_type = %s
						ORDER BY {$wpdb->posts}.post_date DESC
					 ", $item['item_link'], pf_feed_item_post_type());
					$checkpoststwo = $wpdb->get_results($queryMoreStr, OBJECT);
					if ($checkpoststwo):
						pf_log('Check for posts with the same link.');
						foreach ($checkpoststwo as $post):
							setup_postdata($post);

								# Post comparative values.
								$theTitle = $post->post_title;
								$postID = $post->ID;

								$postDate = strtotime($post->post_date);
								$postItemLink = get_post_meta($post->ID, 'item_link', true);
								# Item comparative values.
								$itemDate = strtotime($item['item_date']);
								$itemTitle = $item['item_title'];
								$itemLink = $item['item_link'];

								# First check if it more recent than the currently stored item.
								if((($theTitle == $itemTitle) || ($postItemLink == $itemLink))){
									$thePostsDoubleCheck++;
									pf_log('We already have the post ' . $theTitle . ' with the link ' . $itemLink);
									$sourceRepeat = get_post_meta($postID, 'source_repeat', true);
									if (($itemDate > $postDate)) {
										# If it is more recent, than this is the new dominant post.
										$sourceRepeat++;
									} elseif (($itemDate <= $postDate)) {
										# if it is less recent, then we need to increment the source count.
										$sourceRepeat++;
										if ($thePostsDoubleCheck > $sourceRepeat) {
											update_post_meta($postID, 'source_repeat', $sourceRepeat);
										}
										$thepostscheck++;
									} else {
										$thepostscheck = 0;
									}
								} else {
									# If it isn't duplicated at all, then we need to give it a source repeat count of 0
									$sourceRepeat = 0;
								}


						endforeach;
					endif;
				}
				wp_reset_query();
			# Why an increment here instead of a bool?
			# If I start getting errors, I can use this to check how many times an item is in the database.
			# Potentially I could even use this to clean the database from duplicates that might occur if
			# someone were to hit the refresh button at the same time as another person.


#			$fo = fopen(PF_ROOT . "/modules/rss-import/rss-import.txt", 'a') or print_r('Can\'t open log file.');
#			if ($fo != false){
#				fwrite($fo, "\nSending " . $item['item_title'] . " to post table.");
#				fclose($fo);
#			}
			if ( $thepostscheck === 0) {
				$item_title 	= $item['item_title'];
				$item_content 	= $item['item_content'];
				$item_feat_img 	= $item['item_feat_img'];
				$source_title 	= $item['source_title'];
				$item_date 		= $item['item_date'];
				$item_author 	= $item['item_author'];
				$item_link 		= $item['item_link'];
				$item_wp_date	= $item['item_wp_date'];
				$item_tags		= $item['item_tags'];
				if (!isset($item['parent_feed_id']) || !$item['parent_feed_id']){
					$item['parent_feed_id'] = $parent;
				}
				$feed_obj_id	= $item['parent_feed_id'];
				$source_repeat  = $sourceRepeat;

				# Trying to prevent bad or malformed HTML from entering the database.
				$item_title = strip_tags($item_title);
				$item_content = strip_tags($item_content, '<p> <strong> <bold> <i> <em> <emphasis> <del> <h1> <h2> <h3> <h4> <h5> <a> <img>');
				# Need to get rid of some weird characters that prevent inserting posts into the database.
				# From: http://www.alexpoole.name/web-development/282/remove-smart-quotes-bullets-dashes-and-other-junky-characters-from-a-string-with-php
				# And: http://www.enghiong.com/wp_insert_post-could-not-insert-post-into-the-database.html
				//$item_content = self::extra_special_sanatize($item_content);
				//$item_title = self::extra_special_sanatize($item_title);

				//$item_content = wpautop($item_content);
				//$postcontent = sanitize_post($item_content);
				//If we use the @ to prevent showing errors, everything seems to work. But it is still dedicating crap to the database...
				//Perhaps sanitize_post isn't the cause? What is then?

				# Do we want or need the post_status to be published?
				$data = array(
					'post_status' => 'publish',
					'post_type' => pf_feed_item_post_type(),
				//	'post_date' => $_SESSION['cal_startdate'],
					'item_title' => $item_title,
					'post_parent'    => $feed_obj_id,
					'item_content' => $item_content,
					'item_link'	=> $item_link,
					'source_title' => $source_title,
					'item_wp_date' => $item_wp_date,
					'item_tags'	=> $item_tags

				);

				//RIGHT HERE is where the content is getting assigned a bunch of screwed up tags.
				//The content is coming in from the rss_object assembler a-ok. But something here saves them to the database screwy.
				//It looks like sanitize post is screwing them up terribly. But what to do about it without removing the security measures which we need to apply?
				$worked = 1;
				# The post gets created here, the $newNomID variable contains the new post's ID.
				$newNomID = self::create( $data );
				$post_inserted_bool = self::post_inserted($newNomID, $data);

				if (!$post_inserted_bool) {
					# It's the end of the world! Let's throw everything at this.
					pf_log('Post will not go into the database. We will try again.');
					$item_content = htmlentities(strip_tags($item_content), ENT_QUOTES, "UTF-8");
					$item_content = wp_kses(stripslashes($item_content), array('p', 'a', 'b', 'em', 'strong'));
					$item_content = self::extra_special_sanatize($item_content, true);
					$item_content = wpautop($item_content);
					$item_title = self::extra_special_sanatize($item_title, true);
					$data['item_content'] = $item_content;
					$newNomID = self::create( $data );
					$post_inserted_bool = self::post_inserted($newNomID, $data);
				}
				pf_log('End of wp_insert_post process.');
				//$posttest = get_post($newNomID);
				//print_r($posttest->post_content);

				# Somewhere in the process links with complex queries at the end (joined by ampersands) are getting encoded.
				# I don't want that, so I turn it back here.
				# For some reason this is only happening to the ampersands, so that's the only thing I'm changing.
				$item_link = str_replace('&amp;','&', $item_link);

				# If it doesn't have a featured image assigned already, I use the set_ext_as_featured function to try and find one.
				# It also, if it finds one, sets it as the featured image for that post.

				if ( ! empty( $_POST['item_feat_img'] ) ){
					# Turned off set_ext_as_featured here, as that should only occur when items are nominated.
					# Before nominations, the featured image should remain a meta field with an external link.
					if ( false === ( $itemFeatImg = get_transient( 'feed_img_' . $itemUID ) ) ) {
						set_time_limit(0);
						# Because many systems can't process https through php, we try and remove it.
						$itemLink = pf_de_https($itemLink);
						# if it forces the issue when we try and get the image, there's nothing we can do.
						$itemLink = str_replace('&amp;','&', $itemLink);
						if (pressforward()->og_reader->fetch($itemLink)){
							//If there is no featured image passed, let's try and grab the opengraph image.
							$node = pressforward()->og_reader->fetch($itemLink);
							$itemFeatImg = $node->image;

						}

						if ($itemFeatImg == ''){
							//Thinking of starting a method here to pull the first image from the body of a post.
							//http://stackoverflow.com/questions/138313/how-to-extract-img-src-title-and-alt-from-html-using-php
							//http://stackoverflow.com/questions/1513418/get-all-images-url-from-string
							//http://stackoverflow.com/questions/7479835/getting-the-first-image-in-string-with-php
							//preg_match_all('/<img[^>]+>/i',$itemContent, $imgResult);
							//$imgScript = $imgResult[0][0];
						}
						//Most RSS feed readers don't store the image locally. Should we?
						set_transient( 'feed_img_' . $itemUID, $itemFeatImg, 60*60*24 );
					}
				}

				# adding the meta info about the feed item to the post's meta.
				$pf_meta_args = array(
					pf_meta_for_entry('item_id', $item_id),
					pf_meta_for_entry('source_title', $source_title),
					pf_meta_for_entry('item_date', $item_date),
					pf_meta_for_entry('item_author', $item_author),
					pf_meta_for_entry('item_link', $item_link),
					pf_meta_for_entry('item_feat_img', $item_feat_img),
					// The item_wp_date allows us to sort the items with a query.
					pf_meta_for_entry('item_wp_date', $item_wp_date),
					//We can't just sort by the time the item came into the system (for when mult items come into the system at once)
					//So we need to create a machine sortable date for use in the later query.
					pf_meta_for_entry('sortable_item_date', strtotime($item_date)),
					pf_meta_for_entry('item_tags', $item_tags),
					pf_meta_for_entry('source_repeat', $source_repeat),
					pf_meta_for_entry('revertible_feed_text', $item_content)

				);
				pf_meta_establish_post($newNomID, $pf_meta_args);
			}

		}
		update_option( PF_SLUG . '_ready_to_chunk', 1 );
		#$Feed_Retrieve = new PF_Feed_Retrieve();
		pressforward()->pf_retrieve->advance_feeds();
		//die('Refreshing...');

	}

	public static function post_inserted($postAttempt, $data){
			$worked = 1;
			$workedBool = true;
				if ($postAttempt === 0) {
					pf_log('The following post did not go into the database correctly.');
					pf_log($data);
					$worked = 0;
				} elseif (is_wp_error($postAttempt)) {
					pf_log('Attempting to add ' . $data['item_title'] . ' to the database caused this error:' );
					pf_log($postAttempt);
					pf_log('The following post caused the above error.');
					pf_log($data);
					$worked = 0;
				} else {
					pf_log('Create post in the database with the title ' . $data['item_title'] . ' and id of ');
					pf_log($postAttempt);
				}
		if ($worked === 0){ $workedBool = false; }
		return $workedBool;
	}

	# Alternate function title - 'stop_pasting_junk_from_word'
	public function extra_special_sanatize($string, $severe = false){

		$search = array(chr(145),
						chr(146),
						chr(147),
						chr(148),
						chr(151),
						chr(150),
						chr (133),
						chr(149),
						chr(189)
						);
		$replace = array("'",
						"'",
						'"',
						'"',
						'--',
						'-',
						'...',
						"&bull;",
						"1/2",
						);
		$string = str_replace($search, $replace, $string);
		pf_log('String run through specified str_replace.');
		$string = utf8_encode($string);
		pf_log('String run through utf8_encode');
		pf_log('String returned.');
		if ($severe) {
			// ============
			// Remove MS Word Special Characters
			// From: https://gist.github.com/gcoop/701814
			// ============

				$search  = array('&acirc;€“','&acirc;€œ','&acirc;€˜','&acirc;€™','&Acirc;&pound;','&Acirc;&not;','&acirc;„&cent;', '&Acirc;&nbsp;', '&Acirc;', '&amp;nbsp;', '&#8230;');
				$replace = array('-','&ldquo;','&lsquo;','&rsquo;','&pound;','&not;','&#8482;', '', '', '', '...');

				$string = str_replace($search, $replace, $string);
				$string = str_replace('&acirc;€', '&rdquo;', $string);

				$search = array("&#39;", "\xc3\xa2\xc2\x80\xc2\x99", "\xc3\xa2\xc2\x80\xc2\x93", "\xc3\xa2\xc2\x80\xc2\x9d", "\xc3\xa2\x3f\x3f", "&#8220;", "&#8221;", "#8217;", "&not;", "&#8482;");
				$resplace = array("'", "'", ' - ', '"', "'", '"', '"', "'", "-", "(TM)");

				$string = str_replace($search, $replace, $string);

			$quotes = array(
				"\xC2\xAB"     => '"',
				"\xC2\xBB"     => '"',
				"\xE2\x80\x98" => "'",
				"\xE2\x80\x99" => "'",
				"\xE2\x80\x9A" => "'",
				"\xE2\x80\x9B" => "'",
				"\xE2\x80\x9C" => '"',
				"\xE2\x80\x9D" => '"',
				"\xE2\x80\x9E" => '"',
				"\xE2\x80\x9F" => '"',
				"\xE2\x80\xB9" => "'",
				"\xE2\x80\xBA" => "'",
				"\xe2\x80\x93" => "-",
				"\xc2\xb0"	   => "°",
				"\xc2\xba"     => "°",
				"\xc3\xb1"	   => "&#241;",
				"\x96"		   => "&#241;",
				"\xe2\x81\x83" => '&bull;',
				"\xd5" => "'"
			);

			$string = strtr($string, $quotes);
			$string = utf8_encode($string);
			# From: http://stackoverflow.com/questions/657643/how-to-remove-html-special-chars
			//$string = preg_replace("/&#?[a-z0-9]+;/i","", $string);

		}


		return $string;
	}


	/**
	 * Get the content of a URL, using various fallbacks
	 */
	public static function get_content_through_aggregator($url){

		set_time_limit(0);
		//$this->set_error_handler("customError");
		$url = pf_de_https($url);
		$descrip = '';
		//$url = http_build_url($urlParts, HTTP_URL_STRIP_AUTH | HTTP_URL_JOIN_PATH | HTTP_URL_JOIN_QUERY | HTTP_URL_STRIP_FRAGMENT);
		//print_r($url);
		# First run it through Readability.
		$descrip = pressforward()->readability->readability_object($url);
		//print_r($url);
		# If that doesn't work...
		if (!$descrip) {
			$url = str_replace('&amp;','&', $url);
			#Try and get the OpenGraph description.
			if (pressforward()->og_reader->fetch($url)){
				$node = pressforward()->og_reader->fetch($url);
				$descrip = $node->description;
			} //Note the @ below. This is because get_meta_tags doesn't have a failure state to check, it just throws errors. Thanks PHP...
			elseif ('' != ($contentHtml = @get_meta_tags($url))) {
				# Try and get the HEAD > META DESCRIPTION tag.
				$descrip = $contentHtml['description'];
				print_r($url . ' has no meta OpenGraph description we can find.');

			}
			else
			{
				# Ugh... we can't get anything huh?
				print_r($url . ' has no description we can find.');
				# We'll want to return a false to loop with.
				$descrip = false;

				break;
			}
		}
		return $descrip;

	}

	public static function get_ext_og_img($link){
		$itemLink = pf_de_https($link);
		$node = pressforward()->og_reader->fetch($itemLink);
		$itemFeatImg = $node->image;
		return $itemFeatImg;
	}

	public static function set_ext_as_featured($postID,$ogImage){

		if ( (strlen($ogImage)) > 1 ){

				//Remove Queries from the URL
				$ogImage = preg_replace('/\?.*/', '', $ogImage);

				$imgParts = pathinfo($ogImage);
				$imgExt = $imgParts['extension'];
				$imgTitle = $imgParts['filename'];

				if ($imgExt != ('jpg'||'png'||'jrpg'||'bmp'||'gif')){
					//print_r('bad og img');
					return;
				}


				//'/' . get_option(upload_path, 'wp-content/uploads') . '/' . date("o")
				$uploadDir = wp_upload_dir();
				$ogCacheImg = $uploadDir['path'] . $postID . "-" . $imgTitle . "." . $imgExt;

				if ( !file_exists($ogCacheImg) ) {


					$result  = copy($ogImage, $ogCacheImg);


				}
		}

		//Methods within sourced from http://codex.wordpress.org/Function_Reference/wp_insert_attachment
		//and http://wordpress.stackexchange.com/questions/26138/set-post-thumbnail-with-php

		//Get the type of the image file. .jpg, .gif, or whatever
		$filetype = wp_check_filetype( $ogCacheImg );

		//Set the identifying variables for the about to be featured image.
		$imgData = array(
						//tell WordPress what the filetype is.
						'post_mime_type' => $filetype['type'],
						//set the image title to the title of the site you are pulling from
						'post_title' => get_the_title($postID),
						//WordPress tells us we must set this and set it to empty. Why? Dunno.
						'post_content' => $imgTitle,
						//Now we set the status of the image. It will inheret that of the post.
						//If the post is published, then the image will be to.
						'post_status' => 'inherit'
					);
		//WordPress needs an absolute path to the image, as opposed to the relative path we used before.
		//I'm hoping that by using the upload_dir function (above) I can make this function work with multisite.
		//$pathedImg = $uploadDir['url'] . $img;
		//Now we insert the image as a WordPress attachement, and associate it with the current post.
		$thumbid = wp_insert_attachment($imgData, $ogCacheImg, $postID);

		//To set a thumbnail, you need metadata associated with an image.
		//To get that we need to call the image.php file
		require_once(ABSPATH . 'wp-admin/includes/image.php');
		$metadata = wp_generate_attachment_metadata( $thumbid, $ogCacheImg );
		//Now we attach the meta data to the image.
		wp_update_attachment_metadata( $thumbid, $metadata );

		//Now that we have a correctly meta-ed and attached image we can finally turn it into a post thumbnail.
		update_post_meta($postID, '_thumbnail_id', $thumbid);


	}



	/**
	 * Filter 'posts_where' to return only posts older than sixty days
	 */
	public static function filter_where_older_sixty_days( $where = '' ) {
		// posts before the last 60 days
		$where .= " AND post_date < '" . date('Y-m-d', strtotime('-60 days')) . "'";
		return $where;
	}

	/**
	 * Set a feed item's tags
	 *
	 * @param int $post_id
	 * @param array $tags
	 * @param bool $append True if you want to append rather than replace
	 */
	public static function set_tags( $post_id, $tags, $append = false ) {
		return wp_set_object_terms( $post_id, $tags, $this->tag_taxonomy, $append );
	}

	/**
	 * Get the source data object, in a standardized format
	 *
	 * For the moment, all this data comes from the RSS_Import module. In
	 * the future, other modules can hook in to provide their own data
	 * sources.
	 */
	public function source_data_object() {
		// Loop through each module to get its source data
		$source_data_object = array();
		foreach ( pressforward()->modules as $module ) {
			$source_data_object = array_merge( $source_data_object, $module->get_data_object() );
		}
		return $source_data_object;
	}

	/**
	 * Converts a raw tag array to a list appropriate for a tax_query
	 *
	 * Will create the necessary tags if they're not found
	 */
	public static function convert_raw_tags( $tags ) {
		$retval = array( $this->tag_taxonomy => $tags );
		return $retval;
	}

	public static function get_term_slug_from_tag( $tag ) {
//		return 'pf_feed_item_' .
	}
}
