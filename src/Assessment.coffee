class Assessment
  constructor: (@_itemList, @_selectedItemList) ->
    @_isOn = {}

    for item in @_selectedItemList
      if @_itemList.indexOf(item) is -1
        throw new Error 'unknown selected item ' + item

      @_isOn[item] = true

    @_ratio = @_selectedItemList.length / @_itemList.length
    @percent = Math.round(@_ratio * 100) + '%'

  getItemIsOn: (item) ->
    @_isOn[item]

module.exports = Assessment
