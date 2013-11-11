{assert}  = require 'chai'

{Api} = require '../src/'


describe 'Main API class', ->
  describe 'Using AST', ->

    describe 'When I create API using AST', ->
      minimumAst =
        name: 'Minimum API'
        resourceGroups: []
      A = undefined

      before ->
        A = new Api ast: minimumAst


      it 'It gets named automatically', ->
        assert.equal 'Minimum API', A.name



