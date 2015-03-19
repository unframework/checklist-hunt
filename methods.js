
var https = require('https');
var url = require('url');
var Promise = require('bluebird');

var gistApiToken = process.env.GIST_API_TOKEN;

module.exports.getGistInfo = function (gistId) {
    return new Promise(function (resolve, reject) {
        var opts = url.parse('https://api.github.com/gists/' + encodeURIComponent(gistId));
        opts.headers = {
            'Authorization': 'Bearer ' + gistApiToken,
            'User-Agent': 'node.js (Checklist Hunt)'
        };

        https.get(opts, function (response) {
            var data = [];

            if (response.statusCode !== 200) {
                reject('github api response code ' + response.statusCode);
                return;
            }

            response.setEncoding('utf8');
            response.on('data', function (d) { data.push(d); });

            response.on('end', function () {
                resolve(JSON.parse(data.join('')));
            });
        }).on('error', function (e) {
            reject(e);
        });
    });
};
