Q           = require 'q'
request     = require 'request'
uritemplate = require 'uritemplate'

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

    if not @mock and not @apiUrl and not options.promiseBlueprint
      throw new Error 'When API is not in mock mode, API URL must be set.'


  constructFromAst: (ast) ->
    ext = new AstExtractor ast, @

    @name   = ext.getApiName()
    @apiUrl ?= ast.metadata?.HOST?.value

    endpoints   = ext.getAvailableEndpoints()
    collections = ext.getAvailableCollections()

    for collection in collections
      @[collection().getAttributeName()] = collection
      collection().resolveResources endpoints

  constructFromBlueprint: (blueprint) ->
    defer = Q.defer()

    protagonist = require 'protagonist'

    protagonist.parse blueprint, requireBlueprintName: true, (err, result) =>
      if err then return defer.reject err

      @apiUrl ?= result.metadata?.HOST?.value

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
    @templateParameters = {}

    if options.astResource
      @fromAstResource options.astResource

    return (params={}) =>
      @setupParams params
      return @

  fromAstResource: (astResource) ->
    @name        = astResource.name
    @uriTemplate = astResource.uriTemplate
    @parsedTemplate = uritemplate.parse  @uriTemplate
    # hackity hack...rewrite ALL teh things (will not work for star or slash modifier, for example)
    @relevantTemplate = ''
    for expr in @parsedTemplate.expressions

      # This is going to explode quickly
      if expr.literal
        if expr.literal.indexOf('?') > -1
          break
        else
          @relevantTemplate += expr.literal
      else if expr.templateText
        if expr.templateText.indexOf('?') > -1
          break
        else
          # This is reducing the template scope in a huuge way
          @relevantTemplate += "{#{expr.templateText}}"
      else
        throw new Error 'Unsupported template, I say!'

    for action in astResource.actions
      @[action.method.toLowerCase()] = getAction endpoint: @, action: action

  isCollection: ->
    # dummy dummy iterate ,)
    # in fact isRootCollection, hm!
    @uriTemplate.split('/').length is 2

  setupParams: (params) ->
    for k, v of params
      @templateParameters[k] = v

  # Return a name for attribute I am stored under on a parent API/endpoint
  getAttributeName: ->
    @name.toLowerCase()

  getUrl: ->
    if not @api.apiUrl then throw new Error "Cannot return URL as no base apiUrl is set"

    path = @parsedTemplate.expand @templateParameters

    return "#{@api.apiUrl}#{path}"

  resolveResources: (endpoints) ->
    for e in endpoints
      endpoint = e()
      if @relevantTemplate isnt endpoint.uriTemplate and @relevantTemplate is endpoint.uriTemplate.slice 0, @relevantTemplate.length
        @[endpoint.name.toLowerCase()] = e

getAction = ({endpoint, action}) ->
  method = action.method

  return (options={}) ->
    {requestBody, requestHeaders} = options

    defer = Q.defer()

    if endpoint.api.mock
      process.nextTick ->
        res  = clone action.examples?[0].responses?[0]
        body = res.body

        defer.resolve response: res, body: body
    else
      request
        method:  method
        url:     endpoint.getUrl()
        body:    requestBody    or clone action.examples?[0].requests?[0]?.body
        headers: requestHeaders or clone action.examples?[0].requests?[0]?.headers
      , (err, res, body) ->
          # Yep, this should be done in another way and this might freeze you.
          try
            body = JSON.parse body
          catch err
            # not a valid JSON and header set and we should check it and if VERBOSE
          if err
            defer.reject err
          else
            defer.resolve response: res, body: body

    return defer.promise

class AstExtractor
  constructor: (@ast, @api) ->

  getApiName: ->
    return @ast.name

  getAvailableEndpoints: (options={}) ->
    endpoints = []

    for g in @ast.resourceGroups
      for r in g.resources
        endpoints.push new Endpoint astResource: r, api: @api

    return endpoints

  getAvailableCollections: (options) ->
    endpoints = @getAvailableEndpoints()
    return (e for e in endpoints when e().isCollection())


module.exports = {
  Api
}
