
$ = require 'jquery'
Promise = require 'bluebird'

module.exports.loadGistLatestCommitRawObjectId = (gistUser, gistId) ->
  server.getGistInfo(gistUser, gistId).then (objectId) ->
    objectId
  , (resp) ->
    throw new Error 'error fetching gist data from GitHub'

module.exports.loadGistChecklistMarkdown = (gistUser, gistId, gistObjectId) ->
  $.get('https://gist.githubusercontent.com/' + encodeURIComponent(gistUser) + '/' + encodeURIComponent(gistId) + '/raw/' + encodeURIComponent(gistObjectId)).then (gistData) ->
    gistData
  , (resp) ->
    new Error 'error fetching gist data from GitHub'

