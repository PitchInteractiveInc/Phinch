class readFile
	reader = new FileReader()
	progress = document.querySelector('.percent')

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

		# load test file
		document.getElementById('loadTestFile').addEventListener('click', (evt) =>
			$('#loadTestFile').html('loading...&nbsp;&nbsp;<i class="icon-spinner icon-spin icon-large"></i>');
			hostURL = 'http://' + window.location.host + window.location.pathname.substr(0, window.location.pathname.lastIndexOf('/'))
			testfile = hostURL + '/data/testdata.biom'  ## Dev TODO http://phinch.org/data/testdata.biom
			$.get(testfile, (testdata) => 
				biomToStore = {}
				biomToStore.name = 'testdata.biom'
				biomToStore.size = 15427024
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
			filetype = files[0].name.split("").reverse().join("").split(".")[0].toLowerCase()
			acceptable_filetype = ["moib",  "txt"]
			if acceptable_filetype.indexOf(filetype) == -1
				alert "Please upload .biom or or .txt file!"
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
				biomToStore = {}
				biomToStore.name = file.name
				biomToStore.size = file.size
				biomToStore.data = evt.target.result
				d = new Date();
				biomToStore.date = d.getUTCFullYear() + "-" + (d.getUTCMonth() + 1) + "-" + d.getUTCDate() + "T" + d.getUTCHours() + ":" + d.getUTCMinutes() + ":" + d.getUTCSeconds() + " UTC"
				console.log @
				if JSON.parse(biomToStore.data).format.indexOf("Biological Observation Matrix") != -1
					@server.biom.add(biomToStore).done (item) => 
						@currentData = item
						setTimeout( "window.location.href = 'preview.html'", 2000)
				else 
					alert "Incorrect biom format field! Please check your file content!"
		reader.readAsBinaryString(file)

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
