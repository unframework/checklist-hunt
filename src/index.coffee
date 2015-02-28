
# sample URL: http://localhost:3000/#/g/unframework/ngrtUC-iUd4SsQ/go_MhYMTVfbBQoe7IK3dykrKRk8

marked = require 'marked'
base64 = require 'base64-js'

page = require './checklistPage.coffee'

gistApiToken = 'INSERT_TOKEN' # @todo remove
gistApiHeaders = { Authorization: 'Bearer ' + gistApiToken }

hex2puny = (hexText) ->
  punyInput = []

  re = /../g
  while match = re.exec hexText
    punyInput.push parseInt match[0], 16

  unSanitized = base64.fromByteArray punyInput

  unSanitized
    .replace(/\+/g, '-')
    .replace(/\//g, '_')
    .replace(/\=+$/, '')

puny2hex = (punyText) ->
  unSanitized = punyText
    .replace(/-/g, '+')
    .replace(/_/g, '/') + '=='

  unSanitizedLength = unSanitized.length - unSanitized.length % 4

  punyOutput = base64.toByteArray unSanitized.substring 0, unSanitizedLength

  byte2hex = -> if b < 16 then '0' + b.toString(16) else b.toString(16)
  ( byte2hex(b) for b in punyOutput ).join ''

window.loadChecklistUrl = (gistUrl) ->
  [ gistUserEncoded, gistIdEncoded ] = gistUrl.split('/').slice(-2)

  currentBase = (window.location + '').replace /#.*$/, ''

  $.ajax(url: 'https://api.github.com/gists/' + gistIdEncoded, headers: gistApiHeaders).then (gistData) ->
    history = gistData.history or throw new Error 'cannot get gist history'
    gistCommit = history[0].version

    currentBase + [
      '#'
      'g'
      gistUserEncoded
      hex2puny(gistIdEncoded)
      hex2puny(gistCommit)
    ].join '/'

hashMatch = /^#\/g\/(.*?)\/(.*?)\/(.*?)$/.exec window.location.hash

if (!hashMatch)
  throw new Error 'cannot parse checklist URL'

[ gistUser, gistId, gistCommit ] = [ hashMatch[1], puny2hex(hashMatch[2]), puny2hex(hashMatch[3]) ]

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

  mdData = gistFileMap[gistFileNameList[0]].content

  contentMatch = /^\s*<h1[^>]*>(.*?)<\/h1>\s*<ul>([\s\S]*)<\/ul>\s*$/.exec marked(mdData)

  if !contentMatch
    throw new Error 'cannot parse list data'

  listItemMatches = ('</li>' + contentMatch[2] + '<li>').split /\s*<\/li>\s*<li>\s*/g
  if listItemMatches.length < 3
    throw new Error 'cannot parse list items'

  # @todo better cleaning
  titleBody = contentMatch[1].replace(/</g, '&lt;')
  listItemBodies = (item.replace(/</g, '&lt;') for item in listItemMatches.slice(1, -1))

  document.body.appendChild(page(titleBody, listItemBodies))

