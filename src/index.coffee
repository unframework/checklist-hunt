
h = require 'hyperscript'
marked = require 'marked'

gistUrl = 'https://gist.github.com/unframework/9e0aed502fa251de12b1'
[ gistUserEncoded, gistIdEncoded ] = gistUrl.split('/').slice(-2)

$.get('https://api.github.com/gists/' + gistIdEncoded).then (gistData) ->
  gistFileMap = gistData.files

  if !gistFileMap
    throw new Error 'cannot get gist file list'

  if encodeURIComponent(gistData.owner.login) isnt gistUserEncoded
    throw new Error 'gist owner mismatch'

  gistFileNameList = Object.keys gistFileMap # @todo ES5

  if gistFileNameList.length isnt 1 or !gistFileNameList[0].match /\.md|\.markdown$/i
    throw new Error 'expecting a single markdown file in the gist'

  mdData = gistFileMap[gistFileNameList[0]].content

  contentMatch = /^\s*<h1[^>]*>(.*?)<\/h1>\s*<ul>([\s\S]*)<\/ul>\s*$/.exec marked(mdData)

  if !contentMatch
    console.log JSON.stringify(marked mdData)
    throw new Error 'cannot parse list data'

  listItemMatches = ('</li>' + contentMatch[2] + '<li>').split /\s*<\/li>\s*<li>\s*/g
  if listItemMatches.length < 3
    throw new Error 'cannot parse list items'

  # @todo better cleaning
  titleBody = contentMatch[1].replace(/</g, '&lt;')
  listItemBodies = (item.replace(/</g, '&lt;') for item in listItemMatches.slice(1, -1))

  document.body.appendChild(page(titleBody, listItemBodies))

typographicCopy = (font, weight, size, lineHeight, contents) ->
  h 'span', style: {
    'font-family': font
    'font-size': size
    'font-weight': weight
  }, [ contents ]

mainCopy = (contents) ->
  typographicCopy 'Open Sans', 300, '16px', 1, contents

pageLayout = (title, body) ->
  mainColumnWidth = '720px'

  header = h 'header', style: {
    'padding': '20px 0'
    'border-bottom': '1px solid #eee'
  }, h 'div', style: {
    'width': mainColumnWidth
    'margin': 'auto'
  }, typographicCopy 'Open Sans', 700, '24px', 1,
    title

  main = h 'div', style: {
    'padding': '20px 0'
  }, h 'div', style: {
    'width': mainColumnWidth
    'margin': 'auto'
  }, body

  h 'div', style: {
    'min-height': '100%'
  }, [
    header
    main
  ]

page = (title, itemList) ->
  pageLayout title, h 'ul', style: {
  }, [ for itemBody in itemList
    h 'li',
      h 'label',
        h('input', type: 'checkbox', style: {
          'vertical-align': 'middle'
          'width': '30px'
          'height': '30px'
        }),
        typographicCopy 'Open Sans', 300, '18px', 1, itemBody
  ]
