<?php

/** * close all open xhtml tags at the end of the string

 * * @param string $html

 * @return string

 * @author Milian <mail@mili.de>
 
 * from http://www.kirupa.com/forum/showthread.php?343478-Close-all-open-HTML-tags

 */
 
class pf_htmlchecker {

 public function __construct(){
	//$html = $this->closetags($html);
 }

 public function closetags($html) {

	$html = str_replace(array('<article', '</article>'), array('<div', '</div>'), $html);

	$html = str_replace(array('<!--', '-->'), array('<span class="commented-out-html" style="display:none;">', '</span>'), $html); 
	
    $tags_and_content_to_strip = Array("title","script","link","meta");
    
    foreach ($tags_and_content_to_strip as $tag) {
           $html = preg_replace("/<" . $tag . ">(.|\s)*?<\/" . $tag . ">/","",$html);
		   $html = preg_replace("/<" . $tag . " (.|\s)*?>/","",$html);
    }
	
	#$html = preg_match_all('#<(article)*>#', $html, $resultc);
  
  #put all opened tags into an array

  preg_match_all('#<([a-z]+)(?: .*)?(?<![/|/ ])>#iU', $html, $result);

  $openedtags = $result[1];   #put all closed tags into an array

  preg_match_all('#</([a-z]+)>#iU', $html, $result);

  $closedtags = $result[1];

  $len_opened = count($openedtags);

  preg_match_all('#<(em|strong)*/>#', $html, $resultc);
  $malformedtags = $resultc[1];  
  //print_r('Count <br />');
  foreach ($malformedtags as $tag){
	if ($tag == 'em'){
		$html .= '</em>';
	}
	if ($tag == 'strong'){
		$html .= '</strong>';
	}	
  } 
  
  # all tags are closed
  
  if (count($closedtags) == $len_opened) {

    return $html;

  }

  $openedtags = array_reverse($openedtags);

  # close tags

  for ($i=0; $i < $len_opened; $i++) {

    if (!in_array($openedtags[$i], $closedtags)){

      $html .= '</'.$openedtags[$i].'>';

    } else {

      unset($closedtags[array_search($openedtags[$i], $closedtags)]);    }

  }  


  //print_r($html);
  return $html;
  
  } 
}  
?>