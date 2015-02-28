h = require 'hyperscript'

design = require './design.coffee'
pageLayout = require './pageLayout.coffee'

module.exports = () ->
  pageLayout 'Welcome to Checklist Hunt',
    h 'p', design.typographicCopy 'Open Sans', 300, '18px', 1, 'Enter your Gist URL'
