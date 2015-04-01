h = require 'virtual-dom/h'

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

renderButton = (label, onClick) ->
  h 'button', style: {
    margin: '15px 0'
    padding: '8px 15px 12px'
    background: '#2980b9'
    color: '#fff'
    border: 0
    borderRadius: '5px'
    verticalAlign: 'middle'
  }, type: 'button', onclick: (-> onClick(); undefined),
    design.typographicCopy 'Open Sans', 300, '18px', 1, label

formatPercent = (v) ->
  whole = Math.floor(v * 100)
  frac = Math.round(100 * (v * 100 - whole)) % 100
  whole + '.' + ('0' + frac).slice(-2) + '%'

class ChecklistPage
  constructor: (@title, @itemList) ->
    @data = {}
    @isEditing = true
    @score = null

  render: ->
    pageLayout @title, [
      h 'ul', style: {
      }, [
        for itemBody in @itemList
          h 'li', style: {
            background: if @data[itemBody] then '#f8fff8' else ''
          },
            h 'label', [
              if @isEditing then do (itemBody) => renderCheckbox (v) => @data[itemBody] = v else null
              design.typographicCopy 'Open Sans', 300, '18px', 1, itemBody
            ]
      ]

      if @isEditing
        renderButton 'I’m Done!', =>
          @isEditing = false

          count = 0
          for k, v of @data
            if v then count += 1

          @score = formatPercent(count / @itemList.length)
      else
        h 'div', design.typographicCopy 'Open Sans', 300, '18px', 1, 'Your score is: ' + @score
    ]

module.exports = ChecklistPage
