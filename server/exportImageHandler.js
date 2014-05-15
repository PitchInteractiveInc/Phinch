var btoa = require('btoa')

module.exports = function(req, res) {

	var convert = require('child_process').spawn("convert", ["svg:", "png:-"]);
	var svg = req.param('svg');

	var saveBuffer = new Buffer(0);
	var jsonToSend = {'status':'okay', 'imageData': saveBuffer};

	convert.stdout.on('data', function(data){
		// console.log(data);
		console.log( 'bufferLength' + data.length );
		saveBuffer = Buffer.concat([saveBuffer,data])
	});

	convert.on('exit', function(code) {
		if (code !== 0) {
			console.log('exit with code' + code);
		} else {
			jsonToSend['imageData'] = btoa(saveBuffer);
		}
		res.write( JSON.stringify(jsonToSend));
		res.end();
	});

	convert.stderr.setEncoding('utf8');
	convert.stderr.on('data', function(data){
		console.log('stderr: ' + data)
		jsonToSend['status'] = data; 
	});

	convert.stdin.write(svg);
	convert.stdin.end();

}