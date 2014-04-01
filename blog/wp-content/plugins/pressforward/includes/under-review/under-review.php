<?php
//Code for Under Review menu page generation

//Duping code from 1053 in main.
//Mockup - https://gomockingbird.com/mockingbird/#mr28na1/I9lz7i

		//Calling the feedlist within the pf class.
		if (isset($_GET["pc"])){
			$page = $_GET["pc"];
			$page = $page-1;
		} else {
			$page = 0;
		}
		$count = $page * 20;	
		$countQ = 0;
	?>
	<div class="list pf_container full">
		<header id="app-banner">
			<div class="title-span title">
				<?php echo '<h1>' . PF_TITLE . ': Under Review</h1>'; ?>
				<?php 
					if ($page > 0) {
						$pageNumForPrint = sprintf( __('Page %1$d', 'pf'), $page);
						echo '<span> - ' . $pageNumForPrint . '</span>';
					}
				?>
				<span id="h-after"> &#8226; </span>
				<button class="btn btn-small" id="fullscreenfeed"> <?php  _e('Full Screen', 'pf');  ?> </button>
			</div><!-- End title -->
				<?php pressforward()->admin->pf_search_template(); ?>
		</header><!-- End Header -->
		<div role="main">
			<?php $this->toolbox();	?>	
			<div id="entries">
				<?php echo '<img class="loading-top" src="' . PF_URL . 'assets/images/ajax-loader.gif" alt="Loading..." style="display: none" />';  ?>
				<div id="errors">
					<div class="pressforward-alertbox" style="display:none;">
						<div class="row-fluid">
							<div class="span11 pf-alert">
							</div>
							<div class="span1 pf-dismiss">
							<i class="icon-remove-circle">Close</i>
							</div>
						</div>
					</div>				
				</div>
				<div class="display">
					<div class="btn-group pull-left">
					<!--<button type="submit" id="gogrid" class="btn btn-small">Grid</button>
					<button type="submit" id="golist" class="btn btn-small">List</button>-->

					<?php echo '<button type="submit" class="btn btn-small feedsort" id="sortbyitemdate" value="' . __('Sort by item date', 'pf') . '" >' . __('Sort by item date', 'pf') . '</button>';
					echo '<button type="submit" class="btn btn-small feedsort" id="sortbynomdate" value="' . __('Sort by date nominated', 'pf') . '">' . __('Sort by date nominated', 'pf') . '</button>'; 
					echo '<button type="submit" class="btn btn-small feedsort" id="sortbynomcount" value="' . __('Sort by nominations', 'pf') . '">' . __('Sort by nominations', 'pf') . '</button>'; 
					if (!isset($_GET['pf-see']) || ('archive-only' != $_GET['pf-see'])){
						echo '<button type="submit" class="btn btn-small feedsort" id="showarchiveonly" value="' . __('Show only archived', 'pf') . '">' . __('Show only archived', 'pf') . '</button>'; 
						if (isset($_GET['by']) && ( 'archived' == $_GET['by'])){
							echo '<button type="submit" class="showarchived btn btn-small btn-warning" id="shownormal" value="' . __('Show non-archived', 'pf') . '">' . __('Show non-archived', 'pf') . '.</button>';
						} else {
							echo '<button type="submit" class="showarchived btn btn-small btn-warning" id="showarchived" value="' . __('Show archived', 'pf') . '">' . __('Show archived', 'pf') . '.</button>';
						}
					}
					?>
					</div>
					<div class="pull-right text-right">
					<?php echo '<button type="submit" class="delete btn btn-danger btn-small pull-left" id="archivenoms" value="' . __('Archive all', 'pf') . '" >' . __('Archive all', 'pf') . '</button>'; ?>
					<!-- or http://thenounproject.com/noun/list/#icon-No9479 ? -->
					<a class="btn btn-small" id="gomenu" href="#">Menu <i class="icon-tasks"></i></a>
					</div>
				</div><!-- End btn-group -->
		
		<?php 			

//Hidden here, user options, like 'show archived' etc...
				?><div id="page_data" style="display:none">
					<?php
						$current_user = wp_get_current_user();
						$metadata['current_user'] = $current_user->slug;
						$metadata['current_user_id'] = $current_user_id = $current_user->ID;
					?>
					<span id="current-user-id"><?php echo $current_user_id; ?></span>
					<?php

					?>
				</div>
		<?php
		echo '<div class="row-fluid" class="nom-row">';
#Bootstrap Accordion group
		echo '<div class="span12 nom-container" id="nom-accordion">';
		wp_nonce_field('drafter', 'pf_drafted_nonce', false);
		// Reset Post Data
		wp_reset_postdata();

			//This part here is for eventual use in pagination and then infinite scroll.
			$c = 0;
			$c = $c+$count;
			if ($c < 20) {
				$offset = 0;
			} else {
				$offset = $c;
			}

			//Now we must loop.
			//Eventually we may want to provide options to change some of these, so we're going to provide the default values for now.
			$pageCheck = absint($page);
			if (!$pageCheck){ $pageCheck = 1; }
			
			$nom_args = array(

							'post_type' => 'nomination',
							'orderby' => 'date',
							'order' => 'DESC',
							'posts_per_page' => 20,
							'suppress_filters' => FALSE,
							'offset' => $offset  #The query function will turn page into a 1 if it is a 0. 

							);
			add_filter( 'posts_request', 'prep_archives_query');
			$nom_query = new WP_Query( $nom_args );
			remove_filter( 'posts_request', 'prep_archives_query' );
			#var_dump($nom_query);
			$count = 0;
			$countQ = $nom_query->post_count;
			$countQT = $nom_query->found_posts;
			//print_r($countQ);
			while ( $nom_query->have_posts() ) : $nom_query->the_post();
				
				//declare some variables for use, mostly in various meta roles.
				//1773 in rssforward.php for various post meta.

				//Get the submitter's user slug
				$metadata['submitters'] = $submitter_slug = get_the_author_meta('user_nicename');
				// Nomination (post) ID
				$metadata['nom_id'] = $nom_id = get_the_ID();
				//Get the WP database ID of the original item in the database. 
				$metadata['item_feed_post_id'] = get_post_meta($nom_id, 'item_feed_post_id', true);
				//Number of Nominations recieved.
				$metadata['nom_count'] = $nom_count = get_post_meta($nom_id, 'nomination_count', true);
				//Permalink to orig content
				$metadata['permalink'] = $nom_permalink = get_post_meta($nom_id, 'item_link', true);
				$urlArray = parse_url($nom_permalink);
				//Source Site
				$metadata['source_link'] = isset( $urlArray['host'] ) ? $sourceLink = 'http://' . $urlArray['host'] : '';
				//Source site slug
				$metadata['source_slug'] = $sourceSlug = isset( $urlArray['host'] ) ? pf_slugger($urlArray['host'], true, false, true) : '';
				//RSS Author designation
				$metadata['authors'] = $item_authorship = get_post_meta($nom_id, 'item_author', true);
				//Datetime item was nominated
				$metadata['date_nominated'] = $date_nomed = get_post_meta($nom_id, 'date_nominated', true);
				//Datetime item was posted to its home RSS
				$metadata['posted_date'] = $date_posted = get_post_meta($nom_id, 'posted_date', true);
				//Unique RSS item ID
				$metadata['item_id'] = $rss_item_id = get_post_meta($nom_id, 'origin_item_ID', true);
				//RSS-passed tags, comma seperated.
				$item_nom_tags = $nom_tags = get_post_meta($nom_id, 'item_tags', true);
				$wp_nom_tags = '';
				$getTheTags = get_the_tags();
				if (empty($getTheTags)){
					$getTheTags[] = '';
					$wp_nom_tags = '';
					$wp_nom_slugs[] = '';
				} else {
					foreach ($getTheTags as $tag){
						$wp_nom_tags .= ', ';
						$wp_nom_tags .= $tag->name;
					}
					$wp_nom_slugs = array();
					foreach ($getTheTags as $tag){
						$wp_nom_slugs[] = $tag->slug;
					}				
								
				}
				$metadata['nom_tags'] = $nomed_tag_slugs = $wp_nom_slugs;		
				$metadata['all_tags'] = $nom_tags .= $wp_nom_tags;
				$nomTagsArray = explode(",", $item_nom_tags);
				$nomTagClassesString = '';
				foreach ($nomTagsArray as $nomTag) { $nomTagClassesString .= pf_slugger($nomTag, true, false, true); $nomTagClassesString .= ' '; }
				//RSS-passed tags as slugs.
				$metadata['item_tags'] = $nom_tag_slugs = $nomTagClassesString;
				//All users who nominated.
				$metadata['nominators'] = $nominators = get_post_meta($nom_id, 'nominator_array', true);
				//Number of times repeated in source.
				$metadata['source_repeat'] = $source_repeat = get_post_meta($nom_id, 'source_repeat', true);
				//Post-object tags
				$metadata['item_title'] = $item_title = get_the_title();
				$metadata['item_content'] = get_the_content();
				//UNIX datetime last modified.
				$metadata['timestamp_nom_last_modified'] = $timestamp_nom_last_modified = get_the_modified_date( 'U' );
				//UNIX datetime added to nominations.
				$metadata['timestamp_unix_date_nomed'] = $timestamp_unix_date_nomed = strtotime($date_nomed);
				//UNIX datetime item was posted to its home RSS.
				$metadata['timestamp_item_posted'] = $timestamp_item_posted = strtotime($date_posted);
				$metadata['archived_status'] = $archived_status = get_post_meta($nom_id, 'archived_by_user_status');
				$userObj = wp_get_current_user();
				$user_id = $userObj->ID;
				
				
				if (!empty($metadata['archived_status'])){
					$archived_status_string = '';
					$archived_user_string_match = 'archived_' . $current_user_id;
					foreach ($archived_status as $user_archived_status){
						if ($user_archived_status == $archived_user_string_match){
							$archived_status_string = 'archived';
							$dependent_style = 'display:none;';
						}
					}
				} elseif ( 1 == pf_get_relationship_value( 'archive', $nom_id, $user_id)) {
					$archived_status_string = 'archived';
					$dependent_style = 'display:none;';
				} else {
					$dependent_style = '';
					$archived_status_string = '';
				}
			$item = pf_feed_object(get_the_title(), get_post_meta($nom_id, 'source_title', true), $date_posted, $item_authorship, get_the_content(), $nom_permalink, get_the_post_thumbnail($nom_id /**, 'nom_thumb'**/), $rss_item_id, get_post_meta($nom_id, 'item_wp_date', true), $nom_tags, $date_nomed, $source_repeat, $nom_id, '1');
			
			$this->form_of_an_item($item, $c, 'nomination', $metadata);
/**			
			echo '<article class="feed-item entry nom-container ' . $archived_status_string . pf_nom_class_tagger(array($submitter_slug, $nom_id, $item_authorship, $nom_tag_slugs, $nominators, $nomed_tag_slugs, $rss_item_id )) . '" id="' . get_the_ID() . '" style="' . $dependent_style . '" tabindex="' . $c . '">'; ?>
					<header>
						<?php echo '<h1 class="item_title"><a href="#modal-' . get_the_ID() . '" class="item-expander" role="button" data-toggle="modal" data-backdrop="false">' . get_the_title() . '</a></h1>'; ?>
						<div class="sortable-hidden-meta" style="display:none;">
							<?php
							_e('UNIX timestamp from source RSS', 'pf');
							echo ': <span class="sortable_source_timestamp">' . $timestamp_item_posted . '</span><br />';

							_e('UNIX timestamp last modified', 'pf');
							echo ': <span class="sortable_mod_timestamp">' . $timestamp_nom_last_modified . '</span><br />';

							_e('UNIX timestamp date nominated', 'pf');
							echo ': <span class="sortable_nom_timestamp">' . $timestamp_unix_date_nomed . '</span><br />';

							_e('Times repeated in source feeds', 'pf');
							echo ': <span class="sortable_sources_repeat">' . $source_repeat . '</span><br />';

							_e('Number of nominations received', 'pf');
							echo ': <span class="sortable_nom_count">' . $nom_count . '</span><br />';

							_e('Slug for origon site', 'pf');
							echo ': <span class="sortable_origin_link_slug">' . $sourceSlug . '</span><br />';

							//Add an action here for others to provide additional sortables.

						echo '</div>';

						$urlArray = parse_url($item['item_link']);
						$sourceLink = 'http://' . $urlArray['host'];
						//http://nicolasgallagher.com/pure-css-speech-bubbles/demo/
						$ibox = '<div class="feed-item-info-box" id="info-box-' . $item['item_id'] . '">';
						$ibox .= '
							' . __('Feed', 'pf') . ': <span class="feed_title">' . $item['source_title'] . '</span><br />
							' . __('Posted', 'pf') . ': <span class="feed_posted">' . date( 'M j, Y; g:ia' , strtotime($item['item_date'])) . '</span><br />
							' . __('Retrieved', 'pf') . ': <span class="item_meta item_meta_added_date">' . date( 'M j, Y; g:ia' , strtotime($item['item_added_date'])) . '</span><br />
							' . __('Authors', 'pf') . ': <span class="item_authors">' . $item['item_author'] . '</span><br />
							' . __('Origin', 'pf') . ': <span class="source_name"><a target ="_blank" href="' . $sourceLink . '">' . $sourceLink . '</a></span><br />
							' . __('Original Item', 'pf') . ': <span class="source_link"><a href="' . $item['item_link'] . '" class="item_url" target ="_blank">' . $item['item_title'] . '</a></span><br />
							' . __('Tags', 'pf') . ': <span class="item_tags">' . $item['item_tags'] . '</span><br />
							' . __('Times repeated in source', 'pf') . ': <span class="feed_repeat">' . $item['source_repeat'] . '</span><br />
							';
						$ibox .= '</div>';
						echo $ibox;						
						?>			
			<div class="span12" id="item-box-<?php echo $count; ?>">
				<div class="row-fluid well accordion-group nom-item<?php pf_nom_class_tagger(array($submitter_slug, $nom_id, $item_authorship, $nom_tag_slugs, $nominators, $nomed_tag_slugs, $rss_item_id )); ?>" id="<?php echo $count; ?>">
					<div class="span12">

						<div class="sortable-hidden-meta" style="display:none;">
							<?php
							_e('UNIX timestamp from source RSS', 'pf');
							echo ': <span class="sortable_source_timestamp">' . $timestamp_item_posted . '</span><br />';

							_e('UNIX timestamp last modified', 'pf');
							echo ': <span class="sortable_mod_timestamp">' . $timestamp_nom_last_modified . '</span><br />';

							_e('UNIX timestamp date nominated', 'pf');
							echo ': <span class="sortable_nom_timestamp">' . $timestamp_unix_date_nomed . '</span><br />';

							_e('Times repeated in source feeds', 'pf');
							echo ': <span class="sortable_sources_repeat">' . $source_repeat . '</span><br />';

							_e('Number of nominations received', 'pf');
							echo ': <span class="sortable_nom_count">' . $nom_count . '</span><br />';

							_e('Slug for origon site', 'pf');
							echo ': <span class="sortable_origin_link_slug">' . $sourceSlug . '</span><br />';

							//Add an action here for others to provide additional sortables.

						echo '</div>';
						echo '<div class="row-fluid nom-content-container accordion-heading">';
							echo '<div class="span12">';
								echo '<a class="accordion-toggle" data-toggle="collapse" data-parent="#nom-accordion" href="#collapse' . $count . '" count="' . $count . '" style="display:block;">';
								//Figure out feature image later. Put it here when you do.
								echo '<div class="row-fluid span12">';
								remove_filter('get_the_excerpt', 'wp_trim_excerpt');
								add_filter( 'get_the_excerpt', 'pf_noms_excerpt' );
									echo '<h6 class="nom-title">' . get_the_title() . '</h6>';
									?>
									<div class="excerpt-graf" id="excerpt-graf-<?php echo $count; ?>">
										<?php print_r( get_the_excerpt() ); ?>
									</div>
									<?php
								remove_filter( 'get_the_excerpt', 'pf_noms_excerpt' );
								add_filter('get_the_excerpt', 'wp_trim_excerpt');
								echo '</div>';

								echo '</a>';
							echo '</div>';
						echo '</div>';
						echo '<div class="accordion-body collapse" id="collapse' . $count . '">';
						echo '<div class="accordion-inner">';
								echo '<div class="row-fluid span12 authorship-info">';
									$author_string = sprintf(__('Authored by %1$d on %2$d', 'pf'), $item_authorship, $date_posted);
									echo '<h6>' . $author_string . '</h6>';
									if ($nom_count > 1){
										$nomersArray = explode(',',$nominators);
										$userString = "";
										foreach ($nomersArray as $nomer){
											$userObj = get_userdata($nomer);
											$userString .= $userObj->user_nicename;
										}
										$nominators = $userString;
									} else {
										$userObj = get_userdata($nominators);
										$nominators = $userObj->user_nicename;
									}
									$nom_by_string = sprintf(__('Nominated by %1$d on %2$d', 'pf'), $nominators, date('Y-m-d', strtotime($date_nomed)));;
									echo '<h6>' . $nom_by_string . '</h6>';
								echo '</div>
										<div class="nom-content-body row-fluid span12">';
											the_content();
									echo '</div>';
								//echo '<div class="item_commenting">';
								//comment_form();
								//echo '</div>';
								do_action('append_to_under_review_accordion');
						echo '</div>';
						echo '</div>';
					echo '</div>';

				echo '</div>';
			echo '</div>';

			echo '<div class="post-control span3 well" id="action-box-' . $count . '" style="display:none;">';
											?>
									<div class="nom-master-buttons row-fluid">
										<div class="span12">
											<div class="result-status-<?php echo $rss_item_id; ?>">
												<?php echo '<img class="loading-' . $rss_item_id . '" src="' . PF_URL . 'assets/images/ajax-loader.gif" alt="' . __('Loading', 'pf') . '..." style="display: none" />'; ?>
												<div class="msg-box"></div>
											</div>
											<form name="form-<?php echo $rss_item_id; ?>" id="<?php echo $rss_item_id ?>"><p>
												<?php pf_prep_item_for_submit($metadata); ?>
												<button class="btn btn-inverse nom-to-draft" form="<?php echo $rss_item_id ?>"><?php _e('Send to Draft', 'pf'); ?></button>
												<button class="btn btn-inverse nom-to-archive" form="<?php echo $nom_id ?>"><?php _e('Archive', 'pf'); ?></button>
															<?php $tax = get_taxonomy( 'category' ); ?>

			<div id="tagsdiv-post_tag" class="postbox">
				<div class="handlediv" title="<?php esc_attr_e( 'Click to toggle', 'pf' ); ?>"><br /></div>
				<h3><span><?php _e('Tags'); ?></span></h3>
				<div class="inside">
					<div class="tagsdiv" id="post_tag">
						<div class="jaxtag">
							<label class="screen-reader-text" for="newtag"><?php _e('Tags'); ?></label>
							<input type="hidden" name="tax_input[post_tag]" class="the-tags" id="tax-input[post_tag] tag_input_<?php echo $rss_item_id; ?>" value="" />
							<div class="ajaxtag">
								<input type="text" name="newtag[post_tag]" class="newtag form-input-tip" size="16" autocomplete="off" value="" />
								<input type="button" class="button tagadd" value="<?php esc_attr_e('Add', 'pf'); ?>" tabindex="3" />
							</div>
						</div>
						<div class="tagchecklist"></div>
					</div>
					<p class="tagcloud-link"><a href="#titlediv" class="tagcloud-link" id="link-post_tag"><?php _e('Choose from the most used tags', 'pf'); ?></a></p>
				</div>
			</div>

											</form>
										</div>
									</div>
									<?php
			echo '</div>';
					?>
			</div>
			<?php
**/			
			$count++;
			$c++;
			endwhile;

		// Reset Post Data
		wp_reset_postdata();
		echo '</div><!-- End entries -->';

	echo '</div><!-- End main -->';
	if ($countQT > $countQ){
		//Nasty hack because infinite scroll only works starting with page 2 for some reason.
		if ($page == 0){ $page = 1; }
		$pagePrev = $page-1;
		$pageNext = $page+1;
		echo '<div class="pf-navigation">';
		if ($pagePrev > -1){
			echo '<span class="feedprev"><a class="prevnav" href="admin.php?page=pf-review&pc=' . $pagePrev . '">Previous Page</a></span> | ';
		}
		echo '<span class="feednext"><a class="nextnav" href="admin.php?page=pf-review&pc=' . $pageNext . '">Next Page</a></span>';
		echo '</div>';
	}
echo '</div><!-- End container-fluid -->';


?>
