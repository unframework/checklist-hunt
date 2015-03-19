
https = require('https')
url = require('url')
Promise = require('bluebird')

gistApiToken = process.env.GIST_API_TOKEN

module.exports.getGistInfo = (gistId) ->
  new Promise (resolve, reject) ->
    opts = url.parse('https://api.github.com/gists/' + encodeURIComponent(gistId))
    opts.headers =
      'Authorization': 'Bearer ' + gistApiToken
      'User-Agent': 'node.js (Checklist Hunt)'

    https.get(opts, (response) ->
      if response.statusCode != 200
        reject 'github api response code ' + response.statusCode
      else
        data = []

        response.setEncoding 'utf8'
        response.on 'data', (d) -> data.push d

        response.on 'end', ->
          resolve JSON.parse(data.join(''))
    ).on 'error', (e) ->
      reject e

