<?php

/**
 * Test of module base class
 */

class PF_Debugger extends PF_Module {
	function __construct() {
		parent::start();
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
			'page_title' => __( 'View Log', 'pf' ),
			'menu_title' => __( 'View Log', 'pf' ),
			'cap'        => get_option('pf_menu_log_access', pf_get_defining_capability_by_role('administrator')),
			'slug'       => 'pf-debugger',
			'callback'   => array( $this, 'admin_menu_callback' ),
		);

		parent::setup_admin_menus( $admin_menus );
	}

	function setup_module() {
		$enabled = get_option( 'pf_debugger_enable' );
		if ( ! in_array( $enabled, array( 'yes', 'no' ) ) ) {
			$enabled = 'yes';
		}

		$mod_settings = array(
			'name' => 'Debugger Log Viewing Module',
			'slug' => 'debugger',
			'options' => ''
		);

		//update_option( 'pf_foo_settings', $mod_settings );


	}

	function module_setup(){
		$mod_settings = array(
			'name' => 'Debugger Log Viewing Module',
			'slug' => 'debugger',
			'description' => 'This module provides a way to view the feed retrieval log within the dashboard.',
			'thumbnail' => '',
			'options' => ''
		);

		update_option( PF_SLUG . '_' . $this->id . '_settings', $mod_settings );

		//return $test;
	}
	
	function count_the_posts($post_type, $date_less = false){
				
				if (!$date_less){
					$y = date('Y');
					$m = date('m');
				} elseif (!empty($date_less) && $date_less < 12) {
					$y = date('Y');
					$m = date('m');
					$m = $m + $date_less;
				} elseif (!empty($date_less) && $date_less >= 12) {
					$y = date('Y');
					$y = $y - floor($date_less/12);
					$m = date('m');
					$m = $m - (abs($date_less)-(12*floor($date_less/12)));
				}
				
				$query_arg = array(
					'post_type' 		=> $post_type,
					'year'				=> $y,
					'monthnum'			=> $m,
					'posts_per_page' 	=> -1
				);
				$query = new WP_Query($query_arg);	
		
		return $query->post_count;
	}

	function admin_menu_callback() {
		global $wpdb;
		// Default log location is in the uploads directory
		if ( ! defined( 'PF_DEBUG_LOG' ) ) {
			$upload_dir = wp_upload_dir();
			$log_path = $upload_dir['basedir'] . '/pressforward.log';
		} else {
			$log_path = PF_DEBUG_LOG;
		}
		
		$action_count = $wpdb->get_results( $wpdb->prepare( "SELECT COUNT(*) FROM {$wpdb->prefix}pf_relationships", ''), ARRAY_A );		
		
		$ntp_args = array( 'posts_per_page' => -1, 'meta_key' => 'item_link');
		
		$nominated_to_posts = get_posts($ntp_args);
		$nomed_posts = count($nominated_to_posts);
		
		?>
		<div class="wrap">
			<h2>Current Log</h2>
			<?php 

				#var_dump($feed_items_query->post_count);
			
			?>
			<p>Does not update in real time.</p>
			<p>Total Current Feed Items: 
			<?php 
				$feed_item = 'pf_feed_item';
				echo wp_count_posts($feed_item)->publish;
				#var_dump(wp_count_posts($feed_item));
				#var_dump(wp_count_posts('post'));
			?><br />
			<?php 
				$feed_item = 'pf_feed_item';
				echo 'Month to date Feed Items: ' . $this->count_the_posts($feed_item );
				echo '<br />Last month Feed Items: ' . $this->count_the_posts($feed_item, -1 );
				#var_dump(wp_count_posts($feed_item));
				#var_dump(wp_count_posts('post'));
			?>			
			</p>
			<p>Total Current Nominations: 
			<?php 
				# var_dump(wp_count_posts('nomination'));
				echo wp_count_posts('nomination')->draft;
				echo '<br />Month to date Nominations: ' . $this->count_the_posts('nomination');
				echo '<br />Last month Nominations: ' . $this->count_the_posts('nomination', -1 );
				
			?>
			</p>
			<p>Total Actions Taken: 
			<?php 
				echo current($action_count[0]);
				#echo $action_count;
			
			?>
			</p>	
			<p>Total Nominations Published: 
			<?php 
				echo $nomed_posts;
				#var_dump($nomed_posts );
			
			?>
			</p>			
			<br /><br />
			<?php
				if(file_exists($log_path)){
				  echo '<pre>';
				  echo file_get_contents($log_path);
				  echo '</pre>';
				} else {
					echo "The log does not exist.";
				}
			?>
		</div>
		<?php
	}

	/**
	 * If this module has any styles to enqueue, do it in a method
	 * If you have no styles, etc, just ignore this
	 */
	function admin_enqueue_styles() {
		wp_register_style( PF_SLUG . '-debug-style', PF_URL . 'includes/debugger/css/style.css' );
	}

	function control_menu_access($arrayedAdminRights){
		$arrayedAdminRights['pf_menu_log_access'] = array(
															'default'=>'administrator',
															'title'=>'Debugging Log'
														);

		return $arrayedAdminRights;

	}

}
