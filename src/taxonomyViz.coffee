class taxonomyViz

	biom = null
	phinch = null
	percentage = false
	bubbleView = true
	LayerID = 2
	VizID = null
	filename = 'data'
	vizdata = null
	sumEachCol = null
	sumEachTax = null
	new_data_matrix_onLayer = null
	unique_taxonomy_comb_onLayer = null
	format = d3.format(',d')
	fillCol = ['#3182bd', '#6baed6', '#9ecae1', '#c6dbef', '#e6550d', '#fd8d3c', '#fdae6b', '#fdd0a2', '#31a354', '#74c476', '#a1d99b', '#c7e9c0', '#756bb1', '#9e9ac8', '#bcbddc', '#dadaeb', '#636363', '#969696', '#bdbdbd', '#d9d9d9']
	layerNameArr = ['kingdom', 'phylum', 'class', 'order', 'family', 'genus', 'species']
	standardizedValue = 0
	deleteOTUArr = []
	deleteSampleArr = []
	selectedSampleCopy = [] # array after deletion
	new_data_matrix = []
	unique_taxonomy_comb = []
	columns_sample_name_array = []
	map_array = []
	unique_taxonomy_comb_count = []
	selected_samples = []
	groupable = []
	selected_attributes_array = []
	selected_attributes_units_array = []
	selected_phinchID_array = []
	globalColoring = d3.scale.category20()
	backendServer = 'http://' + window.location.host + window.location.pathname.substr(0, window.location.pathname.lastIndexOf('/')) + "/server/"
	filterOptionJSON = {}
	console.log backendServer

	constructor: (_VizID, _LayerID) ->
		VizID = _VizID
		LayerID = _LayerID

		db.open(
			server: "BiomSample", version: 1,
			schema:
				"biomSample": key: keyPath: 'id', autoIncrement: true,
		).done (s) => 
			s.biomSample.query().all().execute().done (results) =>

				filterOptionJSON = results[results.length-1]

				# 1 get selected samples first 
				selected_samples = filterOptionJSON.selected_sample
				groupable = filterOptionJSON.groupable
				selected_groupable_array = filterOptionJSON.selected_groupable_array
				selected_attributes_array = filterOptionJSON.selected_attributes_array
				selected_attributes_units_array = filterOptionJSON.selected_attributes_units_array
				selected_phinchID_array = filterOptionJSON.selected_phinchID_array

				# 2 open the biom file 
				db.open(
					server: "BiomData", version: 1,
					schema:
						"biom": key: keyPath: 'id', autoIncrement: true,
				).done (s) => 
					s.biom.query().all().execute().done (results) =>
						currentData = results[results.length-1]
						biom = JSON.parse(currentData.data)
						filename = currentData.name

						$("#file_details").html("");
						$("#file_details").append( "ANALYZING &nbsp;<span>" + currentData.name.substring(0,30) + "</span> &nbsp;&nbsp;&nbsp;" + (parseFloat(currentData.size.valueOf() / 1000000)).toFixed(1) + " MB <br/><br />Observation &nbsp;<em>" + format(biom.shape[0]) + "</em> &nbsp;&nbsp;&nbsp; Selected Samples &nbsp;<em>" + format(selected_samples.length) + "</em>")


						# 3 Click events 

						# resolve the first layer button mousevoer problem 
						$('#layer_1').on('mouseover', () ->
							$('#layer_1').removeClass('selected_layer');
							$('#layer_1').css('background-image', 'url("css/images/kingdom.png")');
						).on('mouseout', () ->
							$('#layer_1').addClass('selected_layer');
						)

						$('.circle').click (evt) =>
							that = this

							LayerID = parseInt evt.currentTarget.id.replace("layer_","");
							console.log 'clicked on ' + LayerID

							if (VizID == 2 and LayerID == 1)
								alert('Sankey diagram has at least two layers!')
							else if (VizID == 2 and (LayerID == 6 || LayerID == 7)) 
								alert('Cannot go deeper to the 6th or 7th layer!')
							else
								$('.circle').removeClass('selected_layer');
								$('.circle').css('background-image', 'url("css/images/circle.png")')
								$('#layer_' + LayerID).css('background-image', 'url("css/images/' + layerNameArr[LayerID-1] + '.png")');
								$('.progressLine').animate({width: (120 + (LayerID - 2) * 111 ) + 'px'}, {duration: 1000, specialEasing: {width: "easeInOutQuad"}, complete: () -> 
									if LayerID > 1
										for i in [1..LayerID-1]
											$('#layer_' + i).addClass('selected_layer');
									if $('#valueBtn').hasClass('clicked')
										percentage = false
									else 
										percentage = true
									that.generateVizData()

								});

						# 4 Value | Percent View Change 
						$('#valueBtn').click (evt) =>
							if percentage
								percentage = false 
								LayerID = parseInt($('.selected_layer').length) + 1
								$('#valueBtn').addClass('clicked')
								$('#percentBtn').removeClass('clicked')
								@generateVizData()
						$('#percentBtn').click (evt) =>
							if !percentage
								percentage = true
								LayerID = parseInt($('.selected_layer').length) + 1
								$('#valueBtn').removeClass('clicked')
								$('#percentBtn').addClass('clicked')
								@generateVizData()								

						# 5 List | Bubble View Change 
						$('#bubbleBtn').click (evt) =>
							if !bubbleView
								bubbleView = true 
								LayerID = parseInt($('.selected_layer').length) + 1
								$('#bubbleBtn').addClass('clicked')
								$('#listBtn').removeClass('clicked')
								@generateVizData()
						$('#listBtn').click (evt) =>
							if bubbleView
								bubbleView = false
								LayerID = parseInt($('.selected_layer').length) + 1
								$('#bubbleBtn').removeClass('clicked')
								$('#listBtn').addClass('clicked')
								@generateVizData()

						# Special case
						if VizID == 5
							LayerID = 7

						# 6 Legend control 
						$('#legend_header').click () => 
							if $('#legend_header').html() == 'TOP SEQS'
								$('#outline').hide()
								$('#legend_header').animate( {width: ( $('#legend_container').width() - 1) + 'px'}, {duration: 500, specialEasing: {width: "easeInOutQuad"}, complete: () -> 
									$('#legend_container').animate( {opacity: 1}, {duration: 500} )
									$('#legend_header').html('TOP SEQUENCES')
									$('#legend_header').css('background', 'url("css/images/collapse.png") no-repeat')
								})
							else
								$('#legend_container').animate( {opacity: '0'}, {duration: 500, specialEasing: {opacity: "easeInOutQuad"}, complete: () -> 
									$('#legend_header').animate( {width: '146px'}, {duration: 500} )
									$('#legend_header').html('TOP SEQS')
									$('#legend_header').css('background', 'none')
									$('#outline').show()
								})

						$('#count_header').click () => 
							if $('#count_header').html() == 'SAMPLE DIST'
								$('#count_header').animate( {width: '399px'}, {duration: 500, specialEasing: {width: "easeInOutQuad"}, complete: () -> 
									$('#count_container').animate( {opacity: 1}, {duration: 500} )
									$('#count_header').html('SAMPLE DISTRIRBUTION')
									$('#count_header').css('background', 'url("css/images/collapse.png") no-repeat')
								})
							else
								$('#count_container').animate( {opacity: '0'}, {duration: 500, specialEasing: {opacity: "easeInOutQuad"}, complete: () -> 
									$('#count_header').animate( {width: '146px'}, {duration: 500} )
									$('#count_header').html('SAMPLE DIST')
									$('#count_header').css('background', 'none')
								})		

						# 7 Generate chart
						@prepareData()
						@generateVizData()

						# 8 Download file and log 
						$('#downloadFile').click( () => 
							$('#downloadFile i').removeClass('icon-download')
							$('#downloadFile i').addClass('icon-spinner icon-spin')
							setTimeout(@doZip, 800)
						)

						# 9 Export chart 
						$('#export').click( @downloadChart )
						$('#share').click(@shareViz)

	prepareData: () ->

		# Calculate unique taxonomy combination
		for i in [0..biom.rows.length-1]
			flag = true
			comp_i = new Array(7)
			comb_len = unique_taxonomy_comb.length

			if biom.rows[i].metadata.taxonomy.indexOf(';') != -1
				comp_i = biom.rows[i].metadata.taxonomy.replace(/\s+/g, '').replace(/;/g,',').split(',')
			else 
				comp_i = biom.rows[i].metadata.taxonomy

			if comp_i[0].indexOf('k__') == -1 
				comp_i[0] = 'k__'

			switch comp_i.length
				when 6 then comp_i = [comp_i[0], comp_i[1], comp_i[2], comp_i[3], comp_i[4], comp_i[5], 's__']
				when 5 then comp_i = [comp_i[0], comp_i[1], comp_i[2], comp_i[3], comp_i[4], 'g__', 's__']
				when 4 then comp_i = [comp_i[0], comp_i[1], comp_i[2], comp_i[3], 'f__', 'g__', 's__']
				when 3 then comp_i = [comp_i[0], comp_i[1], comp_i[2], 'o__', 'f__', 'g__', 's__']
				when 2 then comp_i = [comp_i[0], comp_i[1], 'c__', 'o__', 'f__', 'g__', 's__']
				when 1 then comp_i = [comp_i[0], 'p__', 'c__', 'o__', 'f__', 'g__', 's__']
				when 0 then comp_i = ['k__', 'p__', 'c__', 'o__', 'f__', 'g__', 's__']

			if comb_len > 0
				for j in [0..comb_len-1]
					if comp_i[0] == unique_taxonomy_comb[j][0] && comp_i[1] == unique_taxonomy_comb[j][1] && comp_i[2] == unique_taxonomy_comb[j][2] && comp_i[3] == unique_taxonomy_comb[j][3] && comp_i[4] == unique_taxonomy_comb[j][4] && comp_i[5] == unique_taxonomy_comb[j][5] && comp_i[6] == unique_taxonomy_comb[j][6]
						unique_taxonomy_comb_count[j]++
						map_array[i] = j
						flag = false
						break 
			if flag 
				map_array[i] = comb_len
				unique_taxonomy_comb_count[comb_len] = 1
				unique_taxonomy_comb[comb_len] = comp_i

		# Create new data matrix 		
		for i in [0..unique_taxonomy_comb.length-1]
			new_data_matrix[i] = []
			for j in [0..biom.shape[1]-1]
				new_data_matrix[i][j] = 0
		for i in [0..biom.data.length-1]
			new_data_matrix[ map_array[biom.data[i][0]] ][ biom.data[i][1] ] += biom.data[i][2]

		for i in [0..biom.shape[1]-1]
			columns_sample_name_array.push(biom.columns[i].id)
		
	generateVizData: () ->
		unique_taxonomy_comb_onLayer = [] 
		new_data_matrix_onLayer = []
		viz_map_array = []

		if LayerID < 7
			for i in [0..unique_taxonomy_comb.length-1]
				comp_i = unique_taxonomy_comb[i]
				flag = true
				if unique_taxonomy_comb_onLayer.length > 0
					for j in [0..unique_taxonomy_comb_onLayer.length-1]
						flag_count = 0
						for k in [0..LayerID-1]
							if comp_i[k] == unique_taxonomy_comb_onLayer[j][k]
								flag_count++
						if flag_count == LayerID
							viz_map_array[i] = j
							flag = false
							break
				if flag
					viz_map_array[i] = unique_taxonomy_comb_onLayer.length 
					switch LayerID 
						when 6 then comp_i = [comp_i[0], comp_i[1], comp_i[2], comp_i[3], comp_i[4], comp_i[5], 's__']
						when 5 then comp_i = [comp_i[0], comp_i[1], comp_i[2], comp_i[3], comp_i[4], 'g__', 's__']
						when 4 then comp_i = [comp_i[0], comp_i[1], comp_i[2], comp_i[3], 'f__', 'g__', 's__']
						when 3 then comp_i = [comp_i[0], comp_i[1], comp_i[2], 'o__', 'f__', 'g__', 's__']
						when 2 then comp_i = [comp_i[0], comp_i[1], 'c__', 'o__', 'f__', 'g__', 's__']

					unique_taxonomy_comb_onLayer[unique_taxonomy_comb_onLayer.length] = comp_i

			for i in [0..unique_taxonomy_comb_onLayer.length-1]
				new_data_matrix_onLayer[i] = [] 
				for j in [0..new_data_matrix[0].length-1]
					new_data_matrix_onLayer[i][j] = 0
			for i in [0..new_data_matrix.length-1]
				for j in [0..new_data_matrix[0].length-1]
					new_data_matrix_onLayer[ viz_map_array[i] ][j] += new_data_matrix[i][j]
		else
			unique_taxonomy_comb_onLayer = unique_taxonomy_comb
			new_data_matrix_onLayer = new_data_matrix

		# console.log LayerID + ", unique comb: " + unique_taxonomy_comb_onLayer.length
		# console.log unique_taxonomy_comb_count
		# console.log new_data_matrix_onLayer

		if VizID == 0
			@vizName = 'taxonomyBarChart'
			@rightClick()
			@filterControl()
			@drawD3Bar()
		else if VizID == 1
			@vizName = 'bubbleChart'
			@drawTaxonomyBubble()
		else if VizID == 2 
			@vizName = 'sankeyDiagram'
			@drawTaxonomySankey()
		else if VizID == 3
			@vizName = 'donutPartition'
			if groupable.length > 1 
				for i in [0..groupable.length-1]
					$('#attributes_dropdown').append('<option>' + groupable[i] + '</option>');
				if $('#attributes_dropdown option:first').text() != undefined 
					@drawTaxonomyDonuts( $('#attributes_dropdown').find(":selected").text() )
				else
					@drawTaxonomyDonuts( groupable[0] )
				$('#attributes_dropdown').fadeIn(800)
				$('#attributes_dropdown').change (evt) =>
					@drawTaxonomyDonuts(evt.currentTarget.value)
			else if groupable.length == 1
				$('#attributes_dropdown').hide()
				@drawTaxonomyDonuts( groupable[0] )
			else 
				alert("Groupable chart not available for this dataset!")
		else if VizID == 4
			@vizName = 'attributesColumn'
			if selected_attributes_array.length > 0 
				$('#attributes_dropdown').html("")
				for i in [0..selected_attributes_array.length-1]
					$('#attributes_dropdown').append('<option>' + selected_attributes_array[i] + '</option>');
				if $('#attributes_dropdown option:first').text() != undefined 
					@drawTaxonomyByAttributes($('#attributes_dropdown').find(":selected").text() )
				else
					@drawTaxonomyByAttributes(selected_attributes_array[0] )
				$('#attributes_dropdown').change (evt) =>
					@drawTaxonomyByAttributes(evt.currentTarget.value)
			else 
				alert("Not supported!")
		else if VizID == 5
			@drawOTUBubble();
		else
			alert('Data is not being loaded correctly! ...')

	#####################################################################################################################         
	##############################################  Bar Chart & Filter ##################################################  
	#####################################################################################################################  

	drawD3Bar: () ->

		# 0 Clone the @selected_sample array, in case delete the elements from selected samples 
		selectedSampleCopy = selected_samples.slice(0); 

		# 1 Prepare Data  &&  2 - get the sum of each row, i.e. one taxonomy total over all samples 
		vizdata = null
		vizdata = new Array(new_data_matrix_onLayer.length) # only contains selected samples 
		sumEachTax = null 
		sumEachTax = new Array(new_data_matrix_onLayer.length)

		# 2 get rid of the deleted samples
		if deleteSampleArr.length > 0
			for i in [0..deleteSampleArr.length-1]
				selectedSampleCopy.splice(selectedSampleCopy.indexOf(deleteSampleArr[i]),1)

		for i in [0..new_data_matrix_onLayer.length-1]  # layer 2 - 68 
			# 1.1 store only selected data
			vizdata[i] = new Array(selectedSampleCopy.length)
			sumEachTax[i] = 0

			for j in [0..selectedSampleCopy.length-1]
				vizdata[i][j] = new Object()
				vizdata[i][j].x = selectedSampleCopy[j]
				vizdata[i][j].i = i
				if deleteOTUArr.indexOf(i) == -1 # not deleted 
					vizdata[i][j].y = new_data_matrix_onLayer[i][selectedSampleCopy[j]]
					sumEachTax[i] += new_data_matrix_onLayer[i][selectedSampleCopy[j]]
				else
					vizdata[i][j].y = 0
				vizdata[i][j].name = unique_taxonomy_comb_onLayer[i][0] + ',' + unique_taxonomy_comb_onLayer[i][1] + ',' + unique_taxonomy_comb_onLayer[i][2] + ',' + unique_taxonomy_comb_onLayer[i][3] + ',' + unique_taxonomy_comb_onLayer[i][4] + ',' + unique_taxonomy_comb_onLayer[i][5] + ',' + unique_taxonomy_comb_onLayer[i][6]
		
		# 3 generate viz - get the max value of each column, i.e. total sequence reads within a sample 
		sumEachCol = null
		sumEachCol = new Array(selectedSampleCopy.length)
		if selectedSampleCopy.length > 0 # 95 samples
			for i in [0..selectedSampleCopy.length-1] 
				sumEachCol[i] = 0
				for j in [0..new_data_matrix_onLayer.length-1] # 2 layer - 68
					vizdata[j][i].y0 = sumEachCol[i]
					if deleteOTUArr.indexOf(j) == -1  # pay attention
						sumEachCol[i] += new_data_matrix_onLayer[j][selectedSampleCopy[i]] 

		# 4 Draw
		@drawBasicBars()

	drawBasicBars: () -> 

		that = this
		@fadeInOutCtrl()

		# 1 draw the delete sample section
		if deleteSampleArr.length > 0
			content = '<ul class="basicTooltip">'
			for k in [0..deleteSampleArr.length-1]
				content += '<li>Sample ' + deleteSampleArr[k] + ', ' + String(selected_phinchID_array[deleteSampleArr[k]]) + '<span id = "delete_' + deleteSampleArr[k] + '">show</span></li>'
			content += '</ul>'

			d3.select("#taxonomy_container").append("div")
				.attr('id', 'deleteSampleArr')
				.html('<p>' + deleteSampleArr.length + ' samples hidden&nbsp;&nbsp;<span>show all</span></p><i class="icon-remove icon-large" id = "iconRemover4SampleDiv"></i>' + content)

			$('#deleteSampleArr p span').on('click',(e) ->
				d3.selectAll('#deleteSampleArr ul').transition().duration(200).ease("quad").style('opacity',1);
				d3.selectAll('#iconRemover4SampleDiv').transition().duration(250).ease("quad").style('opacity',1);
			)

			$('#iconRemover4SampleDiv').on('click',(e) ->
				d3.selectAll('#deleteSampleArr ul').transition().duration(250).ease("quad").style('opacity',0);
				d3.selectAll('#iconRemover4SampleDiv').transition().duration(200).ease("quad").style('opacity',0);
			)

			$('#deleteSampleArr ul li').each (index) ->
				$(this).click () ->
					thisSampID = parseInt( $(this)[0].children[0].id.replace('delete_',''))
					deleteSampleArr.splice(deleteSampleArr.indexOf(thisSampID),1)
					updateContent = ''
					for k in [0..deleteSampleArr.length-1]
						updateContent += '<li>Sample ' + deleteSampleArr[k] + ', ' + String(selected_phinchID_array[deleteSampleArr[k]]) + '<span id = "delete_' + deleteSampleArr[k] + '">show</span></li>'
					d3.select('#deleteSampleArr ul').html(updateContent)					
					that.drawD3Bar()

		# 2 clean canvas 
		w = 1200  
		h = sumEachCol.length * 14 + 200
		max_single = d3.max(sumEachCol)
		margin = {top: 75, right: 20, bottom: 20, left: 100}
		x = d3.scale.ordinal()
			.domain(vizdata[0].map( (d) -> return d.x ))
			.rangeRoundBands([0, h - margin.top - margin.bottom])
		y = d3.scale.linear() # .sqrt()
			.domain([0, max_single ])
			.range([0, w - margin.right - margin.left - 50])
		format = d3.format(',d')
			
		svg = d3.select("#taxonomy_container").append("svg")
			.attr("width", w )
			.attr("height", h)
		.append("g")
			.attr("transform", "translate(" + margin.left + "," + margin.top + ")")

		# 3 add small panel when click 
		infoPanel = d3.select("#taxonomy_container")
			.append("div")
			.attr("class", "basicTooltip")
			.style("visibility", "hidden")

		# 4 add the deletion panel
		delePanel = d3.select("#taxonomy_container")
			.append("div")
			.attr("class", "basicTooltipFlat")
			.style("visibility", "hidden")

		# 5 add main viz svg
		taxonomy = svg.selectAll('g.taxonomy')
			.data(vizdata)
		.enter().append('g')
			.attr('class', 'taxonomy')
			.style('fill', (d,i) -> return fillCol[i%20]  )
			.on 'mouseover', (d,i) ->
				index = i
				d3.selectAll('g.taxonomy')
					.style 'fill', (d,i) ->
						if i != index
							d3.rgb(fillCol[i%20]).darker() 
						else 
							fillCol[index%20]
					.style 'opacity', (d,i) -> 
						if i != index
							return 0.2 
			.on 'mouseout', (d,i) -> 
				d3.selectAll('g.taxonomy').style( 'fill', (d,i) -> return fillCol[i%20]).style('opacity', 1)

		# 6 add each bar
		rect = taxonomy.selectAll('rect')
			.data(Object)
		.enter().append('rect')
			.attr 'class', (d,i) -> 
				return 'sample_' + i
			.attr 'y', (d, i) -> 
					return 14 * i
			.attr 'x', (d, i) ->
				if isNaN(y(d.y0))
					return 0
				else if !percentage
					return y(d.y0)
				else
					return y(d.y0) / sumEachCol[i] * max_single
			.attr 'width', (d,i) ->
				if isNaN(y(d.y))
					return 0
				else if !percentage
					return y(d.y)
				else
					return y(d.y) / sumEachCol[i] * max_single 
			.attr('height', 12)
			.on 'mouseover', (d,i) ->
				content = ''
				content += '<div class="PanelHead"><b>SAMPLE NAME:</b> ' + columns_sample_name_array[d.x] + '<br/><b>TAXONOMY:</b> ' + d.name+ '</div>'
				content += '<div class="PanelInfo">TAXONOMY OCCURENCE IN THIS SAMPLE<br/><span>' + (d.y / sumEachCol[i] * 100).toFixed(2) + '%</span>&nbsp;&nbsp;<em>(' + format(d.y) + ' out of ' + format(sumEachCol[i]) + ')</em></div>'
				content += '<progress max="100" value="' + (d.y / sumEachCol[i] * 100).toFixed(2) + '"></progress>'
				content += '<div class="PanelInfo">OUT OF TOTAL TAXONOMY OCCURENCE IN ALL SAMPLES<br/><span>' + (d.y / sumEachTax[d.i] * 100).toFixed(2) + '%</span>&nbsp;&nbsp;<em>(' + format(d.y) + ' out of ' + format(sumEachTax[d.i]) + ')</em></div>'
				content += '<progress max="100" value="' + (d.y / sumEachTax[d.i] * 100).toFixed(2) + '"></progress>'
				# content += '<div class="PanelInfo">AVERAGE TAXONOMY OCCURENCE ACROSS ALL SAMPLES<br/><span>' + ( 100 / sumEachCol.length).toFixed(2) + '%</span></div>'
				# content += '<progress max="100" value="' + (100 / sumEachCol.length).toFixed(2) + '"></progress>'
				content += '<br/><br/>'
				infoPanel.html(content)
				infoPanel.style( { "visibility": "visible", top: (d3.event.pageY + 8) + "px", left: (d3.event.pageX + 8) + "px", "background": "rgba(255,255,255,0.9)" })
				delePanel.style( { "visibility": "hidden"})
			.on 'mouseout', (d,i) -> 
				infoPanel.style( { "visibility": "hidden"})
			.on 'contextmenu', (d,i) ->
				infoPanel.style( { "visibility": "hidden"})
				delePanel.html('<div class="hideSample">HIDE SAMPLE</div>')
				delePanel.style( { "visibility": "visible", top: (d3.event.pageY + 15) + "px", left: (d3.event.pageX - 15) + "px" })

				$('.hideSample').click () ->
					deleteSampleArr.push(d.x)
					that.drawD3Bar()

		# 7 to keep track of the swap positions 
		swapPosArr = [0..selectedSampleCopy.length-1]

		# 8 add y-axis
		label = svg.append('g').selectAll('text')
			.data(x.domain())
		.enter().append('text')
			.text (d,i) ->
				return String(selected_phinchID_array[i]).substr(0,12)
			.attr('x', -80)
			.attr('class', (d,i) -> return 'sampleTxt_' + i )
			.attr 'y', (d,i) ->
					return 14 * i + 9
			.attr('text-anchor', 'start')
			.attr("font-size", "10px")
			.attr('fill', '#444')
			.on 'mouseout', (d,i) ->
				d3.select('.sampleTxt_' + i).text(String(selected_phinchID_array[i]).substr(0,12)) # update texts 
			.on 'mouseover', (d,i) ->
				d3.select('.sampleTxt_' + i).text(String(selected_phinchID_array[i])) # update texts, full length
				delePanel.html('<div style="height:15px;"><i class="icon-fa-level-up icon-2x" id="moveup_' + i + '"></i></div><div><i class="icon-fa-level-down icon-2x" id="movedown_' + i + '"></i></div><div class="hideSample">HIDE SAMPLE</div>')
				delePanel.style( { "visibility": "visible", top: (d3.event.pageY ) + "px", left: (d3.event.pageX + 5) + "px" })

				$('.hideSample').click (e) ->
					deleteSampleArr.push(d) # d is the index here! 
					that.drawD3Bar()

				$('.icon-fa-level-up').click( (e) ->
					swaperId  = parseInt(e.target.id.replace('moveup_',''));  
					swaperPos = swapPosArr.indexOf(swaperId);          		  
					if swaperPos != 0
						swapeePos = swaperPos - 1;                     
						swapeeId  = swapPosArr[swapeePos]; 

						d3.selectAll('.sample_' + swaperId).transition().duration(250).ease("quad-in-out").attr('y', () -> return 14 * swapeePos )
						d3.selectAll('.sample_' + swapeeId).transition().duration(250).ease("quad-in-out").attr('y', () -> return 14 * swaperPos )

						d3.select('.sampleTxt_' + swaperId).transition().duration(250).ease("quad-in-out").attr('y', () -> return 14 * swapeePos + 9)
						d3.select('.sampleTxt_' + swapeeId).transition().duration(250).ease("quad-in-out").attr('y', () -> return 14 * swaperPos + 9)

						swapPosArr[swapeePos] = swaperId;
						swapPosArr[swaperPos] = swapeeId;
				)
				$('.icon-fa-level-down').click( (e) ->
					swaperId  = parseInt(e.target.id.replace('movedown_','')); 
					swaperPos = swapPosArr.indexOf(swaperId);      
					
					if swaperPos != swapPosArr.length-1
						swapeePos = swaperPos + 1;                     
						swapeeId  = swapPosArr[swapeePos];             

						d3.selectAll('.sample_' + swaperId).transition().duration(250).ease("quad-in-out").attr('y', () -> return 14 * swapeePos )
						d3.selectAll('.sample_' + swapeeId).transition().duration(250).ease("quad-in-out").attr('y', () -> return 14 * swaperPos )

						d3.select('.sampleTxt_' + swaperId).transition().duration(250).ease("quad-in-out").attr('y', () -> return 14 * swapeePos + 9)
						d3.select('.sampleTxt_' + swapeeId).transition().duration(250).ease("quad-in-out").attr('y', () -> return 14 * swaperPos + 9)

						swapPosArr[swapeePos] = swaperId;
						swapPosArr[swaperPos] = swapeeId;
				)

		# 9 add title & x-axis 
		svg.append("text")
			.attr('y', -35)
			.attr("font-size", "11px")
			.text('Sequence Reads')
			.attr('transform', (d) -> return "translate(" + y(max_single) / 2 + ", 0)" )

		rule = svg.selectAll('g.rule')
			.data(y.ticks(10))
		.enter().append('g')
			.attr('class','rule')
			.attr('transform', (d) -> return "translate(" + y(d) + ", 0)" )	

		rule.append('line')
			.attr('y2', h - 180)
			.style("stroke", (d) -> return if d then "#eee" else "#444" )
			.style("stroke-opacity", (d) -> return if d then 0.7 else null )

		rule.append('text')
			.attr('y', - 15 )
			.attr("font-size", "9px")
			.attr('text-anchor', 'middle')
			.attr('fill', '#444')
			.text (d,i) -> 
				if !percentage
					return format(d) 
				else
					return Math.round( i / (y.ticks(10).length - 1) * 100 ) + '%'

		# 10 create legend 
		legendArr = [] 
		for i in [0..sumEachTax.length-1]
			temp = new Object() 
			temp.originalID = i # for color purpose 
			temp.value = sumEachTax[i]
			temp.name = unique_taxonomy_comb_onLayer[i][0] + ',' + unique_taxonomy_comb_onLayer[i][1] + ',' + unique_taxonomy_comb_onLayer[i][2] + ',' + unique_taxonomy_comb_onLayer[i][3] + ',' + unique_taxonomy_comb_onLayer[i][4] + ',' + unique_taxonomy_comb_onLayer[i][5] + ',' + unique_taxonomy_comb_onLayer[i][6]
			legendArr.push(temp)

		@createLegend(legendArr)

		# 11 create fake divs for minimap
		divCont = ''
		if !percentage
			for i in [0..sumEachCol.length-1]
				divCont += '<div class="fake" style="width:' + y(sumEachCol[i]) + 'px;"></div>'
		else 
			for i in [0..sumEachCol.length-1]
				divCont += '<div class="fake" style="width:' + y(max_single) + 'px;"></div>'

		$('#fake_taxonomy_container').html(divCont)
		$('#viz_container').append('<canvas id="outline" width="150" height="' + (window.innerHeight - 280) + '"></canvas>')

		# 12 create a minimap
		if selected_samples.length > 20 
			$('#outline').fracs('outline', {
				crop: true,
				styles: [
					{
						selector: 'section',
						fillStyle: 'rgb(230,230,230)'
					},
					{
						selector: '#header, #file_details, #autoCompleteList',
						fillStyle: 'rgb(68,68,68)'
					},
					{
						selector: '.fake',
						fillStyle: 'rgb(255,193,79)'
					}
				],
				viewportStyle: {
					fillStyle: 'rgba(29,119,194,0.3)'
				},
				viewportDragStyle: {
					fillStyle: 'rgba(29,119,194,0.4)'
				}
			})

	filterControl: () ->

		that = this  # important!! to call the functions 
		availableTags = new Array(unique_taxonomy_comb_onLayer.length)
		for i in [0..unique_taxonomy_comb_onLayer.length-1]  # layer 2 - 68 
			availableTags[i] = unique_taxonomy_comb_onLayer[i][0] + ',' + unique_taxonomy_comb_onLayer[i][1] + ',' + unique_taxonomy_comb_onLayer[i][2] + ',' + unique_taxonomy_comb_onLayer[i][3] + ',' + unique_taxonomy_comb_onLayer[i][4] + ',' + unique_taxonomy_comb_onLayer[i][5] + ',' + unique_taxonomy_comb_onLayer[i][6]

		$('#tags').keydown () -> if $('#tags').val().length < 4 then $('#autoCompleteList').fadeOut(200)
		searchList = []
		$('#autoCompleteList').fadeOut(800);

		$( "#tags" ).autocomplete({ 
			source: availableTags,
			minLength: 3,
			response: (evt, ui) ->
				$('#autoCompleteList').html("");
				searchList.length = 0
				if ui.content.length > 0
					for i in [0..ui.content.length-1]
						searchList.push(ui.content[i].value)
					# searchList.sort( (a,b) -> return a.length - b.length )
					content = '<i class="icon-remove icon-large" style="float:right; margin: 5px 10px 0 0;" id = "iconRemover"></i><ul>'
					for i in [0..searchList.length-1]
						if deleteOTUArr.indexOf(i) != -1 
							content += '<li><span style = "display:block; background-color:#aaa; height: 12px; width: 12px; float: left; margin: 2px 0px;" ></span>&nbsp;&nbsp;'
							content += searchList[i] + '&nbsp;&nbsp;<em id="search_' + i + '">show</em></li>'
						else
							content += '<li><span style = "display:block; background-color:' + fillCol[ availableTags.indexOf(searchList[i]) % 20] + '; height: 12px; width: 12px; float: left; margin: 2px 0px;" ></span>&nbsp;&nbsp;'
							content += searchList[i] + '&nbsp;&nbsp;<em id="search_' + i + '">hide</em></li>'
					content += '</ul>'
					$('#autoCompleteList').append(content)
					$('#autoCompleteList ul li').each (index) ->
						$(this).mouseout () -> 
							d3.selectAll('g.taxonomy').filter((d,i) -> (i is index) )
								.style('fill', fillCol[index%20] )							

						$(this).mouseover () ->
							d3.selectAll('g.taxonomy').filter((d,i) -> (i is index) )
								.style('fill', d3.rgb( fillCol[index%20] ).darker() )

						$(this).click () ->
							if $('#search_' + index).html() == 'hide'
								$('#search_' + index).html('show') 
								$(this).find('span').css('background-color', '#aaa')
								$(this).css('color', '#aaa')
								deleteOTUArr.push( index )
							else
								$('#search_' + index).html('hide') 
								$(this).find('span').css('background-color', fillCol[index%20] )		
								$(this).css('color', '#000')
								deleteOTUArr.splice( deleteOTUArr.indexOf(index), 1)
							that.drawD3Bar()

					$('#iconRemover').click () -> $('#autoCompleteList').fadeOut(200)
					$('#autoCompleteList').show()
				else
					$('#autoCompleteList').html("")
					$('#autoCompleteList').hide()
		})

	rightClick: () ->
		if (document.addEventListener)
			document.addEventListener('contextmenu', (e) -> 
				e.preventDefault();
			, false)
		else 
			document.addEventListener('oncontextmenu', (e) ->
				window.event.returnValue = false;
			, false)

	#####################################################################################################################         
	##############################################  Bubble Chart  #######################################################         
	#####################################################################################################################  

	drawTaxonomyBubble: () ->

		@fadeInOutCtrl()
		@bubbleSearch()

		viz_series = new Array(unique_taxonomy_comb_onLayer.length)
		vizdata = new Array(unique_taxonomy_comb_onLayer.length)
		comb_name_list = new Array(unique_taxonomy_comb_onLayer.length)
		max_single = 0

		for i in [0..unique_taxonomy_comb_onLayer.length-1]
			vizdata[i] = 0
			viz_series[i] = new Array(selected_samples.length)
			comb_name_list[i] = []

		for i in [0..new_data_matrix_onLayer.length-1]  # layer 2 - 68
			
			# 1 add up only selected samples
			for j in [0..selected_samples.length-1]
				vizdata[i] += new_data_matrix_onLayer[i][ selected_samples[j] ]
				viz_series[i][j] = new_data_matrix_onLayer[i][ selected_samples[j] ]
				if viz_series[i][j] > max_single 
					max_single = viz_series[i][j]
			# 2 store comb name
			comb_name = ""
			for j in [0..5]
				comb_name += unique_taxonomy_comb_onLayer[i][j] + ','
			comb_name += unique_taxonomy_comb_onLayer[i][6]
			comb_name_list[i] = comb_name

		vis = d3.select("#taxonomy_container").append("svg")
			.attr("width", 1000)
			.attr("height", 1000)
			.attr("style", "margin: 20px 0 0 50px;")

		tooltip = d3.select("#taxonomy_container")
			.append("div")
			.attr("id", "bubbleTooltip")
			.attr("class", 'basicTooltip')
			.style("visibility", "hidden")

		infoPanel = d3.select("#taxonomy_container")
			.append("div")
			.attr("id", "bubblePanel")
			.style("visibility", "hidden")

		bubbleRemover = d3.select("#taxonomy_container")
			.append('div')
			.attr('id',"bubbleRemover")
			.style("visibility", "hidden")
		bubbleRemover.append('i').attr('class', 'icon-remove icon-large')

		# create a min max slider 
		$('#bubbleSliderLeft').html( Math.max(1, d3.min(vizdata)) );
		$('#bubbleSliderRight').html(d3.max(vizdata));
		$('#bubbleSlider').slider({
			range: true,
			min: Math.max(1, d3.min(vizdata)),
			max: d3.max(vizdata),
			values: [1, d3.max(vizdata)],
			slide: (event, ui) =>
				$('#bubbleSliderLeft').html(ui.values[0]);
				$('#bubbleSliderRight').html(ui.values[1]);
				d3.selectAll('.node').transition().duration(750).ease("quad").style('opacity',(d,i) ->
					if d.value < ui.values[0] or d.value > ui.values[1]
						return '0';
					else
						return '0.6';
				)
		});
		
		nodes = []
		adjust_min = 1
		adjust_max = d3.max(vizdata) + 1
		radius_scale = d3.scale.pow().exponent(0.25).domain([adjust_min, adjust_max]).range([2, 50])

		for i in [0..new_data_matrix_onLayer.length-1]
			if vizdata[i] > adjust_min and vizdata[i] < adjust_max
				node = {
					id: i
					radius: radius_scale( vizdata[i] )
					value: vizdata[i]
					name: comb_name_list[i]
					group: "medium" # 
					x: Math.random() * 800
					y: Math.random() * 600
				}
				nodes.push node

		if bubbleView
			force = d3.layout.force()
				.gravity( 0.1 ) # 0.025 * LayerID
				.charge((d) -> return - Math.pow(d.radius,2.0) / 8)
				.nodes(nodes)
				.on("tick", (e) -> 
					node.attr("cx", (d) -> return d.x )
						.attr("cy", (d) -> return d.y )
				)
				.size([200 + LayerID * 120, 160 + LayerID * 120])
				.start()
		else 
			if nodes.length > 0
				nodes.sort (a,b) -> b.value - a.value
				nodes[0].x = 60
				nodes[0].y = 60
				maxRowHeight = 50
				for i in [1..nodes.length-1]
					nodes[i].x = nodes[i-1].x + nodes[i-1].radius + nodes[i].radius + 20
					nodes[i].y = nodes[i-1].y
					if nodes[i].x > 850 
						nodes[i].x = 10 + nodes[i].radius 
						nodes[i].y += 40 + nodes[i].radius + maxRowHeight
						maxRowHeight = nodes[i].radius
				vis.attr("height", nodes[nodes.length-1].y + 50 ) # update canvas size

		node = vis.selectAll(".node")
			.data(nodes)
		.enter().append("circle")
			.attr("class", "node")
			.attr("id", (d) -> return "bub_" + d.id)
			.attr("cx", (d) -> return d.x )
			.attr("cy", (d) -> return d.y )
			.attr("r", (d) -> d.radius)
			.style("fill", (d, i) -> return fillCol[d.id%20] )
			.style({opacity:'0.6',stroke: 'none'})
			.on('mouseover', (d, i) ->
				d3.select(this).style({opacity:'1', stroke: '#000', 'stroke-width': '3' })
				tooltip.html( "<b>TAXONOMY:</b> " + d.name + "<br/><b>TOTAL READS:</b> " + format(d.value) + "<br/><b>OTU QUANTITY:</b> " + format(unique_taxonomy_comb_count[i])) # vizdata[i]
				tooltip.style( { "visibility": "visible", top: (d3.event.pageY - 10) + "px", left: (d3.event.pageX + 10) + "px" })
			)
			.on('mouseout', (d) ->
				d3.select(this).style({opacity:'0.6',stroke: 'none'})
				tooltip.style("visibility", "hidden")
			)
			.on 'click', (d,i) -> 
				tooltip.style("display","none")
				if bubbleView
					force.stop(); # in case interrupt the mouse movement 
				circleUnderMouse = this
				d3.select(this).transition()
					.attr('cx', '60')
					.attr('cy', '60')
					.duration(750)
					.ease("quad-in-out")
				d3.selectAll(".node").filter((d,i) -> (this isnt circleUnderMouse) )
					.transition()
					.attr('r', '0')
					.duration(750)
					.delay(750)
					.ease("quad-in-out")

				y = d3.scale.linear().domain([0, d3.max(viz_series[d.id])]).range([1,115]) # max_single # standardized 
				infoPanel.style("visibility", "visible")
				bubbleRemover.style("visibility",'visible')
				curColor = d3.select(this).style("fill")
				infoPanel.html('<div class="bubbleTaxHeader">' + d.name.substring(0,70) + '&nbsp;&nbsp;' + format(d3.sum(viz_series[d.id])) + ' Reads &nbsp;<span>SAMPLE DISTRIRBUTION</span></div><svg width="813px" style="float: right; padding: 0 20px; border: 1px solid #c8c8c8; border-top: none;" height="' + Math.ceil(viz_series[d.id].length / 5 + 1) * 25 + '"></svg>') # height="100px"
				barrect = infoPanel.select('svg').selectAll('rect').data(viz_series[d.id])
				valrect = infoPanel.select('svg').selectAll('text').data(viz_series[d.id])
				txtrect = infoPanel.select('svg').selectAll('text').data(selected_samples)

				txtrect.enter().append('text')
					.text( (d,i) -> return String(selected_phinchID_array[i]).substr(-6) )
					.attr("x", (d,i) -> return ( (i % 5) * 160 + 50 ) + 'px' )
					.attr("y", (d,i) -> return 25 * Math.floor(i / 5) + 30 + 'px' )
					.attr("text-anchor", 'end')
					.attr("font-size", "10px")
					.attr("font-weight", 'bold')

				barrect.enter().append('rect')
					.attr('height', '15px' )
					.attr('width', '115px' )
					.attr("x", (d,i) -> return ( (i % 5) * 160 + 55 ) + 'px' )  # 30 bars every line, 20 padding on left & right
					.attr("y", (d,i) -> return 25 * Math.floor(i / 5) + 20 + 'px' ) # 50 padding top and bottom
					.style("fill", '#f2f2f2')

				barrect.enter().append('rect')
					.attr('height', '15px' )
					.attr('width', (d) -> return y(d) )
					.attr("x", (d,i) -> return ( (i % 5) * 160 + 55 ) + 'px' )  # 30 bars every line, 20 padding on left & right
					.attr("y", (d,i) -> return 25 * Math.floor(i / 5) + 20 + 'px' ) # 50 padding top and bottom
					.style("fill", curColor)

				valrect.enter().append('text')
					.text( (d,i) -> return format(d) )
					.attr("x", (d,i) -> return ( (i % 5) * 160 + 165 ) + 'px' )
					.attr("y", (d,i) -> return 25 * Math.floor(i / 5) + 31 + 'px' )
					.attr("text-anchor", 'end')
					.attr("font-size", "10px")
					.attr("fill", "#bbb")

		d3.select('#bubbleRemover').on 'click', (d) ->
			tooltip.style("display", "block")
			infoPanel.style("visibility", "hidden")
			bubbleRemover.style("visibility",'hidden')
			if bubbleView
				force.resume() 
			d3.selectAll(".node").transition()
				.style({opacity:'0.7',stroke: 'none'})
				.attr("cx", (d) -> return d.x)
				.attr("cy", (d) -> return d.y)
				.attr('r', (d) -> return d.radius )
				.duration(750)
				.ease("quad")

	bubbleSearch: () ->

		that = this  # important!! to call the functions 
		availableTags = new Array(unique_taxonomy_comb_onLayer.length)
		for i in [0..unique_taxonomy_comb_onLayer.length-1]  # layer 2 - 68 
			availableTags[i] = unique_taxonomy_comb_onLayer[i][0] + ',' + unique_taxonomy_comb_onLayer[i][1] + ',' + unique_taxonomy_comb_onLayer[i][2] + ',' + unique_taxonomy_comb_onLayer[i][3] + ',' + unique_taxonomy_comb_onLayer[i][4] + ',' + unique_taxonomy_comb_onLayer[i][5] + ',' + unique_taxonomy_comb_onLayer[i][6]

		$('#tags').keydown () -> if $('#tags').val().length < 4 then $('#autoCompleteList').fadeOut(200)
		searchList = []
		$('#autoCompleteList').fadeOut(800);

		$( "#tags" ).autocomplete({ 
			source: availableTags,
			minLength: 3,
			response: (evt, ui) ->
				$('#autoCompleteList').html("");
				searchList.length = 0
				if ui.content.length > 0
					for i in [0..ui.content.length-1]
						searchList.push(ui.content[i].value)
					content = '<i class="icon-remove icon-large" style="float:right; margin: 5px 10px 0 0;" id = "iconRemover"></i><ul>'
					for i in [0..searchList.length-1]
						content += '<li><span style = "display:block; background-color:' + fillCol[ availableTags.indexOf(searchList[i]) % 20] + '; height: 12px; width: 12px; float: left; margin: 2px 0px;" ></span>&nbsp;&nbsp;' + searchList[i] + '</li>'
					content += '</ul>'
					$('#autoCompleteList').append(content)
					$('#autoCompleteList ul li').each (index) ->
						$(this).mouseout () ->
							d3.select('#bub_' + index).style({opacity:'0.6',stroke: 'none'})

						$(this).mouseover () ->
							d3.select('#bub_' + index).style({opacity:'1', stroke: '#000', 'stroke-width': '3' })

					$('#iconRemover').click () -> $('#autoCompleteList').fadeOut(200)
					$('#autoCompleteList').show()
				else
					$('#autoCompleteList').html("")
					$('#autoCompleteList').hide()
		})

	#####################################################################################################################         
	#############################################  Sankey Diagram   #####################################################         
	##################################################################################################################### 

	drawTaxonomySankey: () -> 
		# console.log unique_taxonomy_comb_onLayer
		# console.log new_data_matrix_onLayer

		@fadeInOutCtrl()
		
		# prepare data 
		nodesArr = []
		sumEachTax = new Array(unique_taxonomy_comb_onLayer.length)
		taxonomySankey = new Object()
		taxonomySankey.nodes = []
		taxonomySankey.links = []

		if unique_taxonomy_comb_onLayer.length > 0
			for i in [0..unique_taxonomy_comb_onLayer.length-1]
				sumEachTax[i] = 0 
				for j in [0..selected_samples.length-1]
					sumEachTax[i] += new_data_matrix_onLayer[i][selected_samples[j]]
			
			max_single = d3.max( sumEachTax )
			# console.log 'max_single: ' + max_single
			
			# yScaleReverse = d3.scale.linear().domain([0, 10]).range([0, Math.pow(max_single,0.2)])

			for i in [0..unique_taxonomy_comb_onLayer.length-1] # 
				for j in [0..LayerID-1]
					# step 1: push nodes
					if nodesArr.indexOf( unique_taxonomy_comb_onLayer[i][j] ) == -1 # new element
						nodesArr.push( unique_taxonomy_comb_onLayer[i][j] )
						tempNode = new Object()
						tempNode.name = unique_taxonomy_comb_onLayer[i][j]
						taxonomySankey.nodes.push( tempNode )
					# step 2: push links 
					if j > 0 
						linkExist = false
						tempLink = new Object() 
						tempLink.source = nodesArr.indexOf( unique_taxonomy_comb_onLayer[i][j-1] )
						tempLink.target = nodesArr.indexOf( unique_taxonomy_comb_onLayer[i][j] )
						# tempLink.value = yScale(sumEachTax[i])
						tempLink.absValue = sumEachTax[i]

						for link in taxonomySankey.links 
							if link.source == tempLink.source and link.target == tempLink.target
								link.absValue += sumEachTax[i]
								# link.value = yScale(link.absValue)
								linkExist = true
						if !linkExist
							taxonomySankey.links.push( tempLink )

			maxNodeAbsValue = d3.max(taxonomySankey.links, (d,i) -> return d.absValue )
			yScale = d3.scale.linear().domain([0, maxNodeAbsValue]).range([0, 10])  # pow().exponent(.2)

			for link in taxonomySankey.links
				link.value = (link.absValue)

			# console.log taxonomySankey.nodes
			# console.log taxonomySankey.links

		# clean canvas
		width = 1200
		height = 20 * unique_taxonomy_comb_onLayer.length 
		margin = {top: 40, right: 10, bottom: 20, left: 20}		
		color = globalColoring
		
		svg = d3.select("#taxonomy_container").append("svg")
			.attr("width", width )
			.attr("height", height)
		.append("g")
			.attr("transform", "translate(" + margin.left + "," + margin.top + ")")

		# add small panel when click 
		infoPanel = d3.select("#taxonomy_container")
			.append("div")
			.attr("id", "sankeyInfo")
			.style({"opacity":0, "z-index": -1})
			
		sankey = d3.sankey()
			.size([width - 200, height - 100])
			.nodeWidth(15)
			.nodePadding(10)
			.nodes(taxonomySankey.nodes)
			.links(taxonomySankey.links)
			.layout(32, width - 200)  # modify the sankey.js diagram 

		path = sankey.link()

		link = svg.append("g").selectAll(".link")
			.data(taxonomySankey.links)
		.enter().append("path")
			.attr("class", "link")
			.attr("d", path)
			.style('fill', (d,i) -> return color(d.target.name) )
			.style("opacity", 0.2)
			.sort( (a, b) -> return b.dy - a.dy )
						
		node = svg.append("g").selectAll(".node")
			.data(taxonomySankey.nodes)
		.enter().append("g")
			.attr("class", (d) -> if isNaN(d.y) then return 'nullnode' else return 'node')
			.style('display', (d) -> if isNaN(d.y) then return 'none' else return 'block')
			.attr("transform", (d) -> if !isNaN(d.y) then return "translate(" + d.x + "," + d.y + ")" else return "translate(" + d.x + ", 1)" )

		node.append("rect")
			.attr('x',0).attr('y',0)
			.attr("height",  (d) -> if (d.dy < 2 or isNaN(d.dy)) then return 2 else return d.dy )
			.attr("width", sankey.nodeWidth())
			.style("fill",  (d, i) -> return color(d.name) )
			.style("opacity", 0.6)
			.on "click", (d,i) =>
				return @clickLargeSnakeyNode(d,i, taxonomySankey,svg)

		node.append("text")
			.attr("x", -6)
			.attr("y",  (d) -> if isNaN(d.dy) then return 1 else return d.dy / 2)
			.attr("dy", ".35em")
			.attr("text-anchor", "end")
			.attr("transform", null)
			.attr("font-size", "10px")
			.text( (d) -> return d.name)
		.filter( (d) -> return d.x < width / 2)
			.attr("x", 6 + sankey.nodeWidth())
			.attr("text-anchor", "start");

		# add search function
		@sankeyFilterControl(nodesArr, taxonomySankey, svg)

	clickLargeSnakeyNode: (d,i,taxonomySankey,svg) =>
		infoPanel = d3.select("#taxonomy_container #sankeyInfo")
		content = "<div class='sankeyInfobox'><div id='sankeyRemover'><i class='icon-remove icon-large'></i></div>"
		if d.targetLinks.length == 0
			content += "<p>" + d.name + " is a source node. It has " + d.sourceLinks.length + " branches.</p><p>Their distributions are: </p>"
		else if d.sourceLinks.length == 0
			content += "<p>" + d.name + " is an end node. Its absolute reads is " + d.targetLinks[0].absValue + ".</p></div>"
		else 
			sourceTotal = 0
			for k in [0..d.sourceLinks.length-1] 
				sourceTotal += d.sourceLinks[k].absValue					
			content += "<p>" + d.name + " has " + d.sourceLinks.length + " branches. Its total reads is " + sourceTotal + ".</p><p>Their distributions are: </p>"
		content += "</div>"
		infoPanel.html(content);
		@drawSmallSankey(infoPanel,d,taxonomySankey, svg)
		svg.transition().duration(750).ease("quad-in-out").style({"opacity":0, "z-index": -1})
		infoPanel.style('z-index', 3).transition().duration(750).ease("quad-in-out").style({"opacity": 1})
		$('#sankeyRemover').click () ->
			infoPanel.transition().duration(750).ease("quad-in-out").style({"opacity":0, "z-index": -1})
			svg.transition().duration(750).ease("quad-in-out").style({"opacity": 1, "z-index":1})

	drawSmallSankey: (div,targetNode,originalSankey,originalSVG) -> 
		
		smlTaxonomySankey = new Object()
		smlTaxonomySankey.nodes = []
		smlTaxonomySankey.links = []

		smlTaxonomySankey.nodes.push(_.clone(targetNode))
		minHeight = 600
		targetHeight = 600
		maxNodesOnSide = 1
		if targetNode.targetLinks.length > maxNodesOnSide
			maxNodesOnSide = targetNode.targetLinks.length
		if targetNode.sourceLinks.length > maxNodesOnSide
			maxNodesOnSide = targetNode.sourceLinks.length
		for node in targetNode.targetLinks
			smlTaxonomySankey.nodes.push _.clone(node.source)
			link = {source: smlTaxonomySankey.nodes.length - 1, target: 0, value: node.absValue}
			smlTaxonomySankey.links.push(link)
		for node in targetNode.sourceLinks
			smlTaxonomySankey.nodes.push _.clone(node.target)
			link = {source: 0, target: smlTaxonomySankey.nodes.length - 1, value: node.absValue}
			smlTaxonomySankey.links.push(link)

		nodeHeight = 12
		acceptableHeight = maxNodesOnSide * nodeHeight
		if acceptableHeight > targetHeight
			targetHeight = acceptableHeight

		divHeight = targetHeight + 80
		maxDivHeight = 800
		divLarge = false
		if divHeight > maxDivHeight
			divHeight = maxDivHeight
			divLarge = true
		d3.select('.sankeyInfobox').style('height', divHeight + 'px').style('overflow-y', () ->
			if divLarge
				return 'scroll'
			else
				return 'visible'
		)
		smallSankeyDimensions = {w: 600, h: targetHeight}
		smallSankeySVG = div.select('.sankeyInfobox').append('svg').attr('width', smallSankeyDimensions.w).attr('height', smallSankeyDimensions.h)
		
		color = globalColoring
		smallSankey = d3.sankey().size([smallSankeyDimensions.w, smallSankeyDimensions.h - 10])
			.nodeWidth(15).nodePadding(10)
			.nodes(smlTaxonomySankey.nodes).links(smlTaxonomySankey.links)
			.layout(128, smallSankeyDimensions.w)
		path = smallSankey.link()
		link = smallSankeySVG.append('g').selectAll('.link').data(smlTaxonomySankey.links)
		link.enter().append('path').attr('class','link').style("opacity", 0.2)
		link.attr('d', path).style('fill', (d) ->
			return color(d.target.name);
		).sort((a,b) ->
			return b.dy - a.dy
		)

		node = smallSankeySVG.append('g').selectAll('.node').data(smlTaxonomySankey.nodes)
			.enter().append("g").attr("class", (d) ->
				if isNaN(d.y)
				  return 'nullnode';
				else
				  return 'node';
		
			).attr("transform", (d) ->
				if !isNaN(d.y)
					return "translate(" + d.x + "," + d.y + ")"
				
			)
		node.append("rect").attr("height", (d) ->
			if d.dy < 2
				return 2;
			else
				return d.dy;
		).attr("width", smallSankey.nodeWidth()).style("fill", (d, i) ->
			return color(d.name);
		).on('click', (d,i) =>
			return @clickSmallSankeyNode(d,i, originalSankey,originalSVG)
		).style("opacity", 0.6).attr('x', 0).attr('y',0);
		node.append('rect').attr('height', (d) ->
			originalNode = _.filter(originalSankey.nodes, (dd) -> return dd.name is d.name)
			if originalNode.length > 1
				console.error('more than one matching node')
				console.error(originalNode)
			originalNode = originalNode[0]
			ratio = 1 - d.value / originalNode.value
			if d.dy < 2
				d.fillHeight = 2;
			else
				d.fillHeight = d.dy * ratio
			return d.fillHeight

		).attr('width', smallSankey.nodeWidth()).style('fill', 'rgba(255,255,255,0.8)')
		.attr('y', (d) ->
			return d.dy - d.fillHeight
		).style('pointer-events','none')
		node.append('text')
			.attr("x", -6)
			.attr("y",  (d) -> return d.dy / 2)
			.attr("dy", ".35em")
			.attr("font-size", "10px")
			.attr("text-anchor", "end")
			.attr("transform", null)
			.text( (d) -> return d.name)
		.filter( (d) -> return d.x < width / 2)
			.attr("x", 6 + smallSankey.nodeWidth())
			.attr("text-anchor", "start");

	clickSmallSankeyNode: (d,i,originalSankey,originalSVG) =>
		originalData = _.filter(originalSankey.nodes, (dd) ->
			return dd.name is d.name
		)
		if originalData.length > 1
			console.error('more than one matching node found')
			console.error originalData
		else
			originalData = originalData[0]
		@clickLargeSnakeyNode(originalData, i, originalSankey, originalSVG)

	sankeyFilterControl: (_nodesArr, taxonomySankey, svg) ->

		that = this
		color = globalColoring
		nodesArr = _nodesArr
		availableTags = new Array(nodesArr.length)
		for i in [0..nodesArr.length-1]  # more links
			availableTags[i] = nodesArr[i]

		$('#tags').keydown () -> if $('#tags').val().length < 4 then $('#autoCompleteList').fadeOut(200)
		searchList = []
		$('#autoCompleteList').fadeOut(300);

		$( "#tags" ).autocomplete({ 
			source: availableTags,
			minLength: 2,
			response: (evt, ui) ->
				$('#autoCompleteList').html("");
				searchList.length = 0
				if ui.content.length > 0
					for i in [0..ui.content.length-1]
						searchList.push(ui.content[i].value)
					content = '<i class="icon-remove icon-large" style="float:right; margin-right: 5px;" id = "iconRemover"></i><ul>'
					for i in [0..searchList.length-1]
						content += '<li><span style = "display:block; background-color:' + color(searchList[i]) + '; height: 12px; width: 12px; float: left; margin: 2px 0px;" ></span>&nbsp;&nbsp;'
						content += searchList[i] + '</li>'
					content += '</ul>'
					$('#autoCompleteList').append(content)
					$('#autoCompleteList ul li').each (index) ->
						$(this).click () ->
							for m in[0..taxonomySankey.nodes.length-1]
							 	if taxonomySankey.nodes[m].name == $(this)[0].textContent.substr(2) # find the node and node id
							 		that.clickLargeSnakeyNode(taxonomySankey.nodes[m], m, taxonomySankey, svg)

					$('#iconRemover').click () -> $('#autoCompleteList').fadeOut(200)
					$('#autoCompleteList').show()
				else
					$('#autoCompleteList').html("")
					$('#autoCompleteList').hide()
		})

	#####################################################################################################################			 
	############################################# Level Donut Chart #####################################################  
	#####################################################################################################################  

	drawTaxonomyDonuts: (cur_attribute) -> 

		@fadeInOutCtrl()

		# 1 Prepare data - find different categories under this groupable attr
		groupable_array = []
		for i in [0..selected_samples.length-1]
			if groupable_array.indexOf( biom.columns[ selected_samples[i] ].metadata[cur_attribute] ) == -1 
				groupable_array.push( biom.columns[ selected_samples[i] ].metadata[cur_attribute] )

		count = new Array( groupable_array.length)
		for i in [0..groupable_array.length-1]
			count[i] = []

		selected_new_data_matrix_onLayer = new Array(new_data_matrix_onLayer.length) # only contains selected samples 
		for i in [0..new_data_matrix_onLayer.length-1]  # layer 2 - 68 
			# 1 store only selected data
			selected_new_data_matrix_onLayer[i] = new Array(groupable_array.length)
			for j in [0..groupable_array.length-1]
				selected_new_data_matrix_onLayer[i][j] = 0
			for j in [0..selected_samples.length-1]
				arr_id = groupable_array.indexOf( biom.columns[ selected_samples[j] ].metadata[ cur_attribute ] )
				selected_new_data_matrix_onLayer[i][arr_id] += new_data_matrix_onLayer[i][ selected_samples[j] ] 

		# 2 Store the sample IDs in the count 2D array 
		for i in [0..selected_samples.length-1]
			count[ groupable_array.indexOf( biom.columns[ selected_samples[i] ].metadata[ cur_attribute ] ) ].push( selected_samples[i] )

		# 3 Plot Pie for each category 
		# find the longest bar #
		maxCount = 0
		for i in [0..count.length-1]
			if count[i].length > maxCount
				maxCount = count[i].length

		console.log 'maxCount: ' + maxCount

		d3.select('#taxonomy_container').append('svg').attr("width", maxCount * 20 + 450).attr("height", 250 * groupable_array.length + 200)
		alphagroupble_array = _.clone(groupable_array).sort()

		# console.log groupable_array
		# console.log alphagroupble_array

		for i in [0..groupable_array.length-1]
			donutArr = []
			for j in [0..selected_new_data_matrix_onLayer.length-1]
				donutArr.push( selected_new_data_matrix_onLayer[j][i] )
			@drawBasicDonut( i, groupable_array[i], donutArr, count[i], alphagroupble_array.indexOf(groupable_array[i]))

		# console.log groupable_array
		# console.log count	
		
	drawBasicDonut: ( donutID, donutName, donutData, donutContainedSamp, posID ) -> 

		radius = 100
		yScale = d3.scale.pow().exponent(.4).domain([0, d3.max(donutData)]).range([0, 100]) # linear 
		arc = d3.svg.arc() 
			.outerRadius(radius)
			.innerRadius(50)
		pie = d3.layout.pie() 
			.sort(null)
			.value( (d) -> return yScale(d) )

		# 0 Add switch buttons
		d3.select('#taxonomy_container').append('div')
			.attr('class','donutSwitch')
			.style('top', 250 + posID * 290 + 'px')
			.html('<button id="toggleDy_' + donutID + '" class="clicked">Dynamic</button><button id = "toggleSt_' + donutID + '">Stand.</button>')

		$('#toggleDy_' + donutID).click(() =>
			if(! $('#toggleDy_' + donutID).hasClass('clicked'))
				$('#toggleDy_' + donutID).addClass('clicked')
				$('#toggleSt_' + donutID).removeClass('clicked')
				@drawBasicRect(true, donutContainedSamp, donutID, null, 'dynamic')
		)

		$('#toggleSt_' + donutID).click(() =>
			if(! $('toggleSt_' + donutID).hasClass('clicked'))
				$('#toggleSt_' + donutID).addClass('clicked')
				$('#toggleDy_' + donutID).removeClass('clicked')
				@drawBasicRect(true, donutContainedSamp, donutID, null, 'standardized')
		)

		# 1 append each svg
		d3.select('#taxonomy_container svg').append('g')
			.attr("id", "donut_" + donutID)
			.attr("transform", "translate(" + 125 + "," + (150 + posID * 290) + ")")

		svg = d3.select('#donut_' + donutID).append('g')
			.attr("width", 300)
			.attr("height", 255)

		# 3 plot all arc
		that = this
		g = svg.selectAll(".arc")
			.data(pie(donutData))
		.enter().append("g")
			.attr('class','arc_' + donutID)
		g.append("path")
			.attr('d', arc)
			.style('fill', (d,i) -> return fillCol[i%20] ) 
			.on 'mouseover', (d,i) -> 
				index = i
				d3.selectAll('g.arc_' + donutID)
					.style 'opacity', (d,i) -> 
						if i != index then return 0.5
			.on 'mouseout', (d,i) -> 
				d3.selectAll('g.arc_' + donutID).style('opacity', 1)
			.on 'click', (d,i) ->
				if $('#toggleDy_' + donutID).hasClass('clicked') 
					dynamicStatus = 'dynamic'
				else
					dynamicStatus = 'standardized'
				that.drawBasicRect(false, donutContainedSamp, donutID, i, dynamicStatus )

		# 2 add category name # put this after previous step, so the text will be on top of the donuts
		svg.append('text')
			.attr('dy', '.35em')
			.attr('y', '-7')
			.style('text-anchor', 'middle')
			.attr("font-size", "12px")
			.text(donutName)
		svg.append('text')
			.attr('dy', '.35em')
			.style('text-anchor', 'middle')
			.attr("font-size", "14px")
			.attr("font-weight", "bold")
			.attr('y', '7')
			.text(d3.sum(donutData))

		# 4 bar chart part
		d3.select('#donut_' + donutID).append("g")
			.attr('height', 235)
			.attr('id', 'selectedColumn_' + donutID)
			.attr("transform", "translate(150,-100)")

		d3.select('#donut_' + donutID).append("text")	
			.attr("id", "containedTaxonomy_" + donutID)
			.style("font-size", "11px")
			.style("text-anchor", "start")
			.style("font-style","italic")
			.attr("x", -100)
			.attr("y", 150)
		
		@drawBasicRect(true, donutContainedSamp, donutID, null, 'dynamic')

	drawBasicRect: (totalFlag, containedSamp, donutID, selectedTaxnomy, toggleStandard) ->

		# 1 calculate data 
		rectArr = new Array(containedSamp.length)
		for i in [0..containedSamp.length-1]
			rectArr[i] = 0

			if totalFlag # draw total 
				for j in [0..new_data_matrix_onLayer.length-1]
					rectArr[i] += new_data_matrix_onLayer[j][containedSamp[i]]
			else # draw one taxonomy 
				rectArr[i] += new_data_matrix_onLayer[selectedTaxnomy][containedSamp[i]]

		# 2 add info 
		if totalFlag
			d3.select('#containedTaxonomy_' + donutID).html( unique_taxonomy_comb_onLayer.length + ' Taxonomy in Total')
		else
			thisTaxonomyName = unique_taxonomy_comb_onLayer[selectedTaxnomy][0] + ',' + unique_taxonomy_comb_onLayer[selectedTaxnomy][1] + ',' + unique_taxonomy_comb_onLayer[selectedTaxnomy][2] + ',' + unique_taxonomy_comb_onLayer[selectedTaxnomy][3] + ',' + unique_taxonomy_comb_onLayer[selectedTaxnomy][4] + ',' + unique_taxonomy_comb_onLayer[selectedTaxnomy][5] + ',' + unique_taxonomy_comb_onLayer[selectedTaxnomy][6]
			d3.select('#containedTaxonomy_' + donutID).html( thisTaxonomyName )

		# 3 find the max standardized value of all 
		if d3.max(rectArr) > standardizedValue
			standardizedValue = d3.max(rectArr)

		# 4 draw each column chart
		if toggleStandard == 'dynamic'
			yScale = d3.scale.pow().exponent(.5).domain([0, d3.max(rectArr)]).range([2, 160])
		else 
			yScale = d3.scale.pow().exponent(.5).domain([0, standardizedValue]).range([2, 160])

		eachBarWidth = 20
		$('#selectedColumn_' + donutID).empty() # clear canvas first
		rectContainedSamp = d3.select('#selectedColumn_' + donutID)
		rectContainedSamp.selectAll('rect').data(rectArr).enter().append('rect')
			.attr('height', (d) -> return yScale(d))
			.attr('width', eachBarWidth - 3 )
			.attr("x", (d,i) -> return eachBarWidth * i + 50 )
			.attr("y", (d,i) -> return 170 - yScale(d))
			.style("fill", (d,i) -> if totalFlag then return '#ff8900' else return fillCol[selectedTaxnomy%20] )
		rectContainedSamp.selectAll('text')
			.data(containedSamp)
		.enter().append('text')
			.text( (d,i) -> return String(selected_phinchID_array[i]))  # .substring(0,9) 
			.attr('x', 0)
			.attr('y', 0)
			.attr('width', eachBarWidth )
			.attr('text-anchor', 'end')
			.attr("font-size", "9px")
			.attr('fill', '#444')
			.attr('transform', (d,i) -> return "translate(" + (eachBarWidth * i + 65) + ", 200)rotate(-45)")

		rule = rectContainedSamp.selectAll('g.rule')
			.data(yScale.ticks(10))
		.enter().append('g')
			.attr('class','rule')
			.attr('transform', (d) -> return "translate(0," + ( 172 - yScale(d) ) + ")" )	
		rule.append('line')
			.attr('x1', 45)
			.attr('x2', 55 + containedSamp.length * 20)
			.style("stroke", (d) -> return if d then "#eee" else "#444" )
			.style("stroke-opacity", (d) -> return if d then 0.7 else null )
		rule.append('text')
			.attr('x', 40)
			.attr("font-size", "9px")
			.attr('text-anchor', 'end')
			.attr('fill', '#444')
			.text( (d,i) -> return format(d) )

	#####################################################################################################################  
	#############################################  Bars By Attributes  ##################################################  
	#####################################################################################################################  
	
	drawTaxonomyByAttributes : (cur_attribute) -> 

		$('#attributes_dropdown').fadeIn(800)
		selected_new_data_matrix_onLayer = new Array(new_data_matrix_onLayer.length) # only contains selected samples

		# 1 find all different values
		attributes_array = []
		countEmpty = []
		for i in [0..selected_samples.length-1]
			if attributes_array.indexOf( parseFloat( biom.columns[ selected_samples[i] ].metadata[cur_attribute].split(" ")[0]) ) == -1 and biom.columns[ selected_samples[i] ].metadata[cur_attribute] != 'no_data'
				attributes_array.push( parseFloat( biom.columns[ selected_samples[i] ].metadata[cur_attribute].split(" ")[0]) )

		attributes_array.sort( (a,b) -> return a - b )
		count = new Array( attributes_array.length)
		for i in [0..attributes_array.length-1]
			count[i] = []
		
		for i in [0..new_data_matrix_onLayer.length-1]  # layer 2 - 68 
			# 1 store only selected data
			selected_new_data_matrix_onLayer[i] = new Array(attributes_array.length)
			for j in [0..attributes_array.length-1]
				selected_new_data_matrix_onLayer[i][j] = 0.0
			for j in [0..selected_samples.length-1]
				arr_id = attributes_array.indexOf( parseFloat( biom.columns[ selected_samples[j] ].metadata[cur_attribute].split(" ")[0]) )
				selected_new_data_matrix_onLayer[i][arr_id] += new_data_matrix_onLayer[i][ selected_samples[j] ] 

		for i in [0..selected_samples.length-1]
			if ! isNaN( parseFloat( biom.columns[ selected_samples[i] ].metadata[cur_attribute].split(" ")[0]) )
				count[ attributes_array.indexOf( parseFloat( biom.columns[ selected_samples[i] ].metadata[cur_attribute].split(" ")[0]) ) ].push(selected_samples[i])
			else 
				countEmpty.push(selected_samples[i])

		# 2 Build the viz data 		
		vizdata = new Array(selected_new_data_matrix_onLayer.length)
		sumEachCol = new Array(attributes_array.length)

		for i in [0..selected_new_data_matrix_onLayer.length-1] # # layer 2 - 68 
			vizdata[i] = new Array(attributes_array.length)
			for j in [0..attributes_array.length-1]
				vizdata[i][j] = new Object()
				vizdata[i][j].x = j 
				vizdata[i][j].y = selected_new_data_matrix_onLayer[i][j]
				vizdata[i][j].name = unique_taxonomy_comb_onLayer[i][0] + ',' + unique_taxonomy_comb_onLayer[i][1] + ',' + unique_taxonomy_comb_onLayer[i][2] + ',' + unique_taxonomy_comb_onLayer[i][3] + ',' + unique_taxonomy_comb_onLayer[i][4] + ',' + unique_taxonomy_comb_onLayer[i][5] + ',' + unique_taxonomy_comb_onLayer[i][6] 

		for i in [0..attributes_array.length-1]
			sumEachCol[i] = 0
			for j in [0..selected_new_data_matrix_onLayer.length-1]
				vizdata[j][i].y0 = sumEachCol[i]
				sumEachCol[i] += selected_new_data_matrix_onLayer[j][i]

		@drawBasicColumns(attributes_array, cur_attribute, count)

		$('#count_container').html("") 
		content = ''
		if selected_attributes_units_array[selected_attributes_array.indexOf(cur_attribute)] is undefined # Unit 
			content += '<span>' + cur_attribute + '</span>'
		else
			content += '<span>' + cur_attribute + ', ' + selected_attributes_units_array[selected_attributes_array.indexOf(cur_attribute)] + '</span>'
		if attributes_array.length > 0
			for i in [0..attributes_array.length-1]
				content += '<p><b>' + attributes_array[i] + '</b>:&nbsp;&nbsp;' 
				if count[i].length == 0
					content += 'no samples'
				else if count[i].length == 1
					content += count[i][0]
				else if count[i].length > 2	
					for j in [0..count[i].length-2]
						# content += selected_phinchID_array[count[i][j]] + ' (' + count[i][j] + '), '
						content += count[i][j] + ', '
					content += count[i][count[i].length - 1]
				content += '</p>'
		if countEmpty.length > 0
			content += '<p><i><b>* NaN value samples</b>:&nbsp;&nbsp;'
			for i in [0..countEmpty.length-1]
				content += countEmpty[i] + ', '
			content += '</i></p>'
		$('#count_container').html(content)

		# create legend 
		legendArr = []
		for i in [0..selected_new_data_matrix_onLayer.length-1]
			temp = new Object() 
			temp.originalID = i # for color purpose 
			temp.value = 0
			temp.name = unique_taxonomy_comb_onLayer[i][0] + ',' + unique_taxonomy_comb_onLayer[i][1] + ',' + unique_taxonomy_comb_onLayer[i][2] + ',' + unique_taxonomy_comb_onLayer[i][3] + ',' + unique_taxonomy_comb_onLayer[i][4] + ',' + unique_taxonomy_comb_onLayer[i][5] + ',' + unique_taxonomy_comb_onLayer[i][6] 
			for j in [0..selected_new_data_matrix_onLayer[0].length-1]
				temp.value += selected_new_data_matrix_onLayer[i][j]
			legendArr.push(temp)

		@createLegend(legendArr)

	drawBasicColumns: (attributes_array, cur_attribute, count) -> 

		# console.log count
		@fadeInOutCtrl()
		# 1 Plot     
		w = 120 + sumEachCol.length * 18
		h = 800
		max_single = d3.max(sumEachCol)
		margin = {top: 20, right: 20, bottom: 20, left: 100}
		x = d3.scale.ordinal()
			.domain(vizdata[0].map( (d) -> return d.x ))
			.rangeRoundBands([0, w - margin.right - margin.left])
		y = d3.scale.linear() # .sqrt()
			.domain([0, max_single ])
			.range([0, h - margin.top - margin.bottom])

		svg = d3.select("#taxonomy_container").append("svg")
			.attr("width", w )
			.attr("height", h + 100 )
		.append("g")
			.attr("transform", "translate(" + margin.left + "," + margin.top + ")")
		
		# add tooltip 
		tooltip = d3.select("#taxonomy_container")
			.append("div")
			.attr("class", "basicTooltip")
			.style("visibility", "hidden")

		# add main viz svg
		taxonomy = svg.selectAll('g.taxonomy')
			.data(vizdata)
		.enter().append('g')
			.attr('class', 'taxonomy')
			.style('fill', (d,i) -> return fillCol[i%20]  )
			.on 'mouseover', (d,i) -> 
				d3.select(this).style({ 'fill': d3.rgb(fillCol[i%20]).darker() })
			.on 'mouseout', (d,i) -> 
				d3.select(this).style({ 'fill': fillCol[i%20] })

		# add each bar
		rect = taxonomy.selectAll('rect')
			.data(Object)
		.enter().append('rect')
			.attr('x', (d, i) -> return 20 * i)
			.attr('y', (d, i) -> 
				if !percentage
					return h - y(d.y) - y(d.y0)
				else 
					return h - ( y(d.y) + y(d.y0) ) / sumEachCol[i] * max_single
			)
			.attr('height', (d,i) -> 
				if !percentage
					return y(d.y)
				else 
					return y(d.y) / sumEachCol[i] * max_single 
			)
			.attr('width', 15)
			.on('mouseover', (d,i) ->
				content = ""
				if attributes_array.length > 0
					for i in [0..attributes_array.length-1]
						content += '<b>' + attributes_array[i] + '</b>:&nbsp;&nbsp;' 
						if count[i].length == 1
							content += selected_phinchID_array[count[i][0]] + ' (<i>' + count[i][0] + '</i>)'
						else if count[i].length > 2	
							for j in [0..count[i].length-2]
								content += selected_phinchID_array[count[i][j]] + ' (<i>' + count[i][j] + '</i>), '
							content += selected_phinchID_array[count[i][count[i].length - 1]] + ' (<i>' + count[i][count[i].length - 1] + '</i>)'
						content += '</br>'

				tooltip.html( "<div class='attrColHead'><b>TAXONOMY: </b>" + d.name + "<br/><b>TOTAL READS: </b> " + format(d.y) + "</div><div class='attrColBody'>" + content + "</div>")
				tooltip.style( { "visibility": "visible", top: (d3.event.pageY - 10) + "px", left: (d3.event.pageX + 10) + "px" })
			)
			.on('mouseout', (d,i) -> 
				tooltip.style("visibility", "hidden")
			)

		# add x-axis
		label = svg.selectAll('text')
			.data( attributes_array )
		.enter().append('text')
			.text( (d,i) -> return d )
			.attr('x', 0)
			.attr('y', 0)
			.attr('text-anchor', 'middle')
			.attr("font-size", "10px")
			.attr('fill', '#444')
			.attr('transform', (d,i) -> return "translate(" + (20 * i + 7.5) + ", " + (h + 15) + ")rotate(-45)")

		# add y-axis
		rule = svg.selectAll('g.rule')
			.data(y.ticks(10))
		.enter().append('g')
			.attr('class','rule')
			.attr('transform', (d) -> return "translate(0," + ( h - y(d) ) + ")" )	

		rule.append('line')
			.attr('x2', (d,i) -> return w + 20)
			.style("stroke", (d) -> return if d then "#eee" else "#444" )
			.style("stroke-opacity", (d) -> return if d then 0.7 else null )

		rule.append('text')
			.attr('x', - 25 )
			.attr("font-size", "9px")
			.attr('text-anchor', 'end')
			.attr('fill', '#444')
			.text (d,i) -> 
				if !percentage
					return format(d) 
				else 
					return Math.round( i / (y.ticks(10).length ) * 100 ) + '%'

		# add text legend on the bottom
		attr_n_unit = cur_attribute 
		if selected_attributes_units_array[selected_attributes_array.indexOf(cur_attribute)] isnt undefined
			attr_n_unit += ', ' + selected_attributes_units_array[selected_attributes_array.indexOf(cur_attribute)] 
		svg.append('text')
			.attr('x', w / 2 - 80)
			.attr('y', h + 40)
			.attr('font-size', '11px')
			.text(attr_n_unit)


	#####################################################################################################################         
	############################################### Bubble by OTU #######################################################  
	#####################################################################################################################  

	drawOTUBubble: () ->
		
		@fadeInOutCtrl()
		
		# 0 Prepare the data 
		data = {}
		data.name = 'BIOM'
		data.children = new Array(unique_taxonomy_comb_onLayer.length)
		for i in [0..unique_taxonomy_comb_onLayer.length-1]
			data.children[i] = new Object()
			data.children[i].name = unique_taxonomy_comb_onLayer[i][0] + ',' + unique_taxonomy_comb_onLayer[i][1] + ',' + unique_taxonomy_comb_onLayer[i][2] + ',' + unique_taxonomy_comb_onLayer[i][3] + ',' + unique_taxonomy_comb_onLayer[i][4] + ',' + unique_taxonomy_comb_onLayer[i][5] + ',' + unique_taxonomy_comb_onLayer[i][6]  
			data.children[i].children = new Array(unique_taxonomy_comb_count[i])
			data.children[i].counter = 0
			for j in [0..unique_taxonomy_comb_count[i]-1]
				data.children[i].children[j] = new Object()
				data.children[i].children[j].id = undefined
				data.children[i].children[j].size = 0
		
		for i in [0..biom.data.length-1]
			flag = true
			rowID = map_array[biom.data[i][0]]
			for j in [0..unique_taxonomy_comb_count[rowID]-1]
				if data.children[rowID].children[j].id == biom.data[i][0]
					flag = false
					data.children[rowID].children[j].size += biom.data[i][2]
			if flag
				data.children[rowID].children[data.children[rowID].counter].id = biom.data[i][0]
				data.children[rowID].children[data.children[rowID].counter].size += biom.data[i][2]
				data.children[rowID].counter += 1

		# 1 Layout
		w = 1200
		h = 1100
		r = 1000
		x = d3.scale.linear().range([5, r])
		y = d3.scale.linear().range([5, r])
		fontScale = d3.scale.linear().domain([0, 0.5]).range([10, 20])
		node = null
		root = null
		pack = d3.layout.pack().size([r, r]).value( (d) -> return Math.sqrt(d.size) )  ## return d.size ## but too many small ones 
 
		vis = d3.select("#taxonomy_container").append("svg:svg")
			.attr("width", 1200)
			.attr("height", 1100)
			.append('svg:g')
			.attr("transform", "translate(" + (w - r) / 2 + ", 10)")

		# 2 Filter 
		threshold = 2000 # if the threshold is too high, there's no point in doing this bubble chart
		filteredData = {}
		filteredData.name = 'BIOM'
		filteredData.children = []
		for i in [0..data.children.length-1]
			if data.children[i].counter > threshold
				filteredData.children.push(data.children[i])

		# console.log data;
		# console.log filteredData;

		# 3 Viz
		node = filteredData;
		root = filteredData;
		nodes = pack.nodes(root);
		that = this
		vis.selectAll("circle").data(nodes)
			.enter().append("svg:circle")
			.attr("class", (d) -> if d.children != null then return 'parent' else return 'child' )		
			.attr("cx", (d) -> 
				if isNaN(d.x) 
					return 0 
				else 
					return d.x
			)
			.attr("cy", (d) -> 
				if isNaN(d.y) 
					return 0 
				else 
					return d.y
			)
			.attr("r", (d) -> return d.r)
			.style("fill", '#ff8900')
			# .on "click", (d) -> if node == d then return that.zoomBubble(vis, root) else return that.zoomBubble(vis, d)
		vis.selectAll("text").data(nodes)
			.enter().append("svg:text")
			.attr("class", (d) -> if d.children != null then return 'parent' else return 'child' )
			.attr("x", (d) -> return d.x )
			.attr("y", (d) -> d.y += d.r * (Math.random() - 0.5); return d.y )  ## return d.y ## but d.y could be the same in most cases, so give it a random y position
			.attr("font-size", (d) -> return fontScale( d.r / r) + "px")
			.attr("text-anchor", "middle")
			.style("fill",'#ff8900')
			.style("opacity", (d) -> if d.r > 50 then return 0.8 else return 0 )
			.text((d) -> return d.name )

		# d3.select(window).on("click", () -> that.zoomBubble(vis, root) )

	zoomBubble: (vis, d) -> 
		r = 1000
		k = r / d.r / 2;
		x = d3.scale.linear().range([5, r])
		y = d3.scale.linear().range([5, r])
		x.domain([d.x - d.r, d.x + d.r])
		y.domain([d.y - d.r, d.y + d.r])
		t = vis.transition().duration( () -> if d3.event.altKey? then return 750 else return 500)

		t.selectAll("circle")
			.attr("cx", (d) -> return x(d.x) )
			.attr("cy", (d) -> return y(d.y) )
			.attr("r", (d) -> return k * d.r )

		t.selectAll("text")
			.attr("x", (d) -> return x(d.x) )
			.attr("y", (d) -> return y(d.y) )
			.style("opacity", (d) -> return k * d.r > 20 ? 1 : 0)

		node = d
		d3.event.stopPropagation()

	#####################################################################################################################         
	###############################################   UTILITIES   #######################################################  
	#####################################################################################################################  

	createLegend: (legendArr) ->
		legendArr.sort( (a,b) -> return b.value - a.value ) # specify the sorting order
		$('#legend_container').html('')
		content = '<ul>' # <p>The Top 10 Sequence Reads: </p>
		if legendArr.length < 10
			legendLen = legendArr.length - 1 
		else
			legendLen = 9
		for i in [0..legendLen]
			content += '<li><span style = "display:block; background-color:' + fillCol[ legendArr[i].originalID % 20] + '; height: 12px; width: 12px; float: left; margin: 2px 0px;" ></span>&nbsp;&nbsp;&nbsp;' + legendArr[i].name + '&nbsp;&nbsp;<em>' + format(legendArr[i].value) + '</em></li>'
		content += '</ul>'
		$('#legend_container').append(content)  
		if $('#legend_header').html() == 'TOP SEQUENCES'
			$('#legend_header').css('width', $('#legend_container').width() - 1 )

	fadeInOutCtrl: () -> 

		$('#taxonomy_container').html("")
		$('#loadingIcon').css('opacity','1')
		$('#loadingIcon').animate( {opacity: 0}, {duration: 800, specialEasing: {width: "easeInOutQuad"}, complete: () ->
			
			$('#taxonomy_container').animate( {opacity: 1}, {duration: 2000} )
			$('#layerSwitch').fadeIn(500)

			if VizID == 0
				$('#outline').fadeIn(500)
				$('#tags').fadeIn(500)
				$('#PercentValue').fadeIn(500)
				$('#legend_header').fadeIn(500)
				$('#sankeyMsgBox').html("* If the page is not showing correctly, please refresh")
			if VizID == 1
				$('#ListBubble').fadeIn(500)
				$('#tags').fadeIn(500)
				$('#bubbleSliderContainer').fadeIn(500)
				$('.ui-slider-horizontal .ui-slider-handle').css({
					"margin-top": "-2px",
					"border": "2px solid #ff8900",
					"background": "#fff"
				})
			if VizID == 2
				$('#tags').fadeIn(500)
				$('#sankeyMsgBox').html( "* " + unique_taxonomy_comb_count.length + " unique paths, cannot go deeper to the 6th or 7th layer.")
			if VizID == 4
				$('#PercentValue').fadeIn(500)
				$('#legend_header').fadeIn(500)
				$('#count_header').fadeIn(500)
			if VizID == 5
				$('#layerSwitch').hide()
		})

	exportCallback: (data, textStatus, xhr) ->
		console.log 'exportCallback!'
		convertResult = JSON.parse(data)
		console.log convertResult
		if convertResult['code'] is 0 and convertResult['err'] is ''
			$('#downloadPreview img').attr('src', 'data:image/png;base64,' + convertResult['out']);
			$('#downloadPreview a').attr('href', 'data:image/png;base64,' + convertResult['out']);
			$('#exportHeader').html('Preview Image, click to download!')

		else
			$('#exportHeader').html('unable to download image!')
		$('#exportLoading').fadeOut(500);
	
	downloadChart: () =>
		$('#exportShareDiv').fadeIn(500);
		$('#exportLoading').fadeIn(500);
		$('#downloadPreview img').attr('src', '');
		$('#downloadPreview a').attr('href', '');
		$('#exportHeader').html('Generating Image')

		$('#exportShareDiv .icon-remove').click( (e) -> $('#exportShareDiv').fadeOut(500); ) 

		svg = $('svg')
		svgStringData = svg.wrap('<p>').parent().html()
		postData = {svg: svgStringData}
		exportEndpoint = backendServer + 'export.php'
		$.post(exportEndpoint, postData, @exportCallback)

	doZip: () ->

		obj_phinch = JSON.stringify(biom)
		obj_log = {}
		obj_log.selected_sample = selected_samples;
		obj_log.selected_sample_phinchID = selected_phinchID_array;
		obj_log.selected_attributes_array = selected_attributes_array;
		obj_log.selected_attributes_units_array = selected_attributes_units_array;
		obj_log = JSON.stringify(obj_log);

		zip = new JSZip();
		zip.file( filename + ".phinch", obj_phinch);
		zip.file( filename + "_log.json", obj_log);

		content = zip.generate({type:"blob"});
		saveAs(content, "phinch.zip");

		$('#downloadFile i').removeClass('icon-spinner icon-spin')
		$('#downloadFile i').addClass('icon-download')
	shareViz: () =>
		console.log 'share'
		biomData = JSON.stringify(biom)
		#console.log CryptoJS.SHA1(biomData).toString()
		$('#sharingInfo').show()
		$('#sharingInfo .loadingText').text('Preparing data')
		w = new Worker('scripts/hashWorker.js')
		w.addEventListener('message', (e) =>
			console.log 'worker message'
			console.log e
			hashValue = e.data
			@shareHashExists(hashValue)
		)
		w.postMessage(biomData)
	shareHashExists: (hash) ->
		@shareHash = hash
		hashExistsEndpoint = backendServer + "hashExists.php"
		$.get(hashExistsEndpoint, {hash: hash}, @shareHashExistsCallback)
	shareHashExistsCallback: (data, textStatus, xhr) =>
		console.log data
		@shareHashExists = data
		$('#sharingInfo .loading').hide()
		$('#sharingInfo .shareForm').show()
		$('#sharingInfo .shareButton').off('click', @submitShare).on('click', @submitShare)
	submitShare: () =>
		console.log 'submit share'
		console.log @shareHash
		console.log LayerID + " " + VizID
		layerName = layerNameArr[LayerID - 1]
		vizName = @vizName
		@shareData = {
			from_email: $('#sharingInfo #shareFromEmail').val(),
			to_email: $('#sharingInfo #shareToEmail').val(),
			from_name: $('#sharingInfo #shareFromName').val(),
			to_name: $('#sharingInfo #shareToName').val(),
			notes: $('#sharingInfo #shareNotes').val(),
			biom_file_hash: @shareHash,
			layer_name: layerName,
			filter_options_json: JSON.stringify(filterOptionJSON),
			viz_name: vizName
		}
		if @shareHashExists is 'true'
			@shareRequest()
		else
			@generateBiomZip()

	generateBiomZip: () =>
		biomData = JSON.stringify(biom)
		console.log biomData.length
		w = new Worker('scripts/zipWorker.js')
		w.addEventListener('message', (e) =>
			console.log e.data
			@shareData.biomFile = e.data
			@shareRequest()
		)
		w.postMessage(biomData)
	shareRequest: () =>
		shareEndpoint = backendServer + "shareViz.php"
		$.post(shareEndpoint, @shareData, @shareCallback, 'json')
	shareCallback: (data, textStatus, xhr) =>
		console.log(data)
		if data.status is 'ok'
			$('#sharingInfo .shareForm').hide();
			$('#sharingInfo .results').remove();
			results = d3.select('#sharingInfo').append('div').attr('class','results')
			results.append('div').text('Your visualization has been shared. It is available here:')
			src = document.location.origin + document.location.pathname + "?shareID=" + data.urlHash
			results.append('a').attr('href',src).text(src)		
				




window.taxonomyViz = taxonomyViz

