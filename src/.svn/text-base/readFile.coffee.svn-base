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
			acceptable_filetype = ["moib", "hcnihp", "txt"]
			if acceptable_filetype.indexOf(filetype) == -1
				alert "Please upload .biom or .phinch or .txt file!"
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
		
	readBlob: (file) -> 
		reader.onloadend = (evt) => 
			if evt.target.readyState == FileReader.DONE
				# JSON.parse(reader.result)
				biomToStore = {}
				biomToStore.name = file.name
				biomToStore.size = file.size
				biomToStore.data = evt.target.result
				if JSON.parse(biomToStore.data).format.indexOf("Biological Observation Matrix") != -1
					@server.biom.add(biomToStore).done (item) -> @currentData = item
					setTimeout( "window.location.href = 'preview.html'", 2000)	
				else 
					alert "Incorrect biom format field! Please check your file content!"
		reader.readAsBinaryString(file)

	listRecentFiles: () => 
		@server.biom.query().all().execute().done (results) =>
			if results.length > 0
				$('#recent').show()
				@currentData = results
				content = "<table id='recent_data'><thead><tr><th class = 'header'>ID</th><th class = 'header'>Name</th><th class='header'>Size</th><th class='header'>Load</th><th class='header'>Del</th></thead>"
				for k in [0..results.length-1]
					if k%2 == 1 then content += '<tr class="recent_data even"><td>' else content += '<tr class="recent_data"><td>'
					content += results[k].id + '</td><td>' + results[k].name.substring(0,80) + '</td><td>' + (results[k].size / 1000000).toFixed(1) + " MB" 
					content += '</td><td class="reload" id="reload_' + k + '"><center><i class="icon-upload-alt icon-large"></i></center>' + '</td><td class="del" id="del_'+k+'"><center><i class="icon-trash icon-large"></i></center></td></tr>'		
				content += "</table>"
				$("#recent").append(content)
				for k in [0..results.length-1]
					$('#reload_'+k).click( @reloadRow )
					$('#del_'+k).click( @removeRow )
			else 
				$('#recent').hide()

	reloadRow: (evt) =>
		i = evt.currentTarget.id.replace("reload_","")
		biomToStore = {}
		biomToStore.name = @currentData[i].name
		biomToStore.size = @currentData[i].size
		biomToStore.data = @currentData[i].data
		@server.biom.add(biomToStore).done (item) -> @currentData = item
		setTimeout( "window.location.href = 'preview.html'", 1000)

	removeRow: (evt) =>
		i = evt.currentTarget.id.replace("del_","")
		@server.biom.remove( @currentData[i].id ).done () -> 
			$('#recent_data tr')[parseInt(i)+1].remove()

window.readFile = readFile