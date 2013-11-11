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
          A = new Api ast: minimumAst, mock: true

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
          A = new Api ast: ast, mock: true

        it 'Collection resource is automatically recognized as attribute', ->
          assert.ok A.gists

        it 'GET is automatically recognized', ->
          assert.ok A.gists().get

        describe 'and when I retrieve it', ->
          gists    = undefined
          res      = undefined

          before (done) ->
            A.gists().get().then(
              ({response, body}) ->
                res      = response
                gists    = body
                done null
            ).fail (err) ->
              done err

          it 'I receive the expected response', ->
            assert.equal body, gists

  describe 'Using Markdown', ->
    describe 'Minimum API', ->
      describe 'When I pass in API using Markdown format', ->
        A            = undefined
        apiName      = 'API without resources'
        apiBlueprint = """FORMAT: 1A

        # #{apiName}
        """

        before (done) ->
          # FIXME: We are probably going to refactor Api to be self-sustained promise later,
          # so this one will be possible & the main API
#          new Api(blueprint: apiBlueprint, mock: true).then((api) ->
#            A = api
#            done null
#          ).fail((err) -> done err)

          A = new Api mock: true, promiseBlueprint: true
          A.constructFromBlueprint(apiBlueprint).then(-> done(null)).fail done


        it 'API gets named automatically', ->
          assert.equal apiName, A.name
