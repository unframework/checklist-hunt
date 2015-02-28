
h = require 'hyperscript'
marked = require 'marked'

$.get('sample.md').then (mdData) ->
  contentMatch = /^\s*<h1[^>]*>(.*?)<\/h1>\s*<ul>([\s\S]*)<\/ul>\s*$/.exec marked(mdData)

  if !contentMatch
    console.log JSON.stringify(marked mdData)
    throw new Error 'cannot parse list data'

  listItemMatches = ('</li>' + contentMatch[2] + '<li>').split /\s*<\/li>\s*<li>\s*/g
  if listItemMatches.length < 3
    throw new Error 'cannot parse list items'

  # @todo better cleaning
  titleBody = contentMatch[1].replace(/</g, /&lt;/)
  listItemBodies = (item.replace(/</g, /&lt;/) for item in listItemMatches.slice(1, -1))

  document.body.appendChild(page(titleBody, listItemBodies))

typographicCopy = (font, weight, size, lineHeight, contents) ->
  h 'span', style: {
    'font-family': font
    'font-size': size
    'font-weight': weight
  }, [ contents ]

mainCopy = (contents) ->
  typographicCopy 'Open Sans', 300, '16px', 1, contents

page = (title, itemList) ->
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
  }, h 'ul', style: {
  }, [ h('li', mainCopy itemBody) for itemBody in itemList ]

  h 'div', style: {
    'min-height': '100%'
  }, [
    header
    main
  ]