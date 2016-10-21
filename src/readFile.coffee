class readFile
	reader = new FileReader()
	progress = document.querySelector('.percent')
	Biom = require('biojs-io-biom').Biom;

	constructor: () ->
		db.open(
			server: "BiomData", version: 1,
			schema:
				"biom": key: keyPath: 'id', autoIncrement: true,
		).done( (s) =>
			@server = s
			@listRecentFiles()
		)

		document.querySelector('#parse').addEventListener('click', (evt) => 
			if evt.target.tagName.toLowerCase() == 'button'
				files = document.getElementById('files').files
				@checkFile(files)
		false)

		# Load by URL, requires CORS at remote server
		query = window.location.search.substring(1)
		raw_vars = query.split("&")
		params = {}
		for v in raw_vars
			[key, val] = v.split("=")
			params[key] = decodeURIComponent(val)
		if params['biomURL']?
			$('#loadTestFile').hide()
			$('#fileDrag').hide()
			$('#progress_bar').hide()
			$('#frmUpload').hide()
			$('#parse').html('loading URL...&nbsp;&nbsp;<i class="icon-spinner icon-spin icon-large"></i>');
			$.get(params['biomURL'], (urlData) =>
				if urlData.constructor != String
					urlData = JSON.stringify( urlData )
				biomToStore = {}
				biomToStore.name = params['biomURL']
				biomToStore.size = urlData.length
				biomToStore.data = urlData
				d = new Date();
				biomToStore.date = d.getUTCFullYear() + "-" + (d.getUTCMonth() + 1) + "-" + d.getUTCDate() + "T" + d.getUTCHours() + ":" + d.getUTCMinutes() + ":" + d.getUTCSeconds() + " UTC"
				@server.biom.add(biomToStore).done () ->
					setTimeout( "window.location.href = 'preview.html'", 1)
			)


		# load test file
		document.getElementById('loadTestFile').addEventListener('click', (evt) =>
			$('#loadTestFile').html('loading...&nbsp;&nbsp;<i class="icon-spinner icon-spin icon-large"></i>');
			hostURL = '//' + window.location.host + window.location.pathname.substr(0, window.location.pathname.lastIndexOf('/'))
			testfile = hostURL + '/data/testdata.biom'  ## Dev TODO http://phinch.org/data/testdata.biom
			$.get(testfile, (testdata) => 
				if testdata.constructor != String
					testdata = JSON.stringify( testdata )
				biomToStore = {}
				biomToStore.name = 'testdata.biom'
				biomToStore.size = testdata.length
				biomToStore.data = testdata
				d = new Date();
				biomToStore.date = d.getUTCFullYear() + "-" + (d.getUTCMonth() + 1) + "-" + d.getUTCDate() + "T" + d.getUTCHours() + ":" + d.getUTCMinutes() + ":" + d.getUTCSeconds() + " UTC"
				@server.biom.add(biomToStore).done () ->
					setTimeout( "window.location.href = 'preview.html'", 2000)
			)
		false)

		# handles file selection / uploading
		document.getElementById('files').addEventListener('change', @handleFileSelect, false)
		fileDrag = document.getElementById('fileDrag')
		fileDrag.addEventListener('dragover', @dragFileProc, false)
		fileDrag.addEventListener('dragleave', @dragFileProc, false)
		fileDrag.addEventListener('drop', @dragFileProc, false)
		fileDrag.addEventListener('drop', @handleFileSelect, false)

	checkFile: (files) ->
		if files.length == 0
			alert "Please select a file!"
		else 	
			@readBlob(files[0])

	handleFileSelect: (evt) =>
		progress.style.width = '0%'
		reader.onerror = @errorHandler
		reader.onprogress = @updateProgress
		reader.onabort = (e) -> alert "File loading cancelled!" 
		reader.onloadstart = (e) -> document.getElementById('progress_bar').className = 'loading'
		reader.onload = (e) -> 
			progress.style.width = '100%'
			setTimeout("document.getElementById('progress_bar').className='';", 8000) 

	errorHandler: (evt) -> 
		switch evt.target.error.code 
			when evt.target.error.NOT_FOUND_ERR then alert "File Not Found!" 
			when evt.target.error.NOT_READABLE_ERR then alert "File Not Readable!" 
			else alert "File Not Readable!"

	updateProgress: (evt) -> 
		if evt.lengthComputable
			percentLoaded = Math.round((evt.loaded / evt.total) * 100)
			if percentLoaded < 100 
				progress.style.width = percentLoaded + '%'

	dragFileProc: (evt) => 
		evt.stopPropagation()
		evt.preventDefault()
		switch evt.type
			when 'dragover'  then $('#fileDrag').addClass('hover')
			when 'dragleave' then $('#fileDrag').removeClass('hover')
			when 'drop'
				$('#fileDrag').removeClass('hover')
				files = evt.target.files || evt.dataTransfer.files
				@checkFile(files)

	# store new biom file to the browser indexeddb
	readBlob: (file) =>
		reader.onloadend = (evt) =>
			if evt.target.readyState == FileReader.DONE
				# JSON.parse(reader.result)
				Biom.parse('', {conversionServer: 'server/convert.php', arrayBuffer: evt.target.result}).then(
					(biom) =>
						biomToStore = {}
						biomToStore.name = file.name
						biomToStore.size = file.size
						biom.write().then(
							(biomData) =>
								biomToStore.data = biomData
								d = new Date();
								biomToStore.date = d.getUTCFullYear() + "-" + (d.getUTCMonth() + 1) + "-" + d.getUTCDate() + "T" + d.getUTCHours() + ":" + d.getUTCMinutes() + ":" + d.getUTCSeconds() + " UTC"
								console.log @
								@server.biom.add(biomToStore).done (item) =>
									@currentData = item
									setTimeout( "window.location.href = 'preview.html'", 2000)
						)
					(fail) =>
						alert "Error loading biom file!"
				)
		reader.readAsArrayBuffer(file)

	# list 10 most recent files uploaded to this browser
	listRecentFiles: () => 
		@server.biom.query().all().execute().done (results) =>
			if results.length > 0
				for p in [0..results.length-1]
					if results[p].name == "testdata.biom"
						@server.biom.remove(results[p].id).done # () -> console.log 'remove '
						results.splice(p,1)

				if results.length > 10
					@clearOldEntries(results)
						
				if results.length > 0
					$('#recent').show()
					@currentData = results
					content = "<table id='recent_data'>"
					for k in [0..results.length-1]
						tk = results.length - 1 - k
						content += '<tr><td class="reload" id="reload_' + k + '">LOAD' + '</td><td>' 
						content += results[tk].name.substring(0,55) + '</td><td>' + (results[tk].size / 1000000).toFixed(1) + " MB" + '</td><td>' + results[tk].date
						content += '</td><td class="del" id="del_' + k + '"><i class="icon-fa-times icon-large"></i></td></tr>'
					content += "</table>"
					$("#recent").append(content)
					for k in [0..results.length-1]
						$('#reload_' + k).click( @reloadRow )
						$('#del_' + k).click( @removeRow )

	# allows users to reload old files 
	reloadRow: (evt) =>
		i = @currentData.length - 1 - evt.currentTarget.id.replace("reload_","") # reverse order id 
		biomToStore = {}
		biomToStore.name = @currentData[i].name
		biomToStore.size = @currentData[i].size
		biomToStore.data = @currentData[i].data
		d = new Date();
		biomToStore.date = d.getUTCFullYear() + "-" + (d.getUTCMonth() + 1) + "-" + d.getUTCDate() + "T" + d.getUTCHours() + ":" + d.getUTCMinutes() + ":" + d.getUTCSeconds() + " UTC"
		@server.biom.add(biomToStore).done (item) -> 
			@currentData = item
			setTimeout( "window.location.href = 'preview.html'", 1000)

	# allows users to remove certain files
	removeRow: (evt) =>
		i = evt.currentTarget.id
		totalrows = $('#recent_data tr .del').length
		for k in [0..totalrows-1] 
			if i == $('#recent_data tr .del')[k].id
				console.log @currentData[totalrows - k - 1].id
				@server.biom.remove( @currentData[totalrows - k - 1].id ).done () -> 
					location.reload(true);
	
	# leave only 10 files, remove older files
	clearOldEntries: (results) =>
		console.log results.length
		if results.length > 10
			@server.biom.remove(results[0].id).done () =>
				results.splice(0,1)
				location.reload(true);
				
window.readFile = readFile
