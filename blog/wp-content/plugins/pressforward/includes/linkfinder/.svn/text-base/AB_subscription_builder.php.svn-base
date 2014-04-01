<?php

class AB_subscription_builder {

	public function __construct() {}

	/**
	 * Fetches the top-level categories from the academicblogs.org wiki
	 *
	 * @return array The return array should look like this:
	 *    'categories' => [the categories assembled from academicblogs.org]
	 *    'node_count' => [the number of nodes]
	 *    'nodes_populated' => [this value will always be zero coming from this method]
	 */
	public static function get_blog_categories( $theWikiLink = 'http://academicblogs.org/index.php/Main_Page' ) {

		$categories = array();
		$node_count = 0;

		$html = self::get_simple_dom_object( $theWikiLink );

		if ( ! $html ) {
			return false;
		}

		// The categories are headed by h2 elements in #bodyContent
		foreach ( $html->find( '#bodyContent' ) as $bodyContent ) {
			foreach ( $bodyContent->find( 'h2' ) as $h2 ) {

				$span = $h2->find( 'span' );
				if ( empty( $span ) ) {
					continue;
				}

				// Take the first item in the array
				$span_r = array_reverse( $span );
				$span = array_pop( $span_r );

				$spanText = $span->innertext;
				$spanNameArray = explode(' ', $spanText);
				$spanSlug = '';
				foreach ($spanNameArray as $spanNamePart){
					$spanSlug .= htmlentities(ucfirst($spanNamePart));
				}
				$spanSlug = self::sanitize($spanSlug, false, true);

				$categories[$spanSlug] = array(
					'slug' => $spanSlug,
					'text' => htmlspecialchars( strip_tags( $spanText ) ),
					'counter' => 0,
				);

				// Walk over siblings while they're <p> elements to get the subcategory links
				$next = $h2->next_sibling();
				while ( $next->tag == 'p' ) {
					$pchildren = $next->find( 'a' );
					if ( 1 == count( $pchildren ) ) {
						$pchildren_r = array_reverse( $pchildren );
						$childLink = array_pop( $pchildren_r );

						$link = $childLink->href;
						if ( ! in_array( $link, self::get_spam_sites() ) ) {
							$titleArray = explode( ' ', $childLink->title );

							$titleSlug = '';
							foreach ($titleArray as $titlePart){
								$titleSlug .= htmlentities(ucfirst($titlePart));
							}
							$titleSlug = self::sanitize($titleSlug, false, true);

							$categories[ $spanSlug ]['links'][ $titleSlug ] = array(
								'slug' => $titleSlug,
								'title' => htmlspecialchars( strip_tags( $childLink->title ) ),
								'link' => 'http://academicblogs.org' . $link,
							);

							$node_count++;
						}
					}

					$next = $next->next_sibling();
				}
			}
		}

		return array( 'categories' => $categories, 'node_count' => $node_count, 'nodes_populated' => 0 );
	}

	/**
	 * Given the $categories array, walk over and process $count categories
	 */
	public function add_category_links( $categories, $count ) {
		$counter = 0;

		foreach ( $categories['categories'] as &$category ) {
			foreach ( $category['links'] as &$subcategory ) {
				if ( isset( $subcategory['blogs'] ) ) {
					continue;
				}

				if ( $counter >= $count ) {
					break 2;
				}

				$subcategory['blogs'] = self::getLinksFromSection( $subcategory['link'] );
				$counter++;
				$categories['nodes_populated']++;
			}
		}

		return $categories;
	}

	function getTitle($Url){
		$request = wp_remote_get($Url);
		$response = $Url;

			if (is_wp_error($request)) {


			}
			else if(strlen($request['body'])>1){
				preg_match("/\<title\>(.*)\<\/title\>/",$request['body'],$title);
				$response = $title[1];
			} else {

			}
			$data = array();
			$data['url'] = $Url;
			$data['response'] = $response;

		if ($data['url'] != $Url){

			if (is_wp_error($request)) {


			}
			else if(strlen($request['body'])>1){
				preg_match("/\<title\>(.*)\<\/title\>/",$request['body'],$title);
				$response = $title[1];
			} else {

			}
			$data = array();
			$data['url'] = $Url;
			$data['response'] = $response;

		}
		return $data['response'];
	}

	# via http://stackoverflow.com/questions/2668854/sanitizing-strings-to-make-them-url-and-filename-safe
	public static function sanitize($string, $force_lowercase = true, $anal = false) {
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
		$stringSlug = self::sanitize($stringSlug, false, true);
		return $stringSlug;

	}

	public static function get_spam_sites(){

		$spamsites = array('http://www.buy-wellbutrin.com/', 'http://www.mycaal.com/');

		return $spamsites;

	}

	# to fill the blog property of the array.
	# PS... How often does this get updated?
	public static function getLinksFromSection ($sectionURL){
		set_time_limit(0);

		$html = self::get_simple_dom_object( $sectionURL );

		if ( ! $html ) {
			return 'No Links.';
		}

		$blogs = array();
		$c = 0;
		foreach ($html->find('#bodyContent') as $body){
			foreach ($body->find('a') as $link){
				if (!in_array(($link->href), self::get_spam_sites())){
					if ($link->rel == 'nofollow'){
						$URL = $link->href;
						$title = $link->innertext;
						$slug = self::slugger($title);
						$blogs[$slug]['slug'] = $slug;
						$blogs[$slug]['url'] = $URL;
						$blogs[$slug]['title'] = htmlspecialchars(strip_tags($title));
					}
				}
				else {

				}
			}
		}

		return $blogs;

	}

	public function build_the_ref_array()
	{
		//error_reporting(E_ALL);
		//error_reporting(-1);
		$theWikiLink = 'http://academicblogs.org/index.php/Main_Page';
		$htmlCounter = array();

		$html = self::get_simple_dom_object( $theWikiLink );

		if ( ! $html ) {
			return 'No Links.';
		}

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
				$ch1 = 0;
				# Walk through the dom and count paragraphs between H2 tags
				foreach ($nextBlock->children() as $bodyChild) {


					if (($bodyChild->tag=='h1')){
						if ($ch1 != 0){
							//return $htmlCounter;
							break 2;
							//goto end;
						}
						$ch1++;
					}

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
		//end:
		return $htmlCounter;
	}

	/**
	 * Get the pf_simple_html_dom object for a given URL
	 */
	public static function get_simple_dom_object( $url ) {
		$dom = null;
		$response = wp_remote_get( $url );
		if ( ! empty( $response ) && ! is_wp_error( $response ) ) {
			$dom = new pf_simple_html_dom( null );
			$dom->load( wp_remote_retrieve_body( $response ) );
		}

		return $dom;
	}

}
