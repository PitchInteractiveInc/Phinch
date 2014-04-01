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
<script type="text/javascript">
	google.load("feeds", "1");
	google.setOnLoadCallback(function() {
		var sites = [
			'http://jquery.com/blog/feed/',
			'http://feeds.feedburner.com/JohnResig',
			'http://bassistance.de/feed/',
			'http://www.stilbuero.de/feed/atom/',
			'http://www.learningjquery.com/feed/',
			'http://www.reybango.com/rss.cfm',
			'http://feeds.feedburner.com/WebDeveloperBlog'
		];
		jQuery.each(sites, function(j,site) {
		var feed = new google.feeds.Feed(site);
			feed.load(function(result) {
				if (!result.error) {
					var max = Math.min(result.feed.entries.length, 5);
					// 5 at most
					var f = $('<div class="feed"></div>').appendTo('body');
					f.append('<h1 class="blog">'+result.feed.title+'</h1>');
					for (var i = 0; i < max; i++) {
						var entry = result.feed.entries[i];
						var title = entry.title;
						var snip = entry.contentSnippet;
						var link = entry.link;
						var date = entry.publishedDate;
						f.append('<h2 class="feed"><a href="'+link+'">'+title+'</a></h2>')
							.append('<div class="date">'+date+'</div>')
							.append('<div class="snip">'+snip+'</div> ');
					}
				}
			});
		});
	});
</script>
</head>
<body></body>
</html>