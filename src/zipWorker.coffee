importScripts('../lib/jszip.min.js')
importScripts('../lib/lz-string-1.3.3.js')
self.addEventListener('message', (e) ->
  data = e.data
  out = LZString.compressToBase64(data)
  self.postMessage(out)

)