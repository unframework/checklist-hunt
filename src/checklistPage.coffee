h = require 'virtual-dom/h'
thunk = require 'vdom-thunk'

design = require './design.coffee'
pageLayout = require './pageLayout.coffee'

renderCheckbox = (setValue) ->
  h 'input', type: 'checkbox', style: {
    'vertical-align': 'middle'
    'width': '30px'
    'height': '30px'
  }, onclick: ->
    setValue this.checked
    undefined

class ChecklistPage
  constructor: (@title, @itemList) ->
    @data = {}

    @renderItemCheckbox = (itemBody) =>
      renderCheckbox (v) => @data[itemBody] = v

  render: ->
    pageLayout @title, [
      h 'ul', style: {
      }, [
        for itemBody in @itemList
          h 'li', style: {
            background: if @data[itemBody] then '#f8fff8' else ''
          },
            h 'label', [
              thunk(@renderItemCheckbox, itemBody),
              design.typographicCopy 'Open Sans', 300, '18px', 1, itemBody
            ]
      ]
    ]

module.exports = ChecklistPage
