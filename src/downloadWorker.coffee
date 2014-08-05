# Webworkder for generating a zip package, including biom file and log json file
importScripts('../lib/jszip.min.js')
self.addEventListener('message', (e) ->
	filename = e.data.filename
	zip = new JSZip();
	zip.file( filename + ".biom", e.data.o1);
	zip.file( filename + "_log.json", e.data.o2);
	content = zip.generate({type:"blob"});
	self.postMessage(content)
)