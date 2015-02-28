
$ = require 'jquery'

gistApiToken = 'INSERT_TOKEN' # @todo remove
gistApiHeaders = { Authorization: 'Bearer ' + gistApiToken }

module.exports.loadGistLatestCommit = (gistUser, gistId) ->
  $.ajax(url: 'https://api.github.com/gists/' + encodeURIComponent(gistId), headers: gistApiHeaders).then (gistData) ->
    history = gistData.history or throw new Error 'cannot get gist history'

    if gistData.owner.login isnt gistUser
      throw new Error 'gist owner mismatch'

    history[0].version

module.exports.loadGistChecklistMarkdown = (gistUser, gistId, gistCommit) ->
  $.ajax(url: 'https://api.github.com/gists/' + encodeURIComponent(gistId) + '/' + encodeURIComponent(gistCommit), headers: gistApiHeaders).then (gistData) ->
    gistFileMap = gistData.files

    if !gistFileMap
      throw new Error 'cannot get gist file list'

    if gistData.owner.login isnt gistUser
      throw new Error 'gist owner mismatch'

    gistFileNameList = Object.keys gistFileMap # @todo ES5

    if gistFileNameList.length isnt 1 or !gistFileNameList[0].match /\.md|\.markdown$/i
      throw new Error 'expecting a single markdown file in the gist'

    if gistFileMap[gistFileNameList[0]].isTruncated
      throw new Error 'checklist markdown is too long'

    gistFileMap[gistFileNameList[0]].content

