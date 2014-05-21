<?php

require 'dbconfig.php';

$stmt = $db->prepare('SELECT * FROM Layer');
$stmt->execute();
$layers = array();
while($rs = $stmt->fetch(PDO::FETCH_OBJ)) {
	$layers[] = array('name' => $rs->name, 'id' => $rs->layer_id);
}

$stmt = $db->prepare('SELECT * FROM Visualization');
$stmt->execute();
$viz = array();
while($rs = $stmt->fetch(PDO::FETCH_OBJ)) {
	$viz[] = array('name' => $rs->name, 'id' => $rs->visualization_id);
}



$data = array(
	'layers' => $layers,
	'visualizations' => $viz
);
echo json_encode($data);
?>