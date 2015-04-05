
require('coffee-script/register');

var fs = require('fs');
var express = require('express');
var browserify = require('browserify');
var coffeeify = require('coffeeify');
var concat = require('concat-stream');
var Promise = require('bluebird');
var RemoteControl = require('remote-control');

var methods = require('./src/backend.coffee');

var mainHtml = fs.readFileSync(__dirname + '/index.html');

// build the client-side code
var mainJsWhenReady = new Promise(function (resolve) {
    var b = browserify({ basedir: __dirname + '/src' });
    b.transform(coffeeify);
    b.add('./index.coffee');
    b.bundle().pipe(concat(function(js) {
        resolve(js.toString());
    }));
});

var app = express();

app.get('/', function(request, response) {
    response.setHeader('Content-Type', 'text/html');
    response.send(mainHtml);
});

app.get('/bundle.js', function(request, response) {
    mainJsWhenReady.then(function (mainJs) {
        response.setHeader('Content-Type', 'text/javascript');
        response.send(mainJs);
    });
});

var server = app.listen(process.env.PORT || 3000);

var rc = new RemoteControl(methods, server);
app.get('/remote.js', rc.clientMiddleware)
