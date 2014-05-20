<?php
$pipeDescriptions = array(
   0 => array("pipe", "r"),  // stdin is a pipe that the child will read from
   1 => array("pipe", "w"),  // stdout is a pipe that the child will write to
   2 => array("pipe", "w") // stderr is also a pipe
);
if(!isset($_POST['svg'])) {
    die(json_encode(array('error' => 'no svg data')));
}

//mamp work arounds :( 
//$_ENV['PATH'] = '/opt/local/bin:/opt/local/sbin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin:/opt/X11/bin:/usr/local/git/bin:/Users/pitchmini/bin/FDK/Tools/osx';
//unset($_ENV['DYLD_LIBRARY_PATH']);

$svg = $_POST['svg'];
if(get_magic_quotes_gpc()) {
    $svg = stripslashes($svg);
}

$process = proc_open('convert svg: png:-', $pipeDescriptions, $pipes, NULL, $_ENV);
//$process = proc_open('convert tmp.svg png:-', $pipeDescriptions, $pipes, NULL, $_ENV);
//$process = proc_open('convert -version', $pipeDescriptions, $pipes, NULL, $_ENV);
if (is_resource($process)) {
    // $pipes now looks like this:
    // 0 => writeable handle connected to child stdin
    // 1 => readable handle connected to child stdout
    // 2 => readable handle connected to child stderr
    
    fwrite($pipes[0], $svg);
    fclose($pipes[0]);


    $stdOut = stream_get_contents($pipes[1]);
    fclose($pipes[1]);

    $stdErr = stream_get_contents($pipes[2]);
    fclose($pipes[2]);

    // It is important that you close any pipes before calling
    // proc_close in order to avoid a deadlock
    $return_value = proc_close($process);
    
    $response = array('code' => $return_value, 'err' => $stdErr, 'out' => base64_encode($stdOut));
    echo json_encode($response);

}
?>