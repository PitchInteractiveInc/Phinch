<?php
$dbConfig = array(
	'username' => '',
	'password' => '',
	'host' => '',
	'dbname' => ''
);


$db = new PDO('mysql:host=' . $dbConfig['host'].';dbname=' . $dbConfig['dbname'],
 $dbConfig['username'], $dbConfig['password']);
?>