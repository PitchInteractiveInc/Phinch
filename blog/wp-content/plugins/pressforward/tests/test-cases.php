<?php

class PF_Tests extends PF_UnitTestCase {

	function test_pf_get_relationship_value_blank_string() {
		$user_id = $this->factory->user->create();
		$item_id = $this->factory->post->create();
		$type = 'star';
		$relationship_id = $this->factory->relationship->create( array(
			'user_id' => $user_id,
			'item_id' => $item_id,
			'type'    => $type,
			'value'   => '',
		) );

		$value = pf_get_relationship_value( $type, $item_id, $user_id );
		$this->assertSame( '', $value );
	}

	function test_pf_get_relationship_value_doesnt_exist() {
		$user_id = $this->factory->user->create();
		$item_id = $this->factory->post->create();
		$type = 'star';

		$value = pf_get_relationship_value( $type, $item_id, $user_id );
		$this->assertSame( false, $value );
	}

	function test_pf_get_relationship_value_no_relationship_by_this_type() {
		$user_id = $this->factory->user->create();
		$item_id = $this->factory->post->create();
		$type = 'star';
		$relationship_id = $this->factory->relationship->create( array(
			'user_id' => $user_id,
			'item_id' => $item_id,
			'type'    => $type,
			'value'   => '',
		) );

		// Try a different type of relationship. Should return false
		$value = pf_get_relationship_value( 'read', $item_id, $user_id );

		$this->assertSame( false, $value );
	}

	function test_pf_get_relationship_value_no_relationship_by_this_type_with_integers() {
		$user_id = $this->factory->user->create();
		$item_id = $this->factory->post->create();
		$type = 2;
		$relationship_id = $this->factory->relationship->create( array(
			'user_id' => $user_id,
			'item_id' => $item_id,
			'type'    => $type,
			'value'   => 1,
		) );

		// Try a different type of relationship. Should return false
		$value = pf_get_relationship_value( 1, $item_id, $user_id );

		$this->assertSame( false, $value );
	}

}

