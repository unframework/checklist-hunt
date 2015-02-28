
h = require 'hyperscript'

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

module.exports = (title, itemList) ->
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
