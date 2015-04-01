h = require 'virtual-dom/h'

design = require './design.coffee'
pageLayout = require './pageLayout.coffee'

class ChecklistPage
  constructor: (@title, @itemList) ->

  render: ->
    pageLayout @title, h 'ul', style: {
    }, [ for itemBody in @itemList
      h 'li',
        h 'label', [
          h('input', type: 'checkbox', style: {
            'vertical-align': 'middle'
            'width': '30px'
            'height': '30px'
          }),
          design.typographicCopy 'Open Sans', 300, '18px', 1, itemBody
        ]
    ]

module.exports = ChecklistPage
