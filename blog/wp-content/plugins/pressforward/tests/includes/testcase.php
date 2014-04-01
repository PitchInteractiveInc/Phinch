<?php

class PF_UnitTestCase extends WP_UnitTestCase {

	public function setUp() {
		parent::setUp();
		$this->factory = new PF_UnitTest_Factory;
	}

	public function tearDown() {
		parent::tearDown();
	}
}
