var express = require('express');
var bodyParser = require('body-parser')

var exportImageHandler = require('./exportImageHandler.js')
var shareHandler = require('./shareHandler.js')

var allowCrossDomain = function(req, res, next) {
	//we may need to restrict this to just our own domain
    res.header('Access-Control-Allow-Origin', '*');
    res.header('Access-Control-Allow-Methods', 'GET,PUT,POST,DELETE,OPTIONS');
    res.header('Access-Control-Allow-Headers', 'Content-Type, Authorization, Content-Length, X-Requested-With');

    // intercept OPTIONS method
    if ('OPTIONS' == req.method) {
      res.send(200);
    }
    else {
      next();
    }
};

var app = express();

app.use(allowCrossDomain)
app.use(bodyParser.urlencoded())


app.get('/', function(req, res){
  res.send('this is the Phinch back end server. please see <a href="http://phinch.org/">phinch.org</a> for more information');
});
app.post('/exportImage', exportImageHandler)
app.post('/share', shareHandler)

app.listen(8000);