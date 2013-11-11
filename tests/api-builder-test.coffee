{assert}  = require 'chai'

{Api} = require '../src/'


describe 'Main API class', ->
  describe 'Using AST', ->

    describe 'When I create API using AST', ->

      describe 'Minimum API', ->
        minimumAst =
          name: 'Minimum API'
          resourceGroups: []
        A = undefined

        before ->
          A = new Api ast: minimumAst

        it 'It gets named automatically', ->
          assert.equal 'Minimum API', A.name

      describe 'Single-collection API', ->
        A       = undefined
        body    = JSON.stringify [{"url": "https://api.github.com/gists/xoxotest"}]
        ast     =
          name: 'Gists collection'
          resourceGroups: [
            resources: [
              name: 'Gists'
              uriTemplate: '/gists'
              actions: [
                name: 'List Gists'
                method: 'GET'
                headers: {}
                examples: [
                  requests: []
                  responses: [
                    name: '200'
                    headers: 'content-type': value: 'application/json'
                    body: body
                  ]
                ]
              ]
            ]
          ]


        before ->
          A = new Api ast: ast

        it 'Collection resource is automatically recognized as attribute', ->
          assert.ok A.gists




