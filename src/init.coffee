class init 

	vizNames = ['Taxonomy Bar Chart', 'Bubble Chart', 'Sankey Diagram', 'Donut Partition', 'Attributes Column Chart']

	constructor: (page) ->
		console.log page
		if (@mobilecheck()) # if it's on mobile
			$('body').css({'min-width': window.screen.width});
			$('#NotSupported').css({'width': window.screen.width, 'display': 'block', 'margin': '-20px 0 0 0'});
			$('#NotSupported p').html('Desktop Chrome Recommended!');
			$('h1, h3, #bottom_sec, #menu, #help, .orange_btn, hr, #viz_container, #Page1, #readFile, #recent, .footer_copyright span').hide();

			$('.footer_copyright').css({'font-size': '8px', 'line-height': '16px'});
			$('#top_sec').height(50);
			$('#about').css({'width': window.screen.width - 40, 'margin': ' -80px 20px 0px 20px'});
			$('.descPara').height('auto');
			$( "#GraphGallery .col3").width(window.screen.width - 30);
		else if ( !navigator.userAgent.match(/Chrome/i) || !window.File || !window.FileReader || !window.FileList || !window.Blob )
			# || navigator.userAgent.match(/Firefox/i) || navigator.userAgent.match(/Safari/) )
			$('#NotSupported').show();
			$('#top_sec').animate({height:50}, 200);
			$('#head_sec').animate({height:50}, 200);
			$('#viz_container, #bottom_sec, h3, hr, .orange_btn, #Page1, #readFile, #recent').hide();
			alert('Chrome Browser Recommended! Your browser does not support the Phinch framework!');
		else
			@helpMenu()
			switch page
				when 'home' then new readFile()
				when 'preview' then new filter();
				when 'viz' then @viz()

	mobilecheck: () ->
		check = false;
		((a) -> if(/(android|bb\d+|meego).+mobile|avantgo|bada\/|blackberry|blazer|compal|elaine|fennec|hiptop|iemobile|ip(hone|od)|iris|kindle|lge |maemo|midp|mmp|mobile.+firefox|netfront|opera m(ob|in)i|palm( os)?|phone|p(ixi|re)\/|plucker|pocket|psp|series(4|6)0|symbian|treo|up\.(browser|link)|vodafone|wap|windows (ce|phone)|xda|xiino/i.test(a)||/1207|6310|6590|3gso|4thp|50[1-6]i|770s|802s|a wa|abac|ac(er|oo|s\-)|ai(ko|rn)|al(av|ca|co)|amoi|an(ex|ny|yw)|aptu|ar(ch|go)|as(te|us)|attw|au(di|\-m|r |s )|avan|be(ck|ll|nq)|bi(lb|rd)|bl(ac|az)|br(e|v)w|bumb|bw\-(n|u)|c55\/|capi|ccwa|cdm\-|cell|chtm|cldc|cmd\-|co(mp|nd)|craw|da(it|ll|ng)|dbte|dc\-s|devi|dica|dmob|do(c|p)o|ds(12|\-d)|el(49|ai)|em(l2|ul)|er(ic|k0)|esl8|ez([4-7]0|os|wa|ze)|fetc|fly(\-|_)|g1 u|g560|gene|gf\-5|g\-mo|go(\.w|od)|gr(ad|un)|haie|hcit|hd\-(m|p|t)|hei\-|hi(pt|ta)|hp( i|ip)|hs\-c|ht(c(\-| |_|a|g|p|s|t)|tp)|hu(aw|tc)|i\-(20|go|ma)|i230|iac( |\-|\/)|ibro|idea|ig01|ikom|im1k|inno|ipaq|iris|ja(t|v)a|jbro|jemu|jigs|kddi|keji|kgt( |\/)|klon|kpt |kwc\-|kyo(c|k)|le(no|xi)|lg( g|\/(k|l|u)|50|54|\-[a-w])|libw|lynx|m1\-w|m3ga|m50\/|ma(te|ui|xo)|mc(01|21|ca)|m\-cr|me(rc|ri)|mi(o8|oa|ts)|mmef|mo(01|02|bi|de|do|t(\-| |o|v)|zz)|mt(50|p1|v )|mwbp|mywa|n10[0-2]|n20[2-3]|n30(0|2)|n50(0|2|5)|n7(0(0|1)|10)|ne((c|m)\-|on|tf|wf|wg|wt)|nok(6|i)|nzph|o2im|op(ti|wv)|oran|owg1|p800|pan(a|d|t)|pdxg|pg(13|\-([1-8]|c))|phil|pire|pl(ay|uc)|pn\-2|po(ck|rt|se)|prox|psio|pt\-g|qa\-a|qc(07|12|21|32|60|\-[2-7]|i\-)|qtek|r380|r600|raks|rim9|ro(ve|zo)|s55\/|sa(ge|ma|mm|ms|ny|va)|sc(01|h\-|oo|p\-)|sdk\/|se(c(\-|0|1)|47|mc|nd|ri)|sgh\-|shar|sie(\-|m)|sk\-0|sl(45|id)|sm(al|ar|b3|it|t5)|so(ft|ny)|sp(01|h\-|v\-|v )|sy(01|mb)|t2(18|50)|t6(00|10|18)|ta(gt|lk)|tcl\-|tdg\-|tel(i|m)|tim\-|t\-mo|to(pl|sh)|ts(70|m\-|m3|m5)|tx\-9|up(\.b|g1|si)|utst|v400|v750|veri|vi(rg|te)|vk(40|5[0-3]|\-v)|vm40|voda|vulc|vx(52|53|60|61|70|80|81|83|85|98)|w3c(\-| )|webc|whit|wi(g |nc|nw)|wmlb|wonu|x700|yas\-|your|zeto|zte\-/i.test(a.substr(0,4)))
				check = true) ( navigator.userAgent || navigator.vendor || window.opera);
		return check; 

	viz: () =>

		name = 'shareID';
		regex = new RegExp("[\\?&]" + name + "=([^&#]*)");
		results = regex.exec(location.search);
		results == null ? "" : decodeURIComponent(results[1].replace(/\+/g, " ")); # full results
		
		if results isnt null # if shared from a url

			$('#share_box').show()
			$("#GraphGallery .col3").off('click')
			$('#goBackFilter').attr("disabled", "disabled")

			hostURL = 'http://' + window.location.host + window.location.pathname.substr(0, window.location.pathname.lastIndexOf('/'))
			shareURL = hostURL + "/server/getSharedData.php?shareID=" + results[1];
			$.getJSON shareURL, (shareJSON) =>
				console.log(shareJSON);
				shareFile = hostURL + '/biomFiles/' + shareJSON.biom_filename
				optionJSON = JSON.parse(shareJSON.filter_options_json)

				$('#share_box .info').eq(0).find('span').html(optionJSON.name)
				$('#share_box .info').eq(1).find('span').html(shareJSON.date_uploaded)
				$('#share_box .info').eq(2).find('span').html(shareJSON.countView)
				$('#share_box .info').eq(3).find('span').html(vizNames[parseInt(shareJSON.visualization_id) - 1])
				$('#share_box .info').eq(4).find('span').html(shareJSON.LayerName)

				$.get(shareFile, (data) =>

					w = new Worker('scripts/unzipWorker.js')
					w.addEventListener('message', (e) =>
						@saveIndexedDb(e.data, shareJSON, optionJSON)
					)
					w.postMessage(data)

				).fail () ->
					alert( "This shared link no long exists ..." )

		else # not from a shared url
			$( "#GraphGallery .col3").each (index) ->
				$(this).click () -> 
					if(index == 5)
						alert('Implementing... ');
					else
						$('#loadingIcon').css('opacity','1')
						$('h3').html( $(this).find('p').text() ); # 1 change the big title 
						$('#GraphGallery').fadeOut(300, () -> $('#up_sec').fadeIn(300); ); # 2 fade in and out 
						app = new taxonomyViz(index+1, 2); # 3 generate viz

	saveIndexedDb: (shareBiom, shareJSON, optionJSON) =>
		d = new Date();
		biomToStore = {name: optionJSON.name, size: shareBiom.length, data: shareBiom, date: d.getUTCFullYear() + "-" + (d.getUTCMonth() + 1) + "-" + d.getUTCDate() + "T" + d.getUTCHours() + ":" + d.getUTCMinutes() + ":" + d.getUTCSeconds() + " UTC"}					
		db.open(
			server: "BiomData", version: 1,
			schema:
				"biom": key: keyPath: 'id', autoIncrement: true,
		).done (s) =>
			s.biom.add(biomToStore).done () ->
				console.log 'shared file uploaded!'
				db.open(
					server: "BiomSample", version: 1,
					schema:
						"biomSample": key: keyPath: 'id', autoIncrement: true,
				).done (t) =>
					delete optionJSON.id 
					t.biomSample.add( optionJSON ).done (item) =>
						console.log 'option json uploaded!'
						$('#shareGO').html('GO >>')
						$('#shareGO').click () =>
							# need to update the countView
							$('#share_box').fadeOut(200)
							$('#loadingIcon').css('opacity','1')
							$('h3').html( vizNames[parseInt(shareJSON.visualization_id) - 1]); # 1 change the big title 
							$('#GraphGallery').fadeOut(300, () -> $('#up_sec').fadeIn(300); ); # 2 fade in and out
							app = new taxonomyViz(parseInt(shareJSON.visualization_id), parseInt(shareJSON.layer_id));

	helpMenu: () ->
		$('#help').click (e) ->
			e.preventDefault();
			$('#dialog-modal').show();
			$('#dialog-modal').dialog({ height: 140, modal: true });
			$('.ui-button-text').html('<i class="icon-remove icon-large"></i>');

window.init = init