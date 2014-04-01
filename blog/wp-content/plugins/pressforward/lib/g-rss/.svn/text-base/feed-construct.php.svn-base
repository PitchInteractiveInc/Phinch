<html>
<head>
<script type="text/javascript" src="http://www.google.com/jsapi">
</script>

<script type="text/javascript" src="gfeedfetcher.js">

/***********************************************
* gAjax RSS Feeds Displayer- (c) Dynamic Drive (www.dynamicdrive.com)
* This notice MUST stay intact for legal use
* Visit http://www.dynamicdrive.com/ for full source code
***********************************************/

</script>

<style type="text/css">

.labelfield{ /*CSS for label field in general*/
color:brown;
font-size: 90%;
}

.datefield{ /*CSS for date field in general*/
color:gray;
font-size: 90%;
}

#example1 li{ /*CSS specific to demo 1*/
margin-bottom: 4px;
}

#example2 div{ /*CSS specific to demo 2*/
margin-bottom: 5px;
}

#example2 div a{ /*CSS specific to demo 2*/
text-decoration: none;
}

#example3 a{ /*CSS specific to demo 3*/
color: #D80101;
text-decoration: none;
font-weight: bold;
}

#example3 p{ /*CSS specific to demo 3*/
margin-bottom: 2px;
}

code{ /*CSS for insructions*/
color: red;
}

</style>

</head>
<body>

<h3>Example 1: (Single RSS feed, 10 entries, "<code>date</code>" field enabled, sort by <code>title</code>)</h3>

<script type="text/javascript">

var cssfeed=new gfeedfetcher("example1", "example1class", "")
cssfeed.addFeed("CSS Drive", "http://www.cssdrive.com/index.php/news/rss_2.0/") //Specify "label" plus URL to RSS feed
cssfeed.displayoptions("date") //show the specified additional fields
cssfeed.setentrycontainer("li") //Display each entry as a list (li element)
cssfeed.filterfeed(10, "title") //Show 10 entries, sort by date
cssfeed.init() //Always call this last

</script>

<br /><br />



<h3>Example 2: (Two RSS feeds, 6 entries, "<code>label"</code>, "<code>datetime</code>", and "<code>snippet</code>" fields enabled, sort by <code>label</code>)</h3>

<script type="text/javascript">

var socialfeed=new gfeedfetcher("example2", "example2class", "_new")
socialfeed.addFeed("Slashdot", "http://rss.slashdot.org/Slashdot/slashdot") //Specify "label" plus URL to RSS feed
socialfeed.addFeed("Digg", "http://digg.com/rss/index.xml") //Specify "label" plus URL to RSS feed
socialfeed.displayoptions("label datetime snippet") //show the specified additional fields
socialfeed.setentrycontainer("div") //Display each entry as a DIV
socialfeed.filterfeed(6, "label") //Show 6 entries, sort by label
socialfeed.init() //Always call this last

</script>

<br /><br />



<h3>Example 3: (Three RSS feeds, 8 entries, "<code>datetime</code>" and "<code>snippet</code>" fields enabled, sort by <code>date</code>)</h3>

<script type="text/javascript">

var newsfeed=new gfeedfetcher("example3", "example3class", "_new")
newsfeed.addFeed("BBC", "http://newsrss.bbc.co.uk/rss/newsonline_uk_edition/front_page/rss.xml") //Specify "label" plus URL to RSS feed
newsfeed.addFeed("MSNBC", "http://www.msnbc.msn.com/id/3032091/device/rss/rss.xml") //Specify "label" plus URL to RSS feed
newsfeed.addFeed("Yahoo News", "http://rss.news.yahoo.com/rss/topstories") //Specify "label" plus URL to RSS feed
newsfeed.displayoptions("datetime snippet") //show the specified additional fields
newsfeed.setentrycontainer("p", "pclass") //Display each entry as a paragraph, and add a "pclass" class to each P
newsfeed.filterfeed(8, "date") //Show 8 entries, sort by date
newsfeed.init() //Always call this last

</script>

<h2>My example</h3>
<script type="text/javascript">

<?php
$feedlist = array(
	
	array(
		'title' => 'HackText', 
		'url' => 'http://hacktext.com',
		'folder' => 'narrative design'
		),
	array(
		'title' => 'CHNM Home',
		'url' => 'http://chnm.gmu.edu',
		'folder' => 'Higher Ed'
		),
	array(
		'title' => 'GMU News',
		'url' => 'http://newsdesk.gmu.edu',
		'folder' => 'Higher Ed'
		),
	array(
		'title' => 'CNN',
		'url' => 'http://cnn.com',
		'folder' => '',
		)
	);
?>

var feednewsfeed=new gfeedfetcher("prime", "feedlist-class", "_blank");

<?php
foreach ($feedlist as $feeditem){
	echo 'feednewsfeed.addFeed("' . $feeditem['title'] . '", "' . $feeditem['url'] . '");'; //Specify "label" plus URL to RSS feed
}
?>

feednewsfeed.displayoptions("datetime snippet label snippet description"); //show the specified additional fields
feednewsfeed.setentrycontainer("div", "well accordion-group feed-item row-fluid");

<?php

$gencode = '
				<div class="well accordion-group feed-item row-fluid" id="{id}">
					<div class="span12" id="{count}">
						<div class="feed-item-info-box well leftarrow" id="info-box-{id}" style="display:none;">
								Feed: <span class="feed_title">{title}</span><br />
								Posted on: <span class="feed_posted">{datetime}</span><br />
								Authors: <span class="item_authors">{authors}</span><br />
								Origin: <span class="source_name"><a target ="_blank" href="{urlbase}">{urlbase}</a></span><br />
								Original Item: <span class="source_link"><a href="{url}" target ="_blank">{url}</a></span><br />
								Tags: <span class="item_tags">{label}</span><br />
								Times repeated in source: <span class="feed_repeat">{sourcerepeat}</span><br />
						</div>
						<div class="row-fluid accordion-heading">
							<a class="accordion-toggle" data-toggle="collapse" data-parent="#feed-accordion" href="#collapse{count}">
								<div class="span1">
									<div style="float:left; margin: 10px auto;">
										<div class="thumbnail">
											{featimg}
										</div>
									</div>
								</div><!-- End span1 -->
								<div class="span10">
									1. <span class="source_title">{feedurl}</span> : 
									<h3>{title}</h3>
									<div class="item_meta item_meta_date">{datetime} by {authors}.</div>
									<div style="display:none;">Unix timestamp for item date:<span class="sortableitemdate">{datetime}</span> and for added to RSS date <span class="sortablerssdate">{addeddatetime}</span>.</div>
									<div class="item_excerpt" id="excerpt{count}">
										{excerpt} ...
									</div>
								</div><!-- End span8 or 10 -->
							</a>
							<div class="span{count}">
								<button class="btn btn-small itemInfobutton" id="i-{id}"><i class="icon-info-sign"></i></button>
							</div>
						</div><!-- End row-fluid -->
						<div id="collapse{count}" class="accordion-body collapse">
							<div class="accordion-inner">
								<div class="row-fluid">
									<div class="span12 item_content">
										<div>
											{content}
										</div><br>
										<a target="_blank" href="{url}">Read More</a><br>
										<strong class="item-tags">Item Tags</strong>: {label}<br>
									</div><!-- end item_content span12 -->
								</div><!-- End row-fluid -->
								<div class="item_actions row-fluid">
									<div class="span12">
										<form name="form-{id}">
											<p>
												<input type="hidden" name="item_title" id="item_title_{id}" value="{escpedcontent}">
												<input type="hidden" name="item_link" id="item_link_{id}" value="{url}">
												<input type="hidden" name="item_feat_img" id="item_feat_img_{id}" value="{featimglink}">
												<input type="hidden" name="item_id" id="item_id_{id}" value="{id}">
												<input type="hidden" name="item_wp_date" id="item_wp_date_{id}" value="{yyyy}-{mm}-{dd}">
												<input type="hidden" name="item_tags" id="item_tags_{id}" value="{label}">
												<input type="hidden" name="item_added_date" id="item_added_date_{id}" value="{addeddate}">
												<input type="hidden" name="source_repeat" id="source_repeat_dabe225b933be76cd0233cc36ec5fd23" value="{repeat}">
												<input type="hidden" id="pf_nomination_nonce" name="pf_nomination_nonce" value="035950e4ef">
												<input type="submit" class="PleasePushMe" id="{id}" value="Nominate">
												</p>
											<div class="nominate-result-{id}">
												<img class="loading-{id}" src="http://localhost:8080/xampp/wordpress/wp-content/plugins/rss-to-pressforward/assets/images/ajax-loader.gif" alt="Loading..." style="display: none">
											</div>
											<p></p>
										</form>
									</div><!-- End accordion Inner -->
								</div><!-- End accordion body -->
							</div>
						</div>
					</div><!-- End span12 -->
				</div>
			';
			?>
feednewsfeed.definetemplate('<?php echo $gencode; ?>');
feednewsfeed.filterfeed(10, "date") //Show 8 entries, sort by date
feednewsfeed.init() //Always call this last	
								jQuery(window).load(function() {
									jQuery("#{id}").on("show", function () {
										jQuery("#excerpt1").hide("slow");
									});
									
									jQuery("#{id}").on("hide", function () {
										jQuery("#excerpt1").show("slow");
									});
								});				

</script>
</body>
</html>