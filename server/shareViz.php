<?php
require 'dbconfig.php';

$requiredVars = array('from_email','from_name','to_email','to_name','notes', 'biom_file_hash', 'viz_id','layer_id')
foreach($requiredVars as $requiredVar) {
	if(! isset($_POST[$requiredVar])) {
		die('missing ' . $requiredVar)
	}
}
?>