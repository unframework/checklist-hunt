
$ = require 'jquery'

requestAnimationFrame = require 'raf'
diff = require 'virtual-dom/diff'
patch = require 'virtual-dom/patch'
createElement = require 'virtual-dom/create-element'

module.exports = (render) ->
  tree = render()
  rootNode = createElement(tree)

  redrawId = null

  requestRedraw = ->
    # debounce redraw requests
    if redrawId is null
      redrawId = requestAnimationFrame ->
        redrawId = null

        newTree = render()

        rootNode = patch(rootNode, diff(tree, newTree))
        tree = newTree

  $(window).on 'hashchange', ->
    requestRedraw()

  $(document.body).on 'click', ->
    requestRedraw()

  return rootNode
