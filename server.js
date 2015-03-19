
require('coffee-script/register');

var fs = require('fs');
var express = require('express');
var browserify = require('browserify');
var coffeeify = require('coffeeify');
var concat = require('concat-stream');
var WebSocketServer = require("ws").Server;
var Promise = require('bluebird');

var methods = require('./methods.coffee');

var mainHtml = fs.readFileSync(__dirname + '/index.html');
var mainJs = null;

// build the client-side code
(function () {
    var b = browserify({ basedir: __dirname + '/src' });
    b.transform(coffeeify);
    b.add('./index.coffee');
    b.bundle().pipe(concat(function(js) {
        mainJs = js.toString();
    }));
})();

var app = express();

app.get('/', function(request, response) {
    response.setHeader('Content-Type', 'text/html');
    response.send(mainHtml);
});

app.get('/bundle.js', function(request, response) {
    response.setHeader('Content-Type', 'text/javascript');
    response.send(mainJs);
});

var server = app.listen(process.env.PORT || 3000);

var wsServer = new WebSocketServer({ server: server });

wsServer.on('connection', function (socket) {
    socket.on('message', function (dataJson) {
        var data = null;

        try {
            data = [].concat(JSON.parse(dataJson));
        } catch (e) {
            return;
        }

        var callId = data[0];
        var method = methods[data[1]];
        var args = data.slice(2);
        var result = undefined;

        try {
            result = Promise.resolve(method.apply(null, args));
        } catch (e) {
            result = Promise.reject();
        }

        result.then(function (resultValue) {
            socket.send(JSON.stringify([ callId, resultValue ]));
        }, function (error) {
            console.error(error);
            socket.send(JSON.stringify([ callId, null, true ]));
        });
    });
});
