#
# batman.jquery.coffee
# batman.js
#
# Created by Nick Small
# Copyright 2011, Shopify
#

# Include this file instead of batman.nodep if your
# project already uses jQuery. It will map a few
# batman.js methods to existing jQuery methods.

Batman.Request::_parseResponseHeaders = (xhr) ->
  headers = xhr.getAllResponseHeaders().split('\n').reduce((acc, header) ->
    [key, value] = header.split(':')
    acc[key]
    acc
  , {})

Batman.Request::send = (data) ->
  options =
    url: @get 'url'
    type: @get 'method'
    dataType: @get 'type'
    data: data || @get 'data'
    username: @get 'username'
    password: @get 'password'
    headers: @get 'headers'
    beforeSend: =>
      @fire 'loading'

    success: (response, textStatus, xhr) =>
      @mixin
        xhr: xhr
        status: xhr.status
        response: response
        responseHeaders: @_parseResponseHeaders(xhr)
      @fire 'success', response

    error: (xhr, status, error) =>
      @mixin
        xhr: xhr
        status: xhr.status
        response: xhr.responseText
        responseHeaders: @_parseResponseHeaders(xhr)
      xhr.request = @
      @fire 'error', xhr

    complete: =>
      @fire 'loaded'

  if @get('method') in ['PUT', 'POST']

    unless @hasFileUploads()
      options.contentType = @get 'contentType'
    else
      options.contentType = false
      options.processData = false
      options.data = @constructor.objectToFormData(options.data)

  jQuery.ajax options

Batman.mixins.animation =
  show: (addToParent) ->
    jq = $(@)
    show = ->
      jq.show 600

    if addToParent
      addToParent.append?.appendChild @
      addToParent.before?.parentNode.insertBefore @, addToParent.before

      jq.hide()
      setTimeout show, 0
    else
      show()
    @

  hide: (removeFromParent) ->
    $(@).hide 600, =>
      @parentNode?.removeChild @ if removeFromParent
      Batman.DOM.didRemoveNode(@)
    @
