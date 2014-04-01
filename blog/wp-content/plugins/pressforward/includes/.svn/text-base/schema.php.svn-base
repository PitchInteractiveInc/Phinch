<?php

/**
 * Feed item data schema
 *
 * The RSS Import module stores several different types of data. The schemas
 * are described below.
 *
 * (1) FEED ITEMS
 *     Feed items are stored in a custom post type ('pf_feed_item'). Data
 *     is mapped as follows:
 *
 *     [data type]       -> [WP location]
 *     feed item title   -> wp_posts.post_title
 *     feed item URL     -> wp_posts.guid
 *     feed item content -> wp_posts.post_content
 *     word count        -> wp_postmeta ('pf_feed_item_word_count')
 *     source feed       -> wp_postmeta ('pf_feed_item_source') May move to post_parent if feeds move to CPT
 *     date              -> wp_posts.post_date_gmt
 */
class PF_Feed_Item_Schema {
	var $feed_item_post_type;
	var $feed_item_tag_taxonomy;

	public function init() {
		static $instance;

		if ( empty( $instance ) ) {
			$instance = new self;
		}

		return $instance;
	}

	public function __construct() {
		$this->feed_item_post_type = 'pf_feed_item';
		$this->feed_item_tag_taxonomy = 'pf_feed_item_tag';

		// Post types and taxonomies must be registered after 'init'
		add_action( 'init', array( $this, 'register_feed_item_post_type' ) );
		add_action( 'pf_feed_item_post_type_registered', array( $this, 'register_feed_item_tag_taxonomy' ) );

		// Maybe install custom table for relationships
		add_action( 'admin_init', array( $this, 'maybe_install_relationship_table' ) );
	}

	/**
	 * Feed items are stored in a CPT, which is registered here
	 */
	public function register_feed_item_post_type() {
		$labels = array(
			'name'               => __( 'Feed Items', 'pf' ),
			'singular_name'      => __( 'Feed Item', 'pf' ),
			'add_new'            => _x( 'Add New', 'pf', 'add new feed item' ),
			'all_items'          => __( 'All Feed Items', 'pf' ),
			'add_new_item'       => __( 'Add New Feed Item', 'pf' ),
			'edit_item'          => __( 'Edit Feed Item', 'pf' ),
			'new_item'           => __( 'New Feed Item', 'pf' ),
			'view_item'          => __( 'View Feed Item', 'pf' ),
			'search_items'       => __( 'Search Feed Items', 'pf' ),
			'not_found'          => __( 'No feed items found', 'pf' ),
			'not_found_in_trash' => __( 'No feed items found in trash', 'pf' ),
		);

		register_post_type( $this->feed_item_post_type, apply_filters( 'pf_register_feed_item_post_type_args', array(
			'label'       => $labels['name'],
			'labels'      => $labels,
			'description' => __( 'Feed items imported by PressForward&#8217;s RSS Importer', 'pf' ),
			'public'      => false,
			'show_ui'     => false, // for testing only
		) ) );

		do_action( 'pf_feed_item_post_type_registered' );
	}

	public function register_feed_item_tag_taxonomy() {
		$labels = array(
			'name'          => __( 'Feed Item Tags', 'pf' ),
			'singular_name' => __( 'Feed Item Tag', 'pf' ),
			'all_items'     => __( 'All Feed Item Tags', 'pf' ),
			'edit_item'     => __( 'Edit Feed Item Tag', 'pf' ),
			'update_item'   => __( 'Update Feed Item Tag', 'pf' ),
			'add_new_item'  => __( 'Add New Feed Item Tag', 'pf' ),
			'new_item_name' => __( 'New Feed Item Tag', 'pf' ),
			'search_items'  => __( 'Search Feed Item Tags', 'pf' ),
		);

		register_taxonomy( $this->feed_item_tag_taxonomy, $this->feed_item_post_type, apply_filters( 'pf_register_feed_item_tag_taxonomy_args', array(
			'labels' => $labels,
			'public' => true,
			'show_admin_columns' => true,
			'rewrite' => false,
		) ) );
	}

	/**
	 * Checks to see whether the relationship table needs to be installed, and installs if so
	 *
	 * A regular activation hook won't work correctly given where how
	 * this file is loaded. Might change this in the future
	 */
	public function maybe_install_relationship_table() {
		if ( ! is_super_admin() ) {
			return;
		}

		global $wpdb;
		$table_exists = $wpdb->get_var( $wpdb->prepare( "SHOW TABLES LIKE %s", $wpdb->prefix . 'pf_relationships' ) );

		if ( ! $table_exists ) {
			self::install_relationship_table();
		}
	}

	/**
	 * Defines the relationship table schema and runs dbDelta() on it
	 */
	public static function install_relationship_table() {
		global $wpdb;

		require_once( ABSPATH . 'wp-admin/includes/upgrade.php' );

		$sql = array();
		$sql[] = "CREATE TABLE IF NOT EXISTS {$wpdb->prefix}pf_relationships (
	                    id bigint(20) NOT NULL AUTO_INCREMENT PRIMARY KEY,
		            user_id bigint(20) NOT NULL,
		            item_id bigint(20) NOT NULL,
			    relationship_type smallint(5) NOT NULL,
			    value varchar(255),

			    KEY user_id (user_id),
			    KEY item_id (item_id),
			    KEY relationship_type (relationship_type)
			)";

		dbDelta( $sql );
	}
}
