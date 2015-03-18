var fs = require('fs');
var express = require('express');
var browserify = require('browserify');
var coffeeify = require('coffeeify');
var concat = require('concat-stream');

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

app.listen(process.env.PORT || 3000);