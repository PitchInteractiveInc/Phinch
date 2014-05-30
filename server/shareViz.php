<?php
require 'dbconfig.php';
$sharedDataFolder = '../biomFiles/';
/* check if all vars exist */
$requiredVars = array('from_email','from_name','to_email','to_name','notes', 'biom_file_hash', 'viz_name','layer_name');
foreach($requiredVars as $requiredVar) {
	if(! isset($_POST[$requiredVar])) {
		die('missing ' . $requiredVar);
	}
}

/*fetch layer and vizualization types */
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
/* ensure we have a valid viz and layer */
$vizID = null;
$layerID = null;
foreach($layers as $layer) {
	if($layer['name'] === $_POST['layer_name']) {
		$layerID = $layer['id'];
	}
}
if($layerID === null) {
	die('invalid layer id');
}

foreach($viz as $vizType) {
	if($vizType['name'] === $_POST['viz_name']) {
		$vizID = $vizType['id'];
	}
}
if($vizID === null) {
	die('invalid viz id');
}

$urlHash = generateRandomString(32);
//ensure hash doesnt exist
$urlHashExists = $db->prepare('SELECT COUNT(*) as count FROM SharedData WHERE url_hash = :url_hash');
while(true) {
	$urlHashExists->bindParam(':url_hash', $urlHash);
	$urlHashExists->execute();
	$exists = $urlHashExists->fetch(PDO::FETCH_OBJ);
	if($exists->count == 0) {
		break;
	} else {
		$urlHash = generateRandomString(32);
	}
}

$q = 'INSERT INTO SharedData (biom_filename, biom_file_hash, ip_address, from_email, from_name, to_email, to_name, notes, url_hash, visualization_id, layer_id, visualization_options, date_uploaded, countView, filter_options_json) VALUES ';
$q .= '(:biom_filename, :biom_file_hash, :ip_address, :from_email, :from_name, :to_email, :to_name, :notes, :url_hash, :visualization_id, :layer_id, :visualization_options, NOW(), 0, :filter_options_json)';
$stmt = $db->prepare($q);
$stmt->bindParam(':biom_file_hash', $_POST['biom_file_hash']);
$stmt->bindParam(':ip_address', $_SERVER['REMOTE_ADDR']);
$stmt->bindParam(':from_email', $_POST['from_email']);
$stmt->bindParam(':to_email', $_POST['to_email']);
$stmt->bindParam(':from_name', $_POST['from_name']);
$stmt->bindParam(':to_name', $_POST['to_name']);
$stmt->bindParam(':notes', $_POST['notes']);
$stmt->bindParam(':url_hash', $urlHash);
$stmt->bindParam(':visualization_id', $vizID);
$stmt->bindParam(':layer_id', $layerID);
$stmt->bindParam(':filter_options_json', $_POST['filter_options_json']);
$stmt->bindParam(':visualization_options', json_encode(array()));
//generate random url hash

//do we have an uploaded file?
if(isset($_POST['biomFile'])) {
	$randomFilename = generateRandomString(32);
	while(file_exists($sharedDataFolder.$randomFilename)) {
		$randomFilename = generateRandomString(32);
	}
	$fullPath = $sharedDataFolder.$randomFilename;
	$f = fopen($fullPath,'w+');
	fwrite($f, $_POST['biomFile']);
	fclose($f);
	//bindFilename
	$stmt->bindParam(':biom_filename', $randomFilename);
} else {
	//get filename from db
	$biomFilename = $db->prepare('SELECT biom_filename FROM SharedData WHERE biom_file_hash = :biom_file_hash');
	$biomFilename->bindParam(':biom_file_hash', $_POST['biom_file_hash']);
	$biomFilename->execute();
	$filename = $biomFilename->fetch(PDO::FETCH_OBJ);

	//bind it
	$stmt->bindParam(':biom_filename', $filename->biom_filename);
}

$stmt->execute();
//execute query
$link = 'http://phinch.org/viz.html?shareID=' . $urlHash;
$to = $_POST['to_email'];
$subject = 'Shared Biom Visualization';
$message = 'Hi ' . $_POST['to_name']."\n\n";
$message .= $_POST['from_name'].' ' .$_POST['from_email'] .' has shared a visuzliation with you. You can view it here:'. "\n\n";
$message .= $link;

$message .= "\n\n";
if($_POST['notes'] !== '') {
	$message .= 'Notes: ' . $_POST['notes'];
}
$header = 'From: noreply@phinch.org' . "\r\n" . "Reply-To: " . $_POST['from_email'] . "\r\n" . 'X-Mailer: PHP/' . phpversion();
echo json_encode(array('status' => 'ok', 'urlHash' => $urlHash));
mail($to, $subject, $message, $header);

function generateRandomString($length = 10) {
    $characters = '0123456789abcdefghijklmnopqrstuvwxyz';
    $randomString = '';
    for ($i = 0; $i < $length; $i++) {
        $randomString .= $characters[rand(0, strlen($characters) - 1)];
    }
    return $randomString;
}
?>