h = require 'virtual-dom/h'

module.exports.typographicCopy = (font, weight, size, lineHeight, contents) ->
  h 'span', style: {
    'font-family': font
    'font-size': size
    'font-weight': weight
  }, [ contents ]
