h = require 'hyperscript'
$ = require 'jquery'

gistApi = require './gistApi.coffee'
design = require './design.coffee'
pageLayout = require './pageLayout.coffee'

loadChecklistUrl = (currentBase, hex2puny, gistUrl) ->
  [ gistUserEncoded, gistIdEncoded ] = gistUrl.split('/').slice(-2)

  gistApi.loadGistLatestCommit(decodeURIComponent(gistUserEncoded), decodeURIComponent(gistIdEncoded)).then (gistCommit) ->
    currentBase + [
      '#'
      'g'
      gistUserEncoded
      hex2puny(gistIdEncoded)
      hex2puny(gistCommit)
    ].join '/'

module.exports = (currentBase, hex2puny) ->
  pageLayout 'Welcome to Checklist Hunt', [
    h 'p', design.typographicCopy 'Open Sans', 300, '18px', 1, 'Enter your Gist URL'
    h 'form', {
      action: 'javascript:void(0)' # prevent submit
      onsubmit: ->
        $form = $(this)
        $input = $form.find('input')

        urlResult = loadChecklistUrl currentBase, hex2puny, $input.val()

        $form.attr('disabled', true)
        $input.attr('disabled', true)

        urlResult.always ->
          $form.attr('disabled', false)
          $input.attr('disabled', false)

        urlResult.then (url) ->
          window.location.href = url

        urlResult.fail (e) ->
          $form.find('.error').text(e.message)
    }, [
      h 'div.error', style: { color: '#f00' }
      h 'input', { type: 'text' }
    ]
  ]
