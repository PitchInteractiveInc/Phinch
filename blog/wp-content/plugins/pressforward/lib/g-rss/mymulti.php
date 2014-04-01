<html>
<head>
<style type="text/css">
	body { font-family: 'trebuchet ms'; color: #555; font-size: small; }
	div.feed { margin: 20px; padding: 20px; border: 1px dashed #ddd;
	background: #ffd }
	div.date { font-size: smaller; color: #aaa }
	h1.blog { font-size: large; padding: 5px; margin: 2px 0; text-align: center }
	h2.feed { font-size: medium; padding: 0; margin: 2px 0 }
</style>
<script src="http://ajax.googleapis.com/ajax/libs/jquery/1.8.3/jquery.min.js"></script>
<script type="text/javascript" src="http://www.google.com/jsapi"></script>
<script type="text/javascript" src="jquery.tinysort.js"></script>
</head>
<body>
<h2>My feedery</h3>
<script type="text/javascript">
google.load("feeds", "1");
<?php
$feedlist = array(
	
	array(
		'title' => 'HackText', 
		'url' => 'http://feeds.feedburner.com/ReadWriteView',
		'folder' => 'narrative design'
		),
	array(
		'title' => 'CHNM Home',
		'url' => 'http://chnm.gmu.edu/news/feed',
		'folder' => 'Higher Ed'
		),
	array(
		'title' => 'GMU News',
		'url' => 'http://newsdesk.gmu.edu/feed',
		'folder' => 'Higher Ed'
		),
	array(
		'title' => 'CNN',
		'url' => 'http://cnn.com',
		'folder' => '',
		)
	);
$c = 0;
$count = count($feedlist);
foreach ($feedlist as $feed){
	//http://stackoverflow.com/questions/5618925/convert-php-array-to-javascript-array
	//$js_array = json_encode($feed);
	//echo 'var feed' . $c . ' = '. $js_array . ';\n';
	
	echo 'google.setOnLoadCallback(showFeed' . $c . ');';
	echo 'function showFeed' . $c . '() {
		var feed' . $c . ' = new google.feeds.Feed("' . $feed['url'] . '");
		feed' . $c . '.setNumEntries(50);
		feed' . $c . '.includeHistoricalEntries();';
		?>
		feed<?php echo $c; ?>.load(function(result) {
			console.log(result);
			if (!result.error) {
				var container = document.getElementById("headlines");
				for (var i=0; i < result.feed.entries.length; i++) {
					var entry = result.feed.entries[i];
					var li = document.createElement("li");
					li.innerHTML = '<h3><a href="' + entry.link + '">' + entry.title + '</a>' + ' <cite>by ' + entry.author + '</cite></h3>';
						var timestamp = new Date(entry.publishedDate).getTime();
					li.innerHTML += '<h6>Published on <span class="pubdate">' + timestamp + '</span></h6>';
					li.innerHTML += '<h6>Real date pub on <span class="realdate">' + entry.publishedDate + '</span></h6>';
					li.innerHTML += '<p>' + entry.contentSnippet + '</p>';
					//li.innerHTML += '<p class="content-full">' + entry.content + '</p>';
					container.appendChild(li);
				
				}
			} else {
				var container<?php echo $c; ?> = document.getElementById("headlines");
				<?php
					echo 'container' . $c . '.innerHTML += "<li><a href=\"' . $feed['url'] . '\">' . $feed['title'] . '</a></li>";';
				?>
			}
			//There has got to be a way to get this to trigger only after completion right? Figure it out.
			jQuery("li").tsort("span.pubdate", {order:'desc'});
		});
		
	}
	
	<?php	

$c++;	
	if ($c == 100){
		?>
			jQuery(window).load(function(){
				jQuery("li").tsort("span.pubdate");
			});
			alert('Sorted');
		<?php		
	}
}
	
?>
</script>
<h1>Google Feed Loader Example</h1>
	<ul id="headlines"></ul> 
</body>
<!--
<script type="text/javascript" defer="defer">
jQuery(window).load(function(){
	jQuery("#headlines").ajaxStop(function(){
		jQuery("ul#headlines>li").tsort("span.pubdate");
		alert('Sorted');
	});
});
			
</script>
-->
</html>