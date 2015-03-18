
$ = require 'jquery'

gistApiToken = process.env.GIST_API_TOKEN
gistApiHeaders = { Authorization: 'Bearer ' + gistApiToken }

bridgeSocket = new WebSocket((window.location + '').replace(/^https?/, 'ws').replace(/#.*$/, ''))
bridgeSocket.onerror = (e) -> console.log('ws error', e)

bridgeSocket.onmessage = (e) ->
  data = JSON.parse e.data

  callId = data[0]

  call = callMap[callId]

  if call
    call(data[1])

callMap = {}

remoteCall = (methodName, args...) ->
  callId = Math.random() + '' # @todo this
  timeoutId = null

  cleanup = ->
    window.clearTimeout timeoutId
    delete callMap[callId]

  timeoutId = window.setTimeout cleanup, 5000

  callMap[callId] = (data) ->
    cleanup()

    console.log data

  bridgeSocket.send JSON.stringify([ callId, methodName ].concat args)


createRejection = (e) ->
  error = new $.Deferred
  error.reject e

  error

module.exports.loadGistLatestCommitRawObjectId = (gistUser, gistId) ->
  remoteCall 'hithere!', 'arg1'

  $.ajax(url: 'https://api.github.com/gists/' + encodeURIComponent(gistId), headers: gistApiHeaders).then (gistData) ->
    # workaround for incomplete Deferred error handling
    try
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
    catch e
      createRejection e # workaround for incomplete Deferred error handling
  , (resp) ->
    new Error 'error fetching gist data from GitHub'

module.exports.loadGistChecklistMarkdown = (gistUser, gistId, gistObjectId) ->
  $.get('https://gist.githubusercontent.com/' + encodeURIComponent(gistUser) + '/' + encodeURIComponent(gistId) + '/raw/' + encodeURIComponent(gistObjectId)).then (gistData) ->
    gistData
  , (resp) ->
    new Error 'error fetching gist data from GitHub'

