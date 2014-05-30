importScripts('../lib/lz-string-1.3.3.js')
self.addEventListener('message', (e) ->
	out = LZString.decompressFromBase64(e.data)
	self.postMessage(out)
)