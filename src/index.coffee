
# sample URL: http://localhost:3000/#/g/unframework/ngrtUC-iUd4SsQ/go_MhYMTVfbBQoe7IK3dykrKRk8

marked = require 'marked'
base64 = require 'base64-js'
createRootNav = require 'jquery-atomic-nav'
createElement = require 'virtual-dom/create-element'

gistApi = require './gistApi.coffee'
welcomePage = require './welcomePage.coffee'
page = require './checklistPage.coffee'

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

currentBase = (window.location + '').replace /#.*$/, ''

# normalize missing window hash
if !window.location.hash
  window.location = '#/'

rootNav = createRootNav()

rootNav.when '/', (welcomeNav) ->
  pageNode = welcomePage(currentBase, hex2puny)

  document.body.appendChild(createElement pageNode)
  welcomeNav.whenDestroyed.then ->
    document.body.removeChild(createElement pageNode)

rootNav.when '/g/:gistUser/:gistId/:gistCommit', (gistUser, gistIdPuny, gistCommitPuny, checklistNav) ->
  [ gistId, gistCommit ] = [ puny2hex(gistIdPuny), puny2hex(gistCommitPuny) ]

  gistApi.loadGistChecklistMarkdown(gistUser, gistId, gistCommit).then (mdData) ->
    contentMatch = /^\s*<h1[^>]*>(.*?)<\/h1>\s*<ul>([\s\S]*)<\/ul>\s*$/.exec marked(mdData)

    if !contentMatch
      throw new Error 'cannot parse list data'

    listItemMatches = ('</li>' + contentMatch[2] + '<li>').split /\s*<\/li>\s*<li>\s*/g
    if listItemMatches.length < 3
      throw new Error 'cannot parse list items'

    # @todo better cleaning
    titleBody = contentMatch[1].replace(/</g, '&lt;')
    listItemBodies = (item.replace(/</g, '&lt;') for item in listItemMatches.slice(1, -1))

    pageNode = page(titleBody, listItemBodies)

    document.body.appendChild(createElement pageNode)
    checklistNav.whenDestroyed.then ->
      document.body.removeChild(createElement pageNode)
