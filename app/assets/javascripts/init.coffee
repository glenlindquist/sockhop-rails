window.App ||= {}

App.init = ->
  $("a, span, i, div").tooltip()

$ ->
  App.init()