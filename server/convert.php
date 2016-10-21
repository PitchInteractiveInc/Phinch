<?php

namespace biomcs;

/**
 * This file converts base64 encoded "content" "to" the desired format (hdf5 or json)
 * The output format is json that contains biom data base64 encoded as part of the output array:
 * Example:
 * {
 *   content: "iUhERg0KGgoAAAAAAAgIAAQAEAAAAAAAAAAAAAAAAAD\/\/\/\/\/\/\/\/\/\/zCEAAAAAAAA...AAAAAAAAAAAAAAAAAAA",
 *   error: null
 * }
 */

// Allow CORS
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type");
// Set own content type
header("Content-Type: application/json");

require_once __DIR__ . DIRECTORY_SEPARATOR . 'vendor' . DIRECTORY_SEPARATOR . 'autoload.php';
// explicitly set CONTENT_TYPE if empty (required for testing)
if(empty($_SERVER['CONTENT_TYPE']))
{
    $_SERVER['CONTENT_TYPE'] = "application/x-www-form-urlencoded";
}
// load json data into $_REQUEST if content type is application/json
if($_SERVER["CONTENT_TYPE"] === 'application/json'){
    $_REQUEST = json_decode(file_get_contents('php://input'), true);
}
$to = isset($_REQUEST["to"]) ? $_REQUEST["to"] : false;
$content = isset($_REQUEST["content"]) ? $_REQUEST["content"] : false;
$content = base64_decode($content);
if (!$to) {
    echo json_encode(array("error" => "Missing parameter 'to' please set to 'json' or 'hdf5'"));
} elseif ($to !== 'json' && $to !== 'hdf5') {
    echo json_encode(array("error" => "Illegal value of 'to' parameter please set to 'json' or 'hdf5'"));
} elseif (!$content) {
    echo json_encode(array("error" => "Missing parameter 'content' please send the content to convert as base64 encoded string"));
} else {
    $biomcs = new BiomCS();
    try {
        if ($to === "json") {
            echo json_encode(
                array(
                    "content" => base64_encode($biomcs->convertToJSON($content)),
                    "error" => null
                ),
                JSON_PRETTY_PRINT
            );
        } elseif ($to === "hdf5") {
            print json_encode(
                array(
                    "content" => base64_encode($biomcs->convertToHDF5($content)),
                    "error" => null
                ),
                JSON_PRETTY_PRINT
            );
        }
    } catch (\Exception $e) {
        echo json_encode(array("error" => $e->getMessage()), JSON_PRETTY_PRINT);
    }
}
