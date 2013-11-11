

class Api
  constructor: (options) ->
    if options.ast
      @constructFromAst options.ast


  constructFromAst: (ast) ->
    @name = ast.name

module.exports = {
  Api
}
