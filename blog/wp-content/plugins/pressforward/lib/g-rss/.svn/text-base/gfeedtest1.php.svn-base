<html>
<head>
<script type="text/javascript" src="https://www.google.com/jsapi"></script>  
<script type="text/javascript">
	google.load("feeds", "1");
	google.setOnLoadCallback(showFeed);
	function showFeed() {
		var feed = new google.feeds.Feed("http://www.sitepoint.com/feed/");
		feed.setNumEntries(10);
		feed.includeHistoricalEntries();
		
		feed.load(function(result) {
			if (!result.error) {
				var container = document.getElementById("headlines");
				for (var i=0; i < result.feed.entries.length; i++) {
					var entry = result.feed.entries[i];
					var li = document.createElement("li");
					li.innerHTML = '<h3><a href="' + entry.link + '">' + entry.title + '</a>' + ' <cite>by ' + entry.author + '</cite></h3>';
					li.innerHTML += '<p>' + entry.contentSnippet + '</p>';
					container.appendChild(li);
				}
			} else {
				var container = document.getElementById("headlines");
				container.innerHTML = '<li><a href="http://sitepoint.com">SitePoint</a></li>';
			}
		});
		
	}
</script>
</head>
<body>
<h1>Google Feed Loader Example</h1>
	<ul id="headlines"></ul> 
</body>
</html>