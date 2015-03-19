
$ = require 'jquery'
Promise = require 'bluebird'

# this converts https into wss
bridgeSocket = new WebSocket((window.location + '').replace(/^http/, 'ws').replace(/#.*$/, ''))
bridgeSocket.onerror = (e) -> console.log('ws error', e)

bridgeSocket.onmessage = (e) ->
  data = JSON.parse e.data

  call = callMap[data[0]]

  if call
    if data.length is 2
      call(null, data[1])
    else
      call(data[2])

callMap = {}

remoteCall = (methodName, args...) ->
  callId = Math.random() + '' # @todo this
  timeoutId = null

  new Promise (resolve, reject) ->
    cleanup = ->
      window.clearTimeout timeoutId
      delete callMap[callId]

    timeoutId = window.setTimeout ->
      cleanup()
      reject()
    , 5000

    callMap[callId] = (args...) ->
      cleanup()

      if args.length is 2
        resolve(args[1])
      else
        reject(args[0])

    bridgeSocket.send JSON.stringify([ callId, methodName ].concat args)


createRejection = (e) ->
  error = new $.Deferred
  error.reject e

  error

module.exports.loadGistLatestCommitRawObjectId = (gistUser, gistId) ->
  remoteCall('getGistInfo', gistUser, gistId).then (objectId) ->
    objectId
  , (resp) ->
    throw new Error 'error fetching gist data from GitHub'

module.exports.loadGistChecklistMarkdown = (gistUser, gistId, gistObjectId) ->
  $.get('https://gist.githubusercontent.com/' + encodeURIComponent(gistUser) + '/' + encodeURIComponent(gistId) + '/raw/' + encodeURIComponent(gistObjectId)).then (gistData) ->
    gistData
  , (resp) ->
    new Error 'error fetching gist data from GitHub'

