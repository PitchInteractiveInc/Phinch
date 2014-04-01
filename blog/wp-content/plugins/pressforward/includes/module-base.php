<?php

/**
 * Base class for PressForward RSS modules
 */
class PF_Module {
	var $id;
	var $module_dir;
	var $module_url;
	var $feed_type;

	function start() {
		$this->setup_hooks();
	}

	function setup_hooks() {
		// Once modules are registered, set up some basic module info
		add_action( 'pf_setup_modules', array( $this, 'setup_module_info' ) );
		add_action( 'admin_init', array($this, 'module_setup') );
		// Set up the admin panels and save methods
		add_action( 'pf_admin_op_page', array( $this, 'admin_op_page' ) );
		add_action( 'pf_admin_op_page_save', array( $this, 'admin_op_page_save' ) );

	}

	/**
	 * Determine some helpful info about this module
	 *
	 * Sets the module ID based on the key used to register the module in
	 * the $pf global
	 *
	 * Also sets up the module_dir and module_url for use throughout
	 */
	function setup_module_info() {
		$pf = pressforward();

		// Determine the ID by checking which module this class belongs to
		$module_class = get_class( $this );
		foreach ( $pf->modules as $module_id => $module ) {
			if ( is_a( $module, $module_class ) ) {
				$this->id = $module_id;
				break;
			}
		}

		// If we've found an id, use it to create some paths
		if ( $this->id ) {
			$this->module_dir = trailingslashit( PF_ROOT . '/modules/' . $this->id );
			$this->module_url = trailingslashit( PF_URL . 'modules/' . $this->id );
		}

		$enabled = get_option( PF_SLUG . '_' . $this->id . '_enable' );
		if ( ! in_array( $enabled, array( 'yes', 'no' ) ) ) {
			$enabled = 'yes';
		}

		if ( 'yes' == $enabled ) {
			// Run at 15 to make sure the core menu is loaded first
			add_action( 'admin_menu', array( $this, 'setup_admin_menus' ), 15 );

			add_action( 'admin_enqueue_scripts', array( $this, 'admin_enqueue_scripts' ) );
			add_action( 'admin_enqueue_scripts', array( $this, 'admin_enqueue_styles' ) );	// There's no admin_enqueue_styles action

			add_action( 'wp_enqueue_scripts', array( $this, 'wp_enqueue_scripts' ) );
			add_action( 'wp_enqueue_styles',  array( $this, 'wp_enqueue_styles' ) );
			add_action( 'feeder_menu', array( $this, 'add_to_feeder' ) );
			add_filter('dash_widget_bar', array($this, 'add_dash_widgets_filter') );
		}

		if ( method_exists( $this, 'post_setup_module_info' ) ) {
			$this->post_setup_module_info();
		}
	}

	function module_setup(){
		$mod_settings = array(
			'name' => $this->id . ' Module',
			'slug' => $this->id,
			'description' => 'This module needs to overwrite the setup_module function and give a description.',
			'thumbnail' => '',
			'options' => ''
		);

		update_option( PF_SLUG . '_' . $this->id . '_settings', $mod_settings );

		//return $test;
	}

	public function admin_op_page() {
		//Module enable option code originated in https://github.com/boonebgorges/participad
		$modsetup = get_option(PF_SLUG . '_' . $this->id . '_settings');
		$modId = $this->id;
		//print_r(PF_SLUG . '_' . $modId . '_enable');
		$enabled = get_option(PF_SLUG . '_' . $modId . '_enable');
		if ( ! in_array( $enabled, array( 'yes', 'no' ) ) ) {
			$enabled = 'yes';
		}
			//print_r( $this->is_enabled() );
		?>
			<h4><?php _e( $modsetup['name'], PF_SLUG ) ?></h4>

			<p class="description"><?php _e( $modsetup['description'], PF_SLUG ) ?></p>

			<table class="form-table">
				<tr>
					<th scope="row">
						<label for="participad-dashboard-enable"><?php _e( 'Enable '. $modsetup['name'], PF_SLUG ) ?></label>
					</th>

					<td>
						<select id="<?php echo PF_SLUG . '_' . $modId . '_enable'; ?>" name="<?php echo PF_SLUG . '_' . $modId . '_enable'; ?>">
							<option value="yes" <?php selected( $enabled, 'yes' ) ?>><?php _e( 'Yes', PF_SLUG ) ?></option>
							<option value="no" <?php selected( $enabled, 'no' ) ?>><?php _e( 'No', PF_SLUG ) ?></option>
						</select>
					</td>
				</tr>
			</table>
		<?php
	}

	public function admin_op_page_save() {
		$modId = $this->id;
		$enabled = isset( $_POST[PF_SLUG . '_' . $modId . '_enable'] ) && 'no' == $_POST[PF_SLUG . '_' . $modId . '_enable'] ? 'no' : 'yes';
		update_option( PF_SLUG . '_' . $modId . '_enable', $enabled );

	}

	function setup_admin_menus( $admin_menus ) {
		foreach ( (array) $admin_menus as $admin_menu ) {
			$defaults = array(
				'page_title' => '',
				'menu_title' => '',
				'cap'        => 'edit_posts',
				'slug'       => '',
				'callback'   => '',
			);
			$r = wp_parse_args( $admin_menu, $defaults );

			// add_submenu_page() will fail if any arguments aren't passed
			if ( empty( $r['page_title'] ) || empty( $r['menu_title'] ) || empty( $r['cap'] ) || empty( $r['slug'] ) || empty( $r['callback'] ) ) {
				continue;
			}

			add_submenu_page( PF_MENU_SLUG, $r['page_title'], $r['menu_title'], $r['cap'], $r['slug'], $r['callback'] );
		}
	}
/**
	function setup_dash_widgets( $dash_widgets ) {
		foreach ( (array) $dash_widgets as $dash_widget ) {
			$defaults = array(
				'widget_title' => '',
				'slug'       => '',
				'callback'   => '',
			);
			$r = wp_parse_args( $dash_widget, $defaults );

			// add_submenu_page() will fail if any arguments aren't passed
			if ( empty( $r['widget_title'] ) || empty( $r['slug'] ) || empty( $r['callback'] ) ) {
				continue;
			}

			//add_action( PF_MENU_SLUG, $r['page_title'], $r['menu_title'], $r['cap'], $r['slug'], $r['callback'] );
		}
	}
**/
	// Fetch and return a formatted data object - optional
	function get_data_object($theFeed) { return array(); }

	function pf_add_dash_widgets() {
		$array = array();
		return $array;
	}

	function add_dash_widgets_filter($filter_inc_array) {
		$client_widgets = $this->pf_add_dash_widgets();
		$all_widgets = array_merge($filter_inc_array, $client_widgets);
		return $all_widgets;
	}

	// Scripts and styles - optional
	function admin_enqueue_scripts() {}
	function admin_enqueue_styles() {}
	function wp_enqueue_scripts() {}
	function wp_enqueue_styles() {}
	function add_to_feeder() {}

}
