<?php
require "dbconfig.php";
if(!isset($_GET['hash']) || ! ctype_alnum($_GET['hash'])) {
	die('invalid hash');
}
$hash = $_GET['hash'];
$stmt = $db->prepare('SELECT COUNT(*) as count FROM SharedData WHERE biom_file_hash = :hash');
$stmt->bindParam(':hash', $hash);
$stmt->execute();

$count = null;
while($rs = $stmt->fetch(PDO::FETCH_OBJ)) {
	$count = $rs->count;
}
if($count > 0) {
	die('true');
} else {
	die('false');
}
?>