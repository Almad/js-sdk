{assert}  = require 'chai'

{Api} = require '../src/'


describe '# Resource on Collection', ->
  describe '## Simple templated resource', ->
    describe 'When I create API with templated resource', ->
      A = undefined

      before (done) ->
        A = new Api mock: true, promiseBlueprint: true
        A.constructFromBlueprint(SINGLE_RESOURCE_BLUEPRINT).then(-> done(null)).fail done


      it 'I get resource recognized under parent collection', ->
        assert.ok A.gists.gist



SINGLE_RESOURCE_BLUEPRINT = """
# Simple Resource API

# Gists [/gists]

## Lists Gists [GET]

+ Response 200 (application/json)

  + Body

      [{"url": "https://api.github.com/gists/1c34d10b7f3cf2de3be2"}]



# Gist [/gists/{id}]

A single gist object

+ Parameters

  + id (string) ... ID of the gist in the form of a hash

## Get a single gist [GET]

+ Response 200 (application/json)

  + Body

      {
        "url": "https://api.github.com/gists/1c34d10b7f3cf2de3be2"
      }

"""
