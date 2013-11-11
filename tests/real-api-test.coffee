{assert}         = require 'chai'

{FULL_GIST_API}  = require './full-gist-api'

{Api}            = require '../src/'

# TODO/FIXME/ETC
# Should be stubbed of course
# ...when we are not coding for our lives
# ...and when single-digit AM time blesses us with variety of superpowers (mostly destructive ones)


describe 'Gist Unauthenticated Real API', ->
  A = undefined

  before (done) ->
    A = new Api promiseBlueprint: true
    A.constructFromBlueprint(FULL_GIST_API).then(-> done(null)).fail done

  describe 'When I retrieve all public gists', ->
    gists = undefined

    before (done) ->
      A.gists().get().then(
        ({body}) ->
          gists = body
          done null
      ).fail done

    it 'I get more then one of them', ->
      assert.ok gists.length > 0

    it 'First gist has an URL', ->
      assert.ok gists[0].url.length > 10

    it 'First gist has an ID', ->
      assert.ok gists[0].url.length > 10

    describe 'and when I retrieve first gist', ->
      fullGist = undefined

      before (done) ->
        A.gists().gist(id: gists[0].id).get().then(
          ({body}) ->
            fullGist = body
            done null
        ).fail done

      it 'I can see full text', ->
        assert.ok fullGist.description.length > 0

      it 'It has same URL', ->
        assert.equal fullGist.url, gists[0].url


