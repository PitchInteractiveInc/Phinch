class taxonomyViz

	biom = null
	percentage = false
	LayerID = 2
	VizID = null
	vizdata = null
	sumEachCol = null
	sumEachTax = null
	new_data_matrix_onLayer = null
	unique_taxonomy_comb_onLayer = null
	format = d3.format(',d')
	fillCol = ['#3182bd', '#6baed6', '#9ecae1', '#c6dbef', '#e6550d', '#fd8d3c', '#fdae6b', '#fdd0a2', '#31a354', '#74c476', '#a1d99b', '#c7e9c0', '#756bb1', '#9e9ac8', '#bcbddc', '#dadaeb', '#636363', '#969696', '#bdbdbd', '#d9d9d9']
	deleteOTUArr = []
	deleteSampleArr = []
	new_data_matrix = []
	unique_taxonomy_comb = []
	columns_sample_name_array = []
	map_array = []
	unique_taxonomy_comb_count = []
	selected_samples = []
	groupable = []
	selected_attributes_array = []

	constructor: (_VizID) ->
		VizID = _VizID
		db.open(
			server: "BiomSample", version: 1,
			schema:
				"biomSample": key: keyPath: 'id', autoIncrement: true,
		).done (s) => 
			s.biomSample.query().all().execute().done (results) =>
				
				# 1 get selected samples first 
				selected_samples = results[results.length-1].selected_sample
				groupable = results[results.length-1].groupable
				selected_groupable_array = results[results.length-1].selected_groupable_array
				selected_attributes_array = results[results.length-1].selected_attributes_array
				selected_attributes_units_array = results[results.length-1].selected_attributes_units_array
				
				# 2 open the biom file 
				db.open(
					server: "BiomData", version: 1,
					schema:
						"biom": key: keyPath: 'id', autoIncrement: true,
				).done (s) => 
					s.biom.query().all().execute().done (results) => 
						currentData = results[results.length-1]
						biom = JSON.parse(currentData.data)

						$("#file_details").html("");
						$("#file_details").append( "ANALYZING &nbsp;<span>" + currentData.name + "</span> &nbsp;&nbsp;&nbsp;" + (parseFloat(currentData.size.valueOf() / 1000000)).toFixed(1) + " MB <br/><br />Observation &nbsp;<em>" + format(biom.shape[0]) + "</em> &nbsp;&nbsp;&nbsp; Selected Samples &nbsp;<em>" + format(selected_samples.length) + "</em>")

						# 3 Click events 
						$('.layer_change').click (evt) => 
							LayerID = parseInt evt.currentTarget.id.replace("layer_","")
							$('#layer_' + LayerID).addClass("loading_notes").delay(800).queue (n) =>
								if $('#otherFuncs li:eq(1) .c option:selected').val() == 'Percent' 
									percentage = true 
								else 
									percentage = false	
								@generateVizData()
								return n()

						# 4 Layer change 
						$('#otherFuncs li:eq(1) .c select').change (evt) =>
							if evt.currentTarget.value == 'Percent'
								percentage = true
							else
								percentage = false
							LayerID = parseInt($('.current_layer').attr('id').replace('layer_',''))
							@generateVizData()

						if VizID == 5
							LayerID = 7 
						@prepareData()
						@generateVizData()

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
		# console.log new_data_matrix_onLayer

		if VizID == 0
			@filterControl()
			@drawD3Bar()
		else if VizID == 1
			@drawTaxonomyBubble()
		else if VizID == 2 
			@drawTaxonomySankey()
		else if VizID == 3
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
			if selected_attributes_array.length > 0 
				d3.select('#viz_container').append('div').attr('id', 'countResult');
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
			@drawOTUBubble()

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
		
		# 3 generate viz - get the max value of each column, i.e. total taxonomy within a sample 
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
        # clean canvas     
		w = 1200 
		h = sumEachCol.length * 14 + 200
		max_single = d3.max(sumEachCol)
		margin = {top: 100, right: 20, bottom: 20, left: 50}
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

		# add small panel when click 
		infoPanel = d3.select("#taxonomy_container")
			.append("div")
			.attr("class", "tooltipOverSmallThumb")
			.style("visibility", "hidden")

		# add the deletion panel
		delePanel = d3.select("#taxonomy_container")
			.append("div")
			.attr("class", "tooltipOverSmallThumb")
			.style("visibility", "hidden")

		# add main viz svg
		taxonomy = svg.selectAll('g.taxonomy')
			.data(vizdata)
		.enter().append('g')
			.attr('class', 'taxonomy')
			.style('fill', (d,i) -> return fillCol[i%20]  )
			.on 'mouseover', (d,i) ->
				# d3.select(this).style({ 'fill': d3.rgb(fillCol[i%20]).darker() })
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

		# add each bar
		rect = taxonomy.selectAll('rect')
			.data(Object)
		.enter().append('rect')
			.attr 'y', (d, i) -> 
					return 14 * i
			.attr 'x', (d, i) -> 
				if !percentage
					return y(d.y0)
				else 
					return y(d.y0) / sumEachCol[i] * max_single
			.attr 'width', (d,i) -> 
				if !percentage
					return y(d.y)
				else 
					return y(d.y) / sumEachCol[i] * max_single 
			.attr('height', 12)
			.on 'mouseover', (d,i) ->
				content = ''
				content += '<div class="PanelHead">' + columns_sample_name_array[d.x] + '<br/>' + d.name+ '</div><div class="PanelRule"></div>'
				content += '<div class="PanelvaluesContainer">In this sample:<br/><span class="PanelTtl">total occurrence<br/><b>' + format(sumEachCol[i]) + '</b></span><span class="PanelValue">this occurrence</br><b>' + format(d.y) + '</b></span><span class="PanelPercent">percent of total</br><b>' + (d.y / sumEachCol[i] * 100).toFixed(1) + '%</b></span>'
				content += 'Compared to all samples:<br/>'
				if d.y / sumEachTax[d.i] * sumEachCol.length > 2
					content += '<div class="PanelSlider" style="width:' + (sumEachTax[d.i] / d.y / sumEachCol.length * 100) + '%;"></div><div class="PanelTrueValue" style="width:100%;"></div>'
				else 
					content += '<div class="PanelSlider" style="width: 50%;"></div><div class="PanelTrueValue" style="width:' + ( d.y / sumEachTax[d.i] * sumEachCol.length * 50) + '%;"></div>'
				content += '<div><span class="PanelTtlAvg">total avg: ' + ( 100 / sumEachCol.length).toFixed(2)  + '%</span>, this sample percent: ' + (d.y / sumEachTax[d.i] * 100).toFixed(2) + '%</div></div>'		
				infoPanel.html(content)
				infoPanel.style( { "visibility": "visible", top: (d3.event.pageY - 10) + "px", left: (d3.event.pageX + 10) + "px" })
			.on 'mouseout', (d,i) -> 
				infoPanel.style( { "visibility": "hidden"})
			.on 'click', (d,i) ->
				content = '' 
				content = '<b><i>Remove sample '+ d.x + '?</i></b>&nbsp;&nbsp;<i class="icon-remove icon-large" id = "iconRemoverPanel"></i><div>'
				if deleteSampleArr.length > 0
					content += '<br/>Deleted samples: <ul id = "deleteSampleArr">'
					for k in [0..deleteSampleArr.length-1]
						content += '<li><input type="checkbox" id="delete_' + deleteSampleArr[k] + '" checked /><label style="margin-top: 1px;" for="delete_' + deleteSampleArr[k] + '"></label>&nbsp;&nbsp;Sample ' + deleteSampleArr[k] + '</li>'
					content += '</ul></div>'
				delePanel.html(content)
				delePanel.style( { "visibility": "visible", top: (d3.event.pageY - 10) + "px", left: (d3.event.pageX + 10) + "px" })
				infoPanel.style( { "visibility": "hidden"})

				$('#iconRemoverPanel').click () -> 
					deleteSampleArr.push(d.x)
					that.drawD3Bar()
					
				$('#deleteSampleArr li').each (index) ->
					$(this).click () ->
						thisSampID = parseInt( $(this)[0].children[0].id.replace('delete_',''))
						if $('#delete_' + thisSampID).is(':checked')					
							$('#delete_' + thisSampID).prop("checked", false)
							deleteSampleArr.splice(deleteSampleArr.indexOf(thisSampID),1)
						else
							$('#delete_' + thisSampID).prop("checked", true)
							deleteSampleArr.push(thisSampID)
						that.drawD3Bar()

		# add y-axis
		label = svg.selectAll('text')
			.data(x.domain())
		.enter().append('text')
			.text (d,i) ->
				if i%2 == 1 then return d
			.attr('x', - 20)
			.attr 'y', (d,i) -> 
					return 14 * i + 9
			.attr('text-anchor', 'middle')
			.attr("font-size", "9px")
			.attr('fill', '#444')	

		# add title & x-axis 
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
					return Math.round( i / (y.ticks(10).length) * 100 ) + '%'

		# create fake divs for minimap
		divCont = ''
		if !percentage
			for i in [0..sumEachCol.length-1]
				divCont += '<div class="fake" style="width:' + y(sumEachCol[i]) + 'px;"></div>'
		else 
			for i in [0..sumEachCol.length-1]
				divCont += '<div class="fake" style="width:' + y(max_single) + 'px;"></div>'

		$('#fake_taxonomy_container').html(divCont)	
		$('#viz_container').append('<canvas id="outline" width="150" height="' + (window.innerHeight - 280) + '"></canvas>')

		# create a minimap
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
					content = '<i class="icon-remove icon-large" style="float:right; margin-right: 5px;" id = "iconRemover"></i><ul>'
					for i in [0..searchList.length-1]
						if deleteOTUArr.indexOf(i) != -1 
							content += '<li><span style = "display:block; background-color:#aaa; height: 12px; width: 12px; float: left; margin: 2px 0px;" ></span>&nbsp;&nbsp;'
							content += '<input type="checkbox" id="search_' + i + '"/><label style="margin-top: 1px;" for="search_' + i + '"></label>&nbsp;&nbsp;&nbsp;'
						else
							content += '<li><span style = "display:block; background-color:' + fillCol[ availableTags.indexOf(searchList[i]) % 20] + '; height: 12px; width: 12px; float: left; margin: 2px 0px;" ></span>&nbsp;&nbsp;'
							content += '<input type="checkbox" id="search_' + i + '" checked /><label style="margin-top: 1px;" for="search_' + i + '"></label>&nbsp;&nbsp;&nbsp;'
						content += searchList[i] + '</li>'
					content += '</ul>' 	
					$('#autoCompleteList').append(content)

					$('#autoCompleteList ul li').each (index) ->
						# that = this 
						$(this).mouseout () -> 
							d3.selectAll('g.taxonomy').filter((d,i) -> (i is index) )
								.style('fill', fillCol[index%20] )							

						$(this).mouseover () ->
							d3.selectAll('g.taxonomy').filter((d,i) -> (i is index) )
								.style('fill', d3.rgb( fillCol[index%20] ).darker() )

						$(this).click () ->
							if $('#search_' + index).is(':checked')
								$('#search_' + index).prop("checked", false)
								$(this).find('span').css('background-color', '#aaa')
								$(this).css('color', '#aaa')
								deleteOTUArr.push( index )
							else
								$('#search_' + index).prop("checked", true)
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

	#####################################################################################################################         
	##############################################  Bubble Chart  #######################################################         
	#####################################################################################################################  

	drawTaxonomyBubble: () ->

		@fadeInOutCtrl()

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

		nodes = []
		color = d3.scale.category10()
		max_amount = d3.max(vizdata)
		
		# adjust min max should later be input field 
		adjust_min = 100
		adjust_max = max_amount + 1
		radius_scale = d3.scale.pow().exponent(0.25).domain([adjust_min, adjust_max]).range([3, 50])

		for i in [0..new_data_matrix_onLayer.length-1]
			if vizdata[i] > adjust_min and vizdata[i] < max_amount
				node = {
					id: i
					radius: 100 * radius_scale( vizdata[i] ) # Math.log( Math.sqrt( vizdata[i] / max_amount ) + 1 ) * 10000
					value: vizdata[i]
					name: comb_name_list[i]
					group: "medium" # 
					x: Math.random() * 1000
					y: Math.random() * 600
				}
				nodes.push node
				# nodes.sort (a,b) -> b.value - a.value

		force = d3.layout.force()
			.gravity(0.025 * LayerID)
			.nodes(nodes)
			.on("tick", (e) -> 
				node.attr("cx", (d) -> return d.x )
					.attr("cy", (d) -> return d.y )
			)
			.size([1200, 1000])
			.start()

		vis = d3.select("#taxonomy_container").append("svg")
			.attr("width", 1500)
			.attr("height", 1200)

		tooltip = d3.select("#taxonomy_container")
			.append("div")
			.attr("id", "pinch_tooltip")
			.style("visibility", "hidden")

		infoPanel = d3.select("#taxonomy_container")
			.append("div")
			.attr("id", "pinch_pannel")
			.style("visibility", "hidden")

		tooltipOverPanel = d3.select("#taxonomy_container")
			.append("div")
			.attr("id", "pinch_pannelTooltip")
			.style("visibility", "hidden")

		removePanel = d3.select("#taxonomy_container")
			.append('div')
			.attr('id',"removePanel")
			.style("visibility", "hidden")
		removePanel.append('i').attr('class', 'icon-remove icon-large')

		y = d3.scale.linear().domain([0, max_single]).range([1,100])
		xAxisLabels = selected_samples

		node = vis.selectAll(".node")
			.data(nodes)
		.enter().append("circle")
			.attr("class", "node")
			.attr("cx", (d) -> return d.x )
			.attr("cy", (d) -> return d.y )
			.attr("r", (d) -> d.radius / 100 )
			.style("fill", (d, i) -> return color( i%10 ) )
			.style("opacity", 0.7)
			.on('mouseover', (d, i) ->
				d3.select(this).style({opacity:'1', stroke: '#000', 'stroke-width': '3' })
				tooltip.html( "Taxonomy: " + d.name + "<br/> Total: " + vizdata[i] )
				tooltip.style( { "visibility": "visible", top: (d3.event.pageY - 10) + "px", left: (d3.event.pageX + 10) + "px" })
			)
			.on('mouseout', (d) ->
				d3.select(this).style({opacity:'0.7',stroke: 'none'})
				tooltip.style("visibility", "hidden")
			)
			.on('click', (d,i) -> 

				tooltip.style("visibility", "hidden")
				force.stop(); # in case interrupt the mouse movement 
				circleUnderMouse = this
				d3.select(this).transition()
					.attr('cx', '100')
					.attr('cy', '100')
					.duration(750)
					.ease("quad")
				d3.selectAll(".node").filter((d,i) -> (this isnt circleUnderMouse) )
					.transition()
					.style("opacity", 0) 
					.attr('cx', '-100')
					.attr('cy', '-100')
					.duration(750)
					.ease("quad")

				infoPanel.style("visibility", "visible")
				removePanel.style("visibility",'visible')
				numberPerRow = 40 
				curColor = d3.select(this).style("fill")
				infoPanel.html('<br/><span>Taxonomy: ' + d.name + '</span><svg width="860px" height="' + Math.ceil(viz_series[i].length / numberPerRow + 1) * 100 + '"></svg>') # height="100px"
				barrect = infoPanel.select('svg').selectAll('rect').data(viz_series[i])
				txtrect = infoPanel.select('svg').selectAll('text').data(xAxisLabels)
				txtrect.enter().append('text')
					.text( (d,i) -> return d )
					.attr("x", (d,i) -> return ( (i % numberPerRow) * 21 + 22) + 'px' )
					.attr("y", (d,i) -> return 35 - y(d) + 100 * Math.floor( i / numberPerRow + 1) )
					.attr("font-size", "10px")
					.style("fill", curColor)
				barrect.enter().append('rect')
					.attr('height', (d) -> return y(d) )
					.attr('width', '15px')
					.attr("x", (d,i) -> return ( (i % numberPerRow) * 21 + 21) + 'px' )  # 30 bars every line, 20 padding on left & right
					.attr("y", (d,i) -> return 20 - y(d) + 100 * Math.floor( i / numberPerRow + 1) ) # 50 padding top and bottom
					.style("fill", curColor)
					.on('mouseover', (d,i) -> 
						tooltipOverPanel.style("visibility", "visible")
						tooltipOverPanel.html( "Num: " + d )
						tooltipOverPanel.style( { "visibility": "visible", top: (d3.event.pageY - 10) + "px", left: (d3.event.pageX + 10) + "px" })
					)
					.on('mouseout', (d) -> 
						tooltipOverPanel.style("visibility", "hidden")
					)
			)

		d3.select('#removePanel').on 'click', (d) ->
			tooltip.style("display", "block")
			infoPanel.style("visibility", "hidden")
			removePanel.style("visibility",'hidden')
			force.resume() 
			d3.selectAll(".node").transition()
				.style({opacity:'0.7',stroke: 'none'})
				.attr("cx", (d) -> return d.x)
				.attr("cy", (d) -> return d.y )
				.duration(750)
				.ease("quad")

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
			yScale = d3.scale.pow().exponent(.2).domain([0, max_single]).range([0, 10])
			yScaleReverse = d3.scale.linear().domain([0, 10]).range([0, Math.pow(max_single,0.2)])

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
						tempLink = new Object() 
						tempLink.source = nodesArr.indexOf( unique_taxonomy_comb_onLayer[i][j-1] )
						tempLink.target = nodesArr.indexOf( unique_taxonomy_comb_onLayer[i][j] )
						tempLink.value = yScale(sumEachTax[i])
						tempLink.absValue = sumEachTax[i]
						taxonomySankey.links.push( tempLink )

        # clean canvas
		width = 1500
		height = 20 * unique_taxonomy_comb_onLayer.length 
		margin = {top: 20, right: 10, bottom: 20, left: 100}		
		color = d3.scale.category20();
		
		svg = d3.select("#taxonomy_container").append("svg")
			.attr("width", width )
			.attr("height", height)
		.append("g")
			.attr("transform", "translate(" + margin.left + "," + margin.top + ")")

		# add small panel when click 
		infoPanel = d3.select("#taxonomy_container")
			.append("div")
			.attr("class", "tooltipOverSmallThumb")
			.style("visibility", "hidden")

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
			.style('stroke', (d,i) -> return color(d.target.name) )
			.style("stroke-width", (d) -> return Math.max(0, d.dy) )
			.sort( (a, b) -> return b.dy - a.dy )
			.on "mouseover", (d,i) -> 
				infoPanel.html(d.source.name + " → " + d.target.name + ': ' + d.absValue)
				infoPanel.style( { "visibility": "visible", top: (d3.event.pageY - 10) + "px", left: (d3.event.pageX + 10) + "px" })
			.on "mouseout", (d,i) -> 
				infoPanel.style("visibility": "hidden")
						
		node = svg.append("g").selectAll(".node")
			.data(taxonomySankey.nodes)
		.enter().append("g")
			.attr("class", (d) -> if isNaN(d.y) then return 'nullnode' else return 'node')
			.attr("transform", (d) -> if !isNaN(d.y) then return "translate(" + d.x + "," + d.y + ")" )

		node.append("rect")
			.attr("height",  (d) -> if d.dy < 1 then return 1 else return d.dy )
			.attr("width", sankey.nodeWidth())
			.style("fill",  (d, i) -> return color(d.name) )
			.on "mouseover", (d,i) -> 
				temp = 0 
				for i in [0..d.targetLinks.length-1]
					temp += d.targetLinks[i].absValue
				infoPanel.html( d.name + ': ' + temp)
				infoPanel.style( { "visibility": "visible", top: (d3.event.pageY - 10) + "px", left: (d3.event.pageX + 10) + "px" })
			.on "mouseout", (d,i) -> 
				infoPanel.style("visibility": "hidden")

		node.append("text")
			.attr("x", -6)
			.attr("y",  (d) -> return d.dy / 2)
			.attr("dy", ".35em")
			.attr("text-anchor", "end")
			.attr("transform", null)
			.text( (d) -> return d.name)
		.filter( (d) -> return d.x < width / 2)
			.attr("x", 6 + sankey.nodeWidth())
			.attr("text-anchor", "start");

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
		d3.select('#taxonomy_container').attr("width", 1200).attr("height", 250 * groupable_array.length + 200)
		for i in [0..groupable_array.length-1]
			donutArr = []
			for j in [0..selected_new_data_matrix_onLayer.length-1]
				donutArr.push( selected_new_data_matrix_onLayer[j][i] )
			@drawBasicDonut( i, groupable_array[i], donutArr, count[i])

		# console.log groupable_array
		# console.log count	
		
	drawBasicDonut: ( donutID, donutName, donutData, donutContainedSamp ) -> 

		radius = 125
		yScale = d3.scale.pow().exponent(.4).domain([0, d3.max(donutData)]).range([0, 100]) # linear 
		arc = d3.svg.arc() 
			.outerRadius(radius)
			.innerRadius(50)
		pie = d3.layout.pie() 
			.sort(null)
			.value( (d) -> return yScale(d) )
		
		# 1 append each svg
		d3.select('#taxonomy_container').append('div')
			.attr("id", "donut_" + donutID)
			.attr("class", "donutDiv")
		svg = d3.select('#donut_' + donutID).append('svg')
			.attr("width", 300)
			.attr("height", 250)
			.style("float", "left")
		.append("g")
			.attr("transform", "translate(" + 125 + "," + 125 + ")")

		# 2 add category name 
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
				# that.drawBasicRect(true, donutContainedSamp, donutID, null)
			.on 'click', (d,i) ->
			 	that.drawBasicRect(false, donutContainedSamp, donutID, i)

		infoPanel = d3.select('#donut_' + donutID)
			.append("div")
			.attr("class", "panelCombSample")
			.html('<span class="containedTaxonomy" id="containedTaxonomy_' + donutID + '"></span><div id="selectedColumn_' + donutID + '"></div>')

		@drawBasicRect(true, donutContainedSamp, donutID, null)

	drawBasicRect: (totalFlag, containedSamp, donutID, selectedTaxnomy) ->

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
		d3.select('#containedTaxonomy_' + donutID).html("")
		if totalFlag
			d3.select('#containedTaxonomy_' + donutID).html( unique_taxonomy_comb_onLayer.length + ' Taxonomy in Total')
		else
			thisTaxonomyName = unique_taxonomy_comb_onLayer[selectedTaxnomy][0] + ',' + unique_taxonomy_comb_onLayer[selectedTaxnomy][1] + ',' + unique_taxonomy_comb_onLayer[selectedTaxnomy][2] + ',' + unique_taxonomy_comb_onLayer[selectedTaxnomy][3] + ',' + unique_taxonomy_comb_onLayer[selectedTaxnomy][4] + ',' + unique_taxonomy_comb_onLayer[selectedTaxnomy][5] + ',' + unique_taxonomy_comb_onLayer[selectedTaxnomy][6]
			d3.select('#containedTaxonomy_' + donutID).html( 'Taxonomy:  ' + thisTaxonomyName )

		# 3 draw each column chart 
		yScale = d3.scale.pow().exponent(.5).domain([0, d3.max(rectArr)]).range([2, 195])
		eachBarWidth = 800 / containedSamp.length
		if eachBarWidth < 10 # too many samples contained, too narrow 
			d3.select('#selectedColumn_' + donutID).html("Too many samples!" + containedSamp) 
		else 
			d3.select('#selectedColumn_' + donutID).select('svg').remove() # clear canvas first
			rectContainedSamp = d3.select('#selectedColumn_' + donutID).append('svg')
			rectContainedSamp.selectAll('rect').data(rectArr).enter().append('rect')
				.attr('height', (d) -> return yScale(d))
				.attr('width', eachBarWidth - 3 )
				.attr("x", (d,i) -> return eachBarWidth * i + 50 )
				.attr("y", (d,i) -> return 200 - yScale(d))
				.style("fill", (d,i) -> if totalFlag then return '#efc14f' else return fillCol[selectedTaxnomy%20] )
			rectContainedSamp.selectAll('text')
				.data(containedSamp)
			.enter().append('text')
				.text( (d,i) -> return d )
				.attr('x', (d,i) -> return eachBarWidth * (i + 0.5) + 50 )
				.attr('y', 210)
				.attr('width', eachBarWidth )
				.attr('text-anchor', 'middle')
				.attr("font-size", "9px")
				.attr('fill', '#444')

			rule = rectContainedSamp.selectAll('g.rule')
				.data(yScale.ticks(10))
			.enter().append('g')
				.attr('class','rule')
				.attr('transform', (d) -> return "translate(0," + ( 202 - yScale(d) ) + ")" )	
			rule.append('line')
				.attr('x1', 45)
				.attr('x2', 870)
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

		attributes_array.sort(@numberSort)
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

		for i in [0..selected_new_data_matrix_onLayer.length-1]
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

		@drawBasicColumns(attributes_array)

		# console.log selected_new_data_matrix_onLayer   
		content = ''
		content += '<div>' + cur_attribute + '</div><div>'
		if attributes_array.length > 0
			for i in [0..attributes_array.length-1]
				content += '<div>' + attributes_array[i] + ': ' 
				if count[i].length > 0
					for j in [0..count[i].length-1]
						content += count[i][j] + ', '
				else 
					content += 'no samples'
				content += '</div>'
		if countEmpty.length > 0
			content += '<div>NaN value samples: '
			for i in [0..countEmpty.length-1]
				content += countEmpty[i] + ', '
			content += '</div>'
		content += '</div>'
		$('#countResult').html(content)

	drawBasicColumns: (attributes_array) -> 

		@fadeInOutCtrl()
        # 1 Plot     
		w = if sumEachCol.length < 80 then 1500 else sumEachCol.length * 18 + 200
		h = 800
		max_single = d3.max(sumEachCol)
		margin = {top: 20, right: 20, bottom: 20, left: 100}
		x = d3.scale.ordinal()
			.domain(vizdata[0].map( (d) -> return d.x ))
			.rangeRoundBands([0, w - margin.right - margin.left - 300])
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
			.attr("class", "tooltipOverSmallThumb")
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
			.attr('class', 'pane')
			.attr('x', (d, i) -> 
				if sumEachCol.length < 80 
					return x(d.x) + i * 3 
				else 
					return 15 * i + i * 3
			)
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
			.attr('width', (d, i) -> 
				if sumEachCol.length < 80 
					return x.rangeBand()
				else 
					return 15
			)
			.on('mouseover', (d,i) -> 
				tooltip.html( "Taxonomy: " + d.name + "<br/> Total: " + d.y )
				tooltip.style( { "visibility": "visible", top: (d3.event.pageY - 10) + "px", left: (d3.event.pageX + 10) + "px" })
			)
			.on('mouseout', (d,i) -> 
				tooltip.style("visibility", "hidden")
			)

		# add x-axis
		x.domain()
		label = svg.selectAll('text')
			.data( attributes_array )
		.enter().append('text')
			.text( (d,i) -> return d )
			.attr('x', (d,i) -> 
				if sumEachCol.length < 80 
					return x.rangeBand() * i + x.rangeBand() / 2 + i * 3
				else 
					return 15 * i + 7.5 + i * 3
			)
			.attr('y', h + 15)
			.attr('text-anchor', 'middle')
			.attr("font-size", "10px")
			.attr('fill', '#444')

		# add y-axis
		rule = svg.selectAll('g.rule')
			.data(y.ticks(10))
		.enter().append('g')
			.attr('class','rule')
			.attr('transform', (d) -> return "translate(0," + ( h - y(d) ) + ")" )	

		rule.append('line')
			.attr('x2', (d,i) -> 
				if sumEachCol.length < 80 
					return w - margin.left - margin.right - 200
				else 
					return w - 200
			)
			.style("stroke", (d) -> return if d then "#eee" else "#444" )
			.style("stroke-opacity", (d) -> return if d then 0.7 else null )

		rule.append('text')
			.attr('x', - 25 )
			.attr("font-size", "9px")
			.attr('text-anchor', 'end')
			.attr('fill', '#444')
			.text( (d,i) -> 
				if !percentage
					return format(d) 
				else 
					return Math.round( i / (y.ticks(10).length-1) * 100 ) + '%'
			)

	#####################################################################################################################         
	############################################### Bubble by OTU #######################################################  
	#####################################################################################################################  

	drawOTUBubble: () -> 
		@fadeInOutCtrl()
		
		# 0 Prepare the data 
		data = new Object() 
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

		console.log data; 
		node = data;
		root = data;
		nodes = pack.nodes(root);
		that = this
		vis.selectAll("circle").data(nodes)
			.enter().append("svg:circle")
			.attr("class", (d) -> if d.children != null then return 'parent' else return 'child' )		
			.attr("cx", (d) -> return d.x)
			.attr("cy", (d) -> return d.y)
			.attr("r", (d) -> return d.r)
			# .on "click", (d) -> if node == d then return that.zoomBubble(vis, root) else return that.zoomBubble(vis, d)
		vis.selectAll("text").data(nodes)
			.enter().append("svg:text")
			.attr("class", (d) -> if d.children != null then return 'parent' else return 'child' )
			.attr("x", (d) -> return d.x )
			.attr("y", (d) -> d.y += d.r * (Math.random() - 0.5); return d.y )  ## return d.y ## but d.y could be the same in most cases, so give it a random y position
			.attr("font-size", (d) -> return fontScale( d.r / r) + "px")
			.attr("text-anchor", "middle")
			.style("opacity", (d) -> if d.r > 50 then return 0.8 else return 0 )
			.text((d) -> return d.name )

		d3.select(window).on("click", () -> that.zoomBubble(vis, root) )

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

	numberSort: (a,b) -> return a - b

	fadeInOutCtrl: () -> 

		$("#taxonomy_container").html("")
		$('#taxonomy_container').fadeIn(500)
		$('.dg').fadeIn(500)
		if VizID == 0
			$('#outline').fadeIn(500)
			$('#tags').fadeIn(500)
		if VizID == 2
			$('#layer_6').hide() 
			$('#layer_7').hide()
		$('#layer_' + LayerID).removeClass("loading_notes")
		$('#LayerFolder ul li .layer_change').removeClass('current_layer');
		$('#layer_' + LayerID).addClass('current_layer')

window.taxonomyViz = taxonomyViz

