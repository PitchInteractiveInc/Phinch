<?php

require_once('pf_simple_html_dom.php');
$dom = new pf_simple_html_dom;

class AB_subscription_builder {

	public function __construct(){
		
		$htmlCounterObj = $this->build_the_ref_array();
		return $htmlCounterObj;
	}	
	
	public function getTitle($str){
		//$str = file_get_contents($Url);
		if(strlen($str)>1){
			preg_match("/\<title\>(.*)\<\/title\>/",$str,$title);
			return $title[1];
		}
	}
	
	# via http://stackoverflow.com/questions/2668854/sanitizing-strings-to-make-them-url-and-filename-safe
	public function sanitize($string, $force_lowercase = true, $anal = false) {
		$strip = array("~", "`", "!", "@", "#", "$", "%", "^", "&", "*", "(", ")", "_", "=", "+", "[", "{", "]",
					   "}", "\\", "|", ";", ":", "\"", "'", "&#8216;", "&#8217;", "&#8220;", "&#8221;", "&#8211;", "&#8212;",
					   "—", "–", ",", "<", ".", ">", "/", "?");
		$clean = trim(str_replace($strip, "", strip_tags($string)));
		$clean = preg_replace('/\s+/', "-", $clean);
		$clean = ($anal) ? preg_replace("/[^a-zA-Z0-9]/", "", $clean) : $clean ;
		return ($force_lowercase) ?
			(function_exists('mb_strtolower')) ?
				mb_strtolower($clean, 'UTF-8') :
				strtolower($clean) :
			$clean;
	}

	public function slugger($string){

		$string = strip_tags($string);
		$stringArray = explode(' ', $string);
		$stringSlug = '';
		foreach ($stringArray as $stringPart){
			$stringSlug .= ucfirst($stringPart);
		}
		$stringSlug = str_replace('&amp;','&', $stringSlug);
		//$charsToElim = array('?','/','\\');
		$stringSlug = $this->sanitize($stringSlug, false, true);
		echo $stringSlug;
		return $stringSlug;
		
	}
	
	public function get_spam_sites(){
		
		$spamsites = array('http://www.buy-wellbutrin.com/', 'http://www.mycaal.com/');
		
		return $spamsites;
		
	}

	# to fill the blog property of the array. 
	# PS... How often does this get updated?
	public function getLinksFromSection ($sectionURL){		
		set_time_limit(0);
		$html = pf_file_get_html($sectionURL);
		
		$blogs = array();
		$c = 0;
		foreach ($html->find('#bodyContent') as $body){
			foreach ($body->find('a') as $link){
				if (!in_array(($link->href), $this->get_spam_sites())){ 
					if ($link->rel == 'nofollow'){
						$URL = $link->href;
						$title = $link->innertext;
						$slug = $this->slugger($title);
						$blogs[$slug]['slug'] = $slug;
						$blogs[$slug]['url'] = $URL;
						$blogs[$slug]['title'] = htmlspecialchars(strip_tags($title));
					}
				}
				else {
					
				}
			}
		}
		echo $blogs;		
		return $blogs;
		
	}

	public function build_the_ref_array()
	{
		error_reporting(E_ALL);
		error_reporting(-1);
		echo 'begin<br /><br />';
		$theWikiLink = 'http://academicblogs.org/index.php/Main_Page';
		$htmlCounter = array();
		//Random article for testing.
		$html = pf_file_get_html($theWikiLink);
		//print_r($html);
		# Get the title page
		foreach ($html->find('h1') as $link){
			//print_r($link);
		//	if (($link->plaintext == '[edit] External links') || ($link->plaintext == '[edit] References') ){
				set_time_limit(0);
				# Get the main content block
				$nextBlock = $link->next_sibling();
				//print_r($nextBlock);	
				
				$counter = 0;
				$sectionCounter = 0;
				$links = array();
				# Walk through the dom and count paragraphs between H2 tags
				foreach ($nextBlock->children() as $bodyChild) {
					echo $bodyChild;
					if (($bodyChild->find('span')) && ($bodyChild->tag=='h2')){
						foreach ($bodyChild->find('span') as $span){
							$sectionCounter++;
							$spanText = $span->innertext;
							
							$spanNameArray = explode(' ', $spanText);
							$spanSlug = '';
							foreach ($spanNameArray as $spanNamePart){
								$spanSlug .= htmlentities(ucfirst($spanNamePart));
							}
							$spanSlug = $this->sanitize($spanSlug, false, true);
							
							$htmlCounter[$spanSlug]['slug'] = $spanSlug;
							$htmlCounter[$spanSlug]['text'] = htmlspecialchars(strip_tags($spanText));
							$htmlCounter[$spanSlug]['counter'] = $counter;
							$counter = 0;
							$links = array();
							//$htmlCounter[];
						}
					} else {
						//$htmlCounter[$spanSlug]['error'] = false;
					}
					
					if (($bodyChild->tag=='p') && ((count($bodyChild->find('a'))) == 1) && ((count($bodyChild->find('a[class=new]'))) == 0)){
						
						$counter++;
						
						foreach ($bodyChild->find('a') as $childLink){
							$link = $childLink->href;
							$title = $childLink->title;
							
							if (!in_array($link, $this->get_spam_sites())){
								$titleArray = explode(' ', $title);
								$titleSlug = '';
								foreach ($titleArray as $titlePart){
									$titleSlug .= htmlentities(ucfirst($titlePart));
								}
								//$charsToElim = array('?','/','\\');
								$titleSlug = $this->sanitize($titleSlug, false, true);
								
								$link = 'http://academicblogs.org' . $link;
								
								$sectionSlug = $htmlCounter[$spanSlug]['slug'];
								
								$htmlCounter[$spanSlug]['links'][$titleSlug]['slug'] = $titleSlug;
								$htmlCounter[$spanSlug]['links'][$titleSlug]['title'] = htmlspecialchars(strip_tags($title));
								$htmlCounter[$spanSlug]['links'][$titleSlug]['link'] = $link;
								//if ($childLink->){
									$htmlCounter[$spanSlug]['links'][$titleSlug]['blogs'] = $this->getLinksFromSection($link);
								//}
								
								//$links[$sectionSlug][$titleSlug]['title'] = $title;
								//$links[$sectionSlug][$titleSlug]['link'] = $link;
							} else {
								
								$counter--;
								$htmlCounter[$spanSlug]['links'][$counter]['error'] = false;
							}
						}
					}
				
				}
				
		}
	
		return $htmlCounter;
	}

}

$ABSubscriptionBuilder = new AB_subscription_builder;
$ABLinksArray = $ABSubscriptionBuilder->build_the_ref_array();

echo '<pre>';
print_r($ABLinksArray);
echo '</pre>';
?>