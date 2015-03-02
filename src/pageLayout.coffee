h = require 'virtual-dom/h'

design = require './design.coffee'

module.exports = (title, body) ->
  mainColumnWidth = '720px'

  header = h 'header', style: {
    'padding': '20px 0'
    'border-bottom': '1px solid #eee'
  }, h 'div', style: {
    'width': mainColumnWidth
    'margin': 'auto'
  }, design.typographicCopy 'Open Sans', 700, '24px', 1,
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
