var spawn = require('child_process').spawn
module.exports = function(req, res) {
	var response = 'hi from express!'
	var svg = req.param('svg')
	response += 'here is the data you sent me'
	response += svg
	res.send(response)

}