Q = require 'q'

class Api
  constructor: (options) ->
    if options.ast
      @constructFromAst options.ast
    else
      throw new Error 'API must be inialized with AST as a source'

    @mock = !!options.mock

    if not @mock and not @apiUrl
      throw new Error 'When API is not in mock mode, API URL must be set.'




  constructFromAst: (ast) ->
    ext = new AstExtractor ast

    @name = ext.getApiName()

    collections = ext.getAvailableCollections()

    for collection in collections
      @[collection.getAttributeName()] = collection



# # Endpoint
# Endpoint is an API callable. It has URI attached and is considered REST resource
# An endpoint can be either Collection or Resource
# Collections should be named in plural
# Resources' last path segment should be URI-templated
class Endpoint
  constructor: (options) ->
    if options.astResource
      @fromAstResource options.astResource

  fromAstResource: (astResource) ->
    @name        = astResource.name
    @uriTemplate = astResource.uriTemplate

    for action in astResource.actions
      @[action.method.toLowerCase()] = new Action endpoint: @

  isCollection: ->
    # dummy dummy iterate ,)
    @uriTemplate.split('/').length is 2


  # Return a name for attribute I am stored under on a parent API/endpoint
  getAttributeName: ->
    @name.toLowerCase()


# # Action
# Corresponds to HTTP method. Can be called on Endpoint.
class Action
  @constructor: ({@endpoint})


class AstExtractor
  constructor: (@ast) ->

  getApiName: ->
    return @ast.name

  getAvailableEndpoints: (options={}) ->
    endpoints = []
    {requiredPrefix} = options

    for g in @ast.resourceGroups
      for r in g.resources
        if not requiredPrefix
          endpoints.push new Endpoint astResource: r
        else
          if requiredPrefix is r.uriTemplate.slice 0, requiredPrefix.length
            endpoints.push new Endpoint astResource: r

    return endpoints

  getAvailableCollections: (options) ->
    endpoints = @getAvailableEndpoints()
    return (e for e in endpoints when e.isCollection())


module.exports = {
  Api
}
