h = require 'virtual-dom/h'

design = require './design.coffee'
pageLayout = require './pageLayout.coffee'
Assessment = require './Assessment.coffee'

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
  constructor: (@title, @itemList, @onSave) ->
    @_editedData = {}
    @_assessment = null
    @score = null

  render: ->
    pageLayout @title, [
      h 'ul', style: {
      }, [
        for itemBody in @itemList
          h 'li', style: {
            background: if @_editedData[itemBody] then '#f8fff8' else ''
          },
            h 'label', [
              if !@_assessment then do (itemBody) => renderCheckbox (v) => @_editedData[itemBody] = v else null
              design.typographicCopy 'Open Sans', 300, '18px', 1, itemBody
            ]
      ]

      if !@_assessment
        renderButton 'I’m Done!', =>
          @_assessment = new Assessment @itemList, (item for item in @itemList when @_editedData[item])

          @onSave (index for item, index in @itemList when @_editedData[item])
      else
        h 'div', design.typographicCopy 'Open Sans', 300, '18px', 1, 'Your score is: ' + @_assessment.percent
    ]

module.exports = ChecklistPage
