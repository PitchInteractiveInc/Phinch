# Webworker for encoding the file, using md5
importScripts('../lib/md5.js')
self.addEventListener('message', (e) ->
	data = e.data
	output = CryptoJS.MD5(data).toString()
	self.postMessage(output)
)