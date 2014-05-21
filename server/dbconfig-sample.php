<?php
$dbConfig = array(
	'username' => '',
	'password' => '',
	'host' => '',
	'dbname' => ''
);


$db = new PDO('mysql:host=' . $dbConfig['host'].';dbname=' . $dbConfig['host'],
 $dbConfig['username'], $dbConfig['password']);
var_dump($db)
?>