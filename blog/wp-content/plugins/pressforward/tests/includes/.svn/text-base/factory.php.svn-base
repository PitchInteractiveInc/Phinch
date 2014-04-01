<?php

class PF_UnitTest_Factory extends WP_UnitTest_Factory {
	public $activity = null;

	function __construct() {
		parent::__construct();

		$this->relationship = new PF_UnitTest_Factory_For_Relationship( $this );
	}
}

class PF_UnitTest_Factory_For_Relationship extends WP_UnitTest_Factory_For_Thing {

	function __construct( $factory = null ) {
		parent::__construct( $factory );

		$this->default_generation_definitions = array(
			'user_id' => 0,
			'item_id' => 0,
			'type'    => 'star',
			'value'   => '',
		);
	}

	function create_object( $args ) {
		if ( ! isset( $args['user_id'] ) )
			$args['user_id'] = get_current_user_id();

		return pf_set_relationship( $args['type'], $args['item_id'], $args['user_id'], $args['value'] );
	}

	function update_object( $activity_id, $fields ) {
		$activity = new BP_Activity_Activity( $activity_id );

		foreach ( $fields as $field_name => $value ) {
			if ( isset( $activity->$field_name ) )
				$activity->$field_name = $value;
		}

		$activity->save();
		return $activity;
	}

	function get_object_by_id( $user_id ) {
		return new BP_Activity_Activity( $user_id );
	}
}

