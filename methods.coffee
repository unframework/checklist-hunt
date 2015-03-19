
https = require('https')
url = require('url')
Promise = require('bluebird')

gistApiToken = process.env.GIST_API_TOKEN

parseGistData = (gistUser, gistData) ->
  gistFileMap = gistData.files

  if !gistFileMap
    throw new Error 'cannot get gist file list'

  if gistData.owner.login isnt gistUser
    throw new Error 'gist owner mismatch'

  gistFileNameList = Object.keys gistFileMap # @todo ES5

  if gistFileNameList.length isnt 1 or !gistFileNameList[0].match /\.md|\.markdown$/i
    throw new Error 'expecting a single markdown file in the gist'

  rawUrl = gistFileMap[gistFileNameList[0]].raw_url
  rawUrlParts = rawUrl.split('/').slice(-3)

  if rawUrlParts[0] isnt 'raw'
    throw new Error 'cannot parse raw URL'

  [ objectId, fileName ] = [ rawUrlParts[1], rawUrlParts[2] ]

  objectId


module.exports.getGistInfo = (gistUser, gistId) ->
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
          resolve parseGistData(gistUser, JSON.parse(data.join('')))
    ).on 'error', (e) ->
      reject e

