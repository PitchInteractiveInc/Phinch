<?php

/**
 * Internal commenting module
 * Note: This borrows pretty strongly from the great work in the Edit Flow Editorial Comments module by batmoo. And by strongly, I mean almost entirely.
 * See http://editflow.org/features/editorial-comments/ for more info about Edit Flow Comments
 */

class PF_Comments extends PF_Module {

	// This is comment type used to differentiate editorial comments
	const comment_type = 'pressforward-comment';

	function __construct() {
		parent::start();

		add_action('pf_modal_comments', array($this, 'the_comment_box'));
		//add_action( 'admin_enqueue_scripts', array( $this, 'add_admin_scripts' ) );
		add_action( 'wp_ajax_editflow_ajax_insert_comment', array( $this, 'ajax_insert_comment' ) );
		add_action('pf_comment_action_button', array($this, 'show_comment_count_button'));
		add_action('pf_comment_action_modal', array($this, 'show_comment_modal'));
		add_filter('pf_setup_admin_rights', array($this, 'control_menu_access'));

	}

	/**
	 * Register the admin menu items
	 *
	 * The parent class will take care of registering them
	 */
	function setup_admin_menus( $admin_menus ) {
		$admin_menus   = array();

		$admin_menus[] = array(
			'page_title' => __( 'Internal Commenting', 'pf' ),
			'menu_title' => __( 'Internal Commenting', 'pf' ),
			'cap'        => 'manage_options',
			'slug'       => 'pf-comments',
			'callback'   => array( $this, 'admin_menu_callback' ),
		);

		parent::setup_admin_menus( $admin_menus );
	}

	function module_setup(){
		$mod_settings = array(
			'name' => 'Internal Commenting',
			'slug' => 'comments',
			'description' => 'This module provides a for users to comment on posts throughout the editorial process.',
			'thumbnail' => '',
			'options' => ''
		);

		update_option( PF_SLUG . '_' . $this->id . '_settings', $mod_settings );

		//return $test;
	}

	function get_editorial_comment_count( $id ) {
		global $wpdb;
		$comment_count = $wpdb->get_var($wpdb->prepare("SELECT COUNT(*) FROM $wpdb->comments WHERE comment_post_ID = %d AND comment_type = %s", $id, self::comment_type));
		if ( !$comment_count )
			$comment_count = 0;
		return $comment_count;
	}

	function show_comment_count_button($commentSet){
		$count = self::get_editorial_comment_count( $commentSet['id'] );
		//print_r($commentModalCall);
		$btnstate = "btn-small";
		$iconstate = "icon-comment";
		if ($count >= 1){ 
			$btnstate .= " btn-info";
			$iconstate .= " icon-white";
		}
		if ($commentSet['modal_state'] == false){
		
			echo '<a role="button" class="btn '.$btnstate.' itemCommentModal comments-expander" data-toggle="modal" href="#comment_modal_' . $commentSet['id'] . '" id="comments-expander-' . esc_attr( $commentSet['id'] ) . '" ><span class="comments-expander-count">' . $count . '</span><i class="'.$iconstate.'"></i></a>';

		} else {
			echo '<a role="button" class="btn btn-small itemCommentModal comments-expander active" >' . $count . '<i class="icon-comment"></i></a>';
		}
	}

	function control_menu_access($arrayedAdminRights){
		$arrayedAdminRights['pf_menu_comments_access'] = array(
															'default'=>'editor',
															'title'=>'Internal Commenting Menu'
														);
		$arrayedAdminRights['pf_feature_comments_access'] = array(
															'default'=>'editor',
															'title'=>'Internal Commenting Feature'
														);

		return $arrayedAdminRights;

	}

	function show_comment_modal($commentSet){
		//print_r($commentModalCall);
		if ($commentSet['modal_state'] == false){

		?>
			<div id="comment_modal_<?php  echo $commentSet['id']; ?>" class="modal fade comment-modal" tabindex="-1" role="dialog" aria-labelledby="comment_modal_<?php  echo $commentSet['id']; ?>_label" aria-hidden="true">
			  <div class="modal-header">
				<button type="button" class="close" data-dismiss="modal" aria-hidden="true">x</button>
				<h3 id="comment_modal_<?php  echo $commentSet['id']; ?>_label">Comments</h3>
			  </div>
			  <div class="modal-body">
				Loading comments...
			  </div>
			  <div class="modal-footer">
				<button class="btn" data-dismiss="modal" aria-hidden="true">Close</button>
			  </div>
			</div>
		<?php

		}
	}

	function the_comment_box($id_for_comments){

		//echo $id_for_comments;
		echo '<script>
		editorialCommentReply.init();
		</script>';
		$comments_allowed = get_option('pf_feature_comments_access', pf_get_defining_capability_by_role('editor'));

		if (!(current_user_can($comments_allowed))){

			_e('You do not have permission to access this area.');
			echo '<div class="clear"></div>';
			return;
		}
		?>
		<div id="ef-comments_wrapper">
			<a name="editorialcomments"></a>

			<?php
			// Show comments only if not a new post
//			if( ! in_array( $post->post_status, array( 'new', 'auto-draft' ) ) ) :

				// Unused since switched to wp_list_comments
				$editorial_comments = $this->ef_get_comments_plus (
								array(
									'post_id' => $id_for_comments,
									'comment_type' => self::comment_type,
									'orderby' => 'comment_date',
									'order' => 'ASC',
									'status' => self::comment_type
								)
							);
				?>

				<ul id="ef-comments">
					<?php
						// We use this so we can take advantage of threading and such

						wp_list_comments(
							array(
								'type' => self::comment_type,
								'callback' => array($this, 'the_comment'),
							),
							$editorial_comments
						);
					?>
				</ul>

				<?php $this->the_comment_form($id_for_comments); ?>

			<div class="clear"></div>
		</div>
		<div class="clear"></div>
		<?php

	}


	/**
	 * Displays the main commenting form
	 */
	function the_comment_form($id_for_comments) {
		//global $post;

		?>
		<a href="#" id="ef-comment_respond" onclick="editorialCommentReply.open();return false;" class="button-primary alignright hide-if-no-js" title=" <?php _e( 'Respond to this post', 'edit-flow' ); ?>"><span><?php _e( 'Respond to this Post', 'edit-flow' ); ?></span></a>

		<!-- Reply form, hidden until reply clicked by user -->
		<div id="ef-replyrow" style="display: none;">
			<div id="ef-replycontainer">
				<textarea id="ef-replycontent" name="replycontent" cols="40" rows="5"></textarea>
			</div>

			<p id="ef-replysubmit">
				<a class="ef-replysave button-primary alignright" href="#comments-form">
					<span id="ef-replybtn"><?php _e('Submit Response', 'edit-flow') ?></span>
				</a>
				<a class="ef-replycancel button-secondary alignright" href="#comments-form"><?php _e( 'Cancel', 'edit-flow' ); ?></a>
				<img alt="Sending comment..." src="<?php echo admin_url('/images/wpspin_light.gif') ?>" class="alignright" style="display: none;" id="ef-comment_loading" />
				<br class="clear" style="margin-bottom:35px;" />
				<span style="display: none;" class="error"></span>
			</p>

			<input type="hidden" value="" id="ef-comment_parent" name="ef-comment_parent" />
			<input type="hidden" name="ef-post_id" id="ef-post_id" value="<?php echo esc_attr( $id_for_comments ); ?>" />

			<?php wp_nonce_field('comment', 'ef_comment_nonce', false); ?>

			<br class="clear" />
		</div>

		<?php
	}


	/**
	 * Displays a single comment
	 */
	function the_comment($comment, $args, $depth) {
		global $current_user, $userdata;

		// Get current user
		get_currentuserinfo() ;

		$GLOBALS['comment'] = $comment;

		// Deleting editorial comments is not enabled for now for the sake of transparency. However, we could consider
		// EF comment edits (with history, if possible). P2 already allows for edits without history, so even that might work.
		// Pivotal ticket: https://www.pivotaltracker.com/story/show/18483757
		//$delete_url = esc_url( wp_nonce_url( "comment.php?action=deletecomment&p=$comment->comment_post_ID&c=$comment->comment_ID", "delete-comment_$comment->comment_ID" ) );

		$actions = array();

		$actions_string = '';
		$comments_allowed = get_option('pf_feature_comments_access', pf_get_defining_capability_by_role('editor'));
		// Comments can only be added by users that can edit the post
		if ( current_user_can($comments_allowed, $comment->comment_post_ID) ) {
			$actions['reply'] = '<a onclick="editorialCommentReply.open(\''.$comment->comment_ID.'\',\''.$comment->comment_post_ID.'\');return false;" class="vim-r hide-if-no-js" title="'.__( 'Reply to this comment', 'edit-flow' ).'" href="#">' . __( 'Reply', 'edit-flow' ) . '</a>';

			$sep = ' ';
			$i = 0;
			foreach ( $actions as $action => $link ) {
				++$i;
				// Reply and quickedit need a hide-if-no-js span
				if ( 'reply' == $action || 'quickedit' == $action )
					$action .= ' hide-if-no-js';

				$actions_string .= "<span class='$action'>$sep$link</span>";
			}
		}

	?>

		<li id="comment-<?php echo esc_attr( $comment->comment_ID ); ?>" <?php comment_class( array( 'comment-item', wp_get_comment_status($comment->comment_ID) ) ); ?>>

			<?php echo get_avatar( $comment->comment_author_email, 50 ); ?>

			<div class="post-comment-wrap">
				<h5 class="comment-meta">
					<?php printf( __('<span class="comment-author">%1$s</span><span class="meta"> said on %2$s at %3$s</span>', 'edit-flow'),
							comment_author_email_link( $comment->comment_author ),
							get_comment_date( get_option( 'date_format' ) ),
							get_comment_time() ); ?>
				</h5>

				<div class="comment-content"><?php comment_text(); ?></div>
				<p class="row-actions"><?php echo $actions_string; ?></p>

			</div>
		</li>
		<?php
	}

	/**
	 * Handles AJAX insert comment
	 */
	function ajax_insert_comment( ) {
		global $current_user, $user_ID, $wpdb;

		// Verify nonce
		if ( !wp_verify_nonce( $_POST['_nonce'], 'comment') )
			die( __( "Nonce check failed. Please ensure you're supposed to be adding editorial comments.", 'edit-flow' ) );

		// Get user info
      	get_currentuserinfo();
		$comments_allowed = get_option('pf_feature_comments_access', pf_get_defining_capability_by_role('editor'));
      	// Set up comment data
		$post_id = absint( $_POST['post_id'] );
		$parent = absint( $_POST['parent'] );

      	// Only allow the comment if user can edit post
      	// @TODO: allow contributers to add comments as well (?)
		if ( ! current_user_can( $comments_allowed, $post_id ) )
			die( __('Sorry, you don\'t have the privileges to add editorial comments. Please talk to your Administrator.', 'edit-flow' ) );

		// Verify that comment was actually entered
		$comment_content = trim($_POST['content']);
		if( !$comment_content )
			die( __( "Please enter a comment.", 'edit-flow' ) );

		// Check that we have a post_id and user logged in
		if( $post_id && $current_user ) {

			// set current time
			$time = current_time('mysql', $gmt = 0);

			// Set comment data
			$data = array(
			    'comment_post_ID' => (int) $post_id,
			    'comment_author' => esc_sql($current_user->display_name),
			    'comment_author_email' => esc_sql($current_user->user_email),
			    'comment_author_url' => esc_sql($current_user->user_url),
			    'comment_content' => wp_kses($comment_content, array('a' => array('href' => array(),'title' => array()),'b' => array(),'i' => array(),'strong' => array(),'em' => array(),'u' => array(),'del' => array(), 'blockquote' => array(), 'sub' => array(), 'sup' => array() )),
			    'comment_type' => self::comment_type,
			    'comment_parent' => (int) $parent,
			    'user_id' => (int) $user_ID,
			    'comment_author_IP' => esc_sql($_SERVER['REMOTE_ADDR']),
			    'comment_agent' => esc_sql($_SERVER['HTTP_USER_AGENT']),
			    'comment_date' => $time,
			    'comment_date_gmt' => $time,
				// Set to -1?
			    'comment_approved' => self::comment_type,
			);

			apply_filters( 'ef_pre_insert_editorial_comment', $data );

			// Insert Comment
			$comment_id = wp_insert_comment($data);
			$comment = get_comment($comment_id);

			// Register actions -- will be used to set up notifications and other modules can hook into this
			if ( $comment_id )
				do_action( 'ef_post_insert_editorial_comment', $comment );

			// Prepare response
			$response = new WP_Ajax_Response();

			ob_start();
				$this->the_comment( $comment, '', '' );
				$comment_list_item = ob_get_contents();
			ob_end_clean();

			$comment_count = self::get_editorial_comment_count( $post_id );

			$response->add( array(
				'what' => 'comment',
				'id' => $comment_id,
				'data' => $comment_list_item,
				'action' => ($parent) ? 'reply' : 'new',
				'supplemental' => array(
					'post_comment_count' => $comment_count,
					'post_id' => $post_id,
				),
			) );

			$response->send();

		} else {
			die( __('There was a problem of some sort. Try again or contact your administrator.', 'edit-flow') );
		}
	}



	function admin_menu_callback() {


		?>
		<div class="wrap">
			<h2>Internal Commenting Options</h2>
			<br /><br />
			<?php

			?>
		</div>
		<?php
	}

	function admin_enqueue_scripts() {
		global $pagenow;

		$hook = 0 != func_num_args() ? func_get_arg( 0 ) : '';

//		$post_type = $this->get_current_post_type();
//		$supported_post_types = array(pf_feed_item_post_type(), 'nomination'); //$this->get_post_types_for_module( $this->module );
//		if ( !in_array( $post_type, $supported_post_types ) )
//			return;
		if ( !in_array( $pagenow, array( 'admin.php' ) ) )
			return;

		if(!in_array($hook, array('pressforward_page_pf-review', 'toplevel_page_pf-menu', 'edit.php', 'post.php', 'post-new.php')) )
			return;

			//	print_r($hook);
		wp_enqueue_script( 'pressforward-internal-comments', PF_URL . 'modules/comments/assets/js/editorial-comments.js', array( 'jquery','post' ));

		$thread_comments = (int) get_option('thread_comments');
		?>
		<script type="text/javascript">
			var ef_thread_comments = <?php echo ($thread_comments) ? $thread_comments : 0; ?>;
		</script>
		<?php

	}

	/**
	 * If this module has any styles to enqueue, do it in a method
	 * If you have no styles, etc, just ignore this
	 */
	function admin_enqueue_styles() {
		wp_enqueue_style( PF_SLUG . '-internal-comments-css', PF_URL . 'modules/comments/assets/css/editorial-comments.css');
		//wp_register_style( PF_SLUG . '-commenting-style', PF_URL . 'includes/debugger/css/style.css' );
	}

	/**
	 * Retrieve a list of comments -- overloaded from get_comments and with mods by filosofo (SVN Ticket #10668)
	 *
	 * @param mixed $args Optional. Array or string of options to override defaults.
	 * @return array List of comments.
	 */
	function ef_get_comments_plus( $args = '' ) {
		global $wpdb;

		$defaults = array(
						'author_email' => '',
						'ID' => '',
						'karma' => '',
						'number' => '',
						'offset' => '',
						'orderby' => '',
						'order' => 'DESC',
						'parent' => '',
						'post_ID' => '',
						'post_id' => 0,
						'status' => '',
						'type' => '',
						'user_id' => '',
				);

		$args = wp_parse_args( $args, $defaults );
		extract( $args, EXTR_SKIP );

		// $args can be whatever, only use the args defined in defaults to compute the key
		$key = md5( serialize( compact(array_keys($defaults)) )  );
		$last_changed = wp_cache_get('last_changed', 'comment');
		if ( !$last_changed ) {
			$last_changed = time();
			wp_cache_set('last_changed', $last_changed, 'comment');
		}
		$cache_key = "get_comments:$key:$last_changed";

		if ( $cache = wp_cache_get( $cache_key, 'comment' ) ) {
			return $cache;
		}

		$post_id = absint($post_id);

		if ( 'hold' == $status )
			$approved = "comment_approved = '0'";
		elseif ( 'approve' == $status )
			$approved = "comment_approved = '1'";
		elseif ( 'spam' == $status )
			$approved = "comment_approved = 'spam'";
		elseif( ! empty( $status ) )
			$approved = $wpdb->prepare( "comment_approved = %s", $status );
		else
			$approved = "( comment_approved = '0' OR comment_approved = '1' )";

		$order = ( 'ASC' == $order ) ? 'ASC' : 'DESC';

		if ( ! empty( $orderby ) ) {
				$ordersby = is_array($orderby) ? $orderby : preg_split('/[,\s]/', $orderby);
				$ordersby = array_intersect(
						$ordersby,
						array(
								'comment_agent',
								'comment_approved',
								'comment_author',
								'comment_author_email',
								'comment_author_IP',
								'comment_author_url',
								'comment_content',
								'comment_date',
								'comment_date_gmt',
								'comment_ID',
								'comment_karma',
								'comment_parent',
								'comment_post_ID',
								'comment_type',
								'user_id',
						)
				);
				$orderby = empty( $ordersby ) ? 'comment_date_gmt' : implode(', ', $ordersby);
		} else {
				$orderby = 'comment_date_gmt';
		}

		$number = absint($number);
		$offset = absint($offset);

		if ( !empty($number) ) {
			if ( $offset )
				$number = 'LIMIT ' . $offset . ',' . $number;
			else
				$number = 'LIMIT ' . $number;

		} else {
			$number = '';
		}

		$post_where = '';

		if ( ! empty($post_id) )
			$post_where .= $wpdb->prepare( 'comment_post_ID = %d AND ', $post_id );
		if ( '' !== $author_email )
				$post_where .= $wpdb->prepare( 'comment_author_email = %s AND ', $author_email );
		if ( '' !== $karma )
				$post_where .= $wpdb->prepare( 'comment_karma = %d AND ', $karma );
		if ( 'comment' == $type )
				$post_where .= "comment_type = '' AND ";
		elseif ( ! empty( $type ) )
				$post_where .= $wpdb->prepare( 'comment_type = %s AND ', $type );
		if ( '' !== $parent )
				$post_where .= $wpdb->prepare( 'comment_parent = %d AND ', $parent );
		if ( '' !== $user_id )
				$post_where .= $wpdb->prepare( 'user_id = %d AND ', $user_id );

		$comments = $wpdb->get_results( "SELECT * FROM $wpdb->comments WHERE $post_where $approved ORDER BY $orderby $order $number" );
		wp_cache_add( $cache_key, $comments, 'comment' );

		return $comments;
	}

}
