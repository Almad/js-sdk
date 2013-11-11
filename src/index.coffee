Q = require 'q'

{clone} = require './utils'

class Api
  constructor: (options) ->
    if options.ast
      @constructFromAst options.ast
    else if options.promiseBlueprint
      # hack-space for promise-API-refactor hackaton
    else
      throw new Error 'API must be inialized with AST as a source'

    @mock = !!options.mock

    if not @mock and not @apiUrl
      throw new Error 'When API is not in mock mode, API URL must be set.'


  constructFromAst: (ast) ->
    ext = new AstExtractor ast, @

    @name = ext.getApiName()

    collections = ext.getAvailableCollections()

    for collection in collections
      @[collection.getAttributeName()] = collection

  constructFromBlueprint: (blueprint) ->
    defer = Q.defer()

    protagonist = require 'protagonist'

    protagonist.parse blueprint, requireBlueprintName: true, (err, result) =>
      if err then return defer.reject err

      @constructFromAst result.ast
      defer.fulfill @

    return defer.promise



# # Endpoint
# Endpoint is an API callable. It has URI attached and is considered REST resource
# An endpoint can be either Collection or Resource
# Collections should be named in plural
# Resources' last path segment should be URI-templated
class Endpoint
  constructor: (options) ->
    @api = options.api
    if options.astResource
      @fromAstResource options.astResource

  fromAstResource: (astResource) ->
    @name        = astResource.name
    @uriTemplate = astResource.uriTemplate

    for action in astResource.actions
      @[action.method.toLowerCase()] = getAction endpoint: @, action: action

  isCollection: ->
    # dummy dummy iterate ,)
    @uriTemplate.split('/').length is 2


  # Return a name for attribute I am stored under on a parent API/endpoint
  getAttributeName: ->
    @name.toLowerCase()

getAction = ({endpoint, action}) ->
  method = action.method

  return (options) ->
    response = Q.defer()

    if endpoint.api.mock
      process.nextTick ->
        res  = clone action.examples?[0].responses?[0]
        body = res.body

        response.resolve response: res, body: body
    else
      process.nextTick ->
        response.reject new Error 'Live API not implemented yet'

    return response.promise

class AstExtractor
  constructor: (@ast, @api) ->

  getApiName: ->
    return @ast.name

  getAvailableEndpoints: (options={}) ->
    endpoints = []
    {requiredPrefix} = options

    for g in @ast.resourceGroups
      for r in g.resources
        if not requiredPrefix
          endpoints.push new Endpoint astResource: r, api: @api
        else
          if requiredPrefix is r.uriTemplate.slice 0, requiredPrefix.length
            endpoints.push new Endpoint astResource: r, api: @api

    return endpoints

  getAvailableCollections: (options) ->
    endpoints = @getAvailableEndpoints()
    return (e for e in endpoints when e.isCollection())


module.exports = {
  Api
}
