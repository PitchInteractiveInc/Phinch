<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
</head>
<?php
//http://simplehtmldom.sourceforge.net/
//http://simplehtmldom.sourceforge.net/manual.htm#section_traverse
//http://simplehtmldom.sourceforge.net/manual_api.htm
//error_reporting(E_ALL);
mb_language('uni');
mb_internal_encoding('UTF-8');
require_once('pf_simple_html_dom.php');
$dom = new pf_simple_html_dom;

function getTitle($str){
    //$str = file_get_contents($Url);
    if(strlen($str)>1){
        preg_match("/\<title\>(.*)\<\/title\>/",$str,$title);
        return $title[1];
    }
}

function customError($errno, $errstr)
{
  return 'Nothing found';

}


//Random article for testing.
$html = pf_file_get_html('http://en.wikipedia.org/wiki/Saving_Babies');
echo 'References: <br />'; 
foreach ($html->find('h2') as $link){
	
	if (($link->plaintext == '[edit] External links') || ($link->plaintext == '[edit] References') ){
		
		$nextBlock = $link->next_sibling();
		foreach ($nextBlock->find('a') as $innerLink){
		if($innerLink->getAttribute('rel') == 'nofollow'){
			$theExternalSite = $innerLink->href;
			//if (!pf_file_get_html($theExternalSite)){
				//echo 'Page no longer exists.';
			//} else {
			//	$exHtml = pf_file_get_html($theExternalSite);
				
			//}
			//echo getTitle($innerLink->href);
			//if($exHtml->find('head')->find('title')){
			//	echo $exHtml->find('head')->find('title')->plaintext;
			//} elseif ($exHtml->head->meta->title == 'name') {
			//	echo 'Name';
			//}
			//if (getTitle($theExternalSite))
			set_error_handler("customError");
			echo getTitle(pf_file_get_html($theExternalSite));
			restore_error_handler();
			echo ' - ';
			echo $theExternalSite;
			echo '<br />';
			//echo $link->plaintext;
			//echo ' |- ';
			//echo $link->next_sibling();
		}
		}
	}

}

$contentHtml = pf_file_get_html('http://oha2012.thatcamp.org/');
//set_error_handler("customError");
$content = $contentHtml->find('.hentry');
echo $content[0]->innertext;

echo '<hr />';

$contentHtml = pf_file_get_html('http://www.freshandnew.org/2012/08/museum-datasets-un-comprehensive-ness-data-mining/');
//set_error_handler("customError");
$content = $contentHtml->find('.entry-content');
echo $content[0]->innertext;

echo '<hr />';

$contentHtml = pf_file_get_html('http://chronicle.com/article/Historians-Ask-Public-to-Help/134054');
//set_error_handler("customError");
$content = $contentHtml->find('.article-body');
//foreach ($content[0]->find('p') as $p) {

//	echo $p;

//}
echo $content[0]->innertext;

echo '<hr />';

$contentHtml = pf_file_get_html('http://oha2012.thatcamp.org/');
//set_error_handler("customError");
$content = $contentHtml->find('article');
echo $content[0]->innertext;

echo '<hr />';

$contentHtml = pf_file_get_html('http://www.wordsinspace.net/urban-media-archaeology/2012-fall/?page_id=9');
//set_error_handler("customError");
$content = $contentHtml->find('section');
echo $content[0]->innertext;

echo '<hr />';

$contentHtml = pf_file_get_html('http://www.wordsinspace.net/urban-media-archaeology/2012-fall/?page_id=9');
//set_error_handler("customError");
$content = $contentHtml->find('#content');
echo $content[0]->innertext;

echo '<hr />';

$contentHtml = pf_file_get_html('http://www.wordsinspace.net/urban-media-archaeology/2012-fall/?page_id=9');
//set_error_handler("customError");
$content = $contentHtml->find('.page-content');
//use to create it in html.
//echo htmlspecialchars($content[0]->innertext);
echo mb_convert_encoding($content[0]->innertext, 'UTF-8', 'UTF-8');
echo '<hr />';

//OG Check goes here. 

$contentHtml = get_meta_tags('http://www.nytimes.com/2012/09/04/us/politics/democrats-say-us-is-better-off-than-4-years-ago.html?_r=1&hp');
//set_error_handler("customError");
$content = $contentHtml['description'];
//echo $content;
echo $content;

echo '<hr />';

//Case 1 - .hentry http://oha2012.thatcamp.org/
//Case 2 - .entry-content  http://www.freshandnew.org/2012/08/museum-datasets-un-comprehensive-ness-data-mining/
//Case 3 - .article-body p (for each p) https://chronicle.com/article/Historians-Ask-Public-to-Help/134054
//Case 3 - article http://oha2012.thatcamp.org/
//Case 4 - section http://www.wordsinspace.net/urban-media-archaeology/2012-fall/?page_id=9
//Case 5 - #content http://www.wordsinspace.net/urban-media-archaeology/2012-fall/?page_id=9
//Case 6 - .page-content http://www.wordsinspace.net/urban-media-archaeology/2012-fall/?page_id=9
//Last case - OG Description

//We could also use this for getting featured imgs mby?
?>