{afterEach, beforeEach, describe, it} = global
{expect}      = require 'chai'
enableDestroy = require 'server-destroy'
shmock        = require 'shmock'

PeterDestroyer = require '../src/peter-destroyer'

describe 'PeterDestroyer', ->
  beforeEach ->
    @meshblu = shmock()
    enableDestroy @meshblu

    @meshbluConfig =
      uuid: 'user-uuid'
      token: 'user-token'
      protocol: 'http'
      hostname: 'localhost'
      port: @meshblu.address().port

  afterEach (done) ->
    @meshblu.destroy done

  describe '->destroy', ->
    describe 'with only a party device', ->
      beforeEach (done) ->
        @sut = new PeterDestroyer {@meshbluConfig, manifest: {}}
        @sut.destroy peterName: 'peter-1', (@error) => done()

      it 'should yield an error', ->
        expect(=> throw @error).to.throw 'peter-1 does not seem to be a member of this party'

    describe 'with a party device and a peter', ->
      beforeEach (done) ->
        auth = new Buffer('user-uuid:user-token').toString 'base64'

        @unregisterPeter = @meshblu
          .delete '/devices/peter-1-uuid'
          .set 'Authorization', "Basic #{auth}"
          .reply 204

        @unsubscribePeter = @meshblu
          .delete '/v2/devices/peter-party-uuid/subscriptions/peter-1-uuid/configure.sent'
          .set 'Authorization', "Basic #{auth}"
          .reply 204

        @sut = new PeterDestroyer {@meshbluConfig, manifest: {
          peterParty:
            uuid: 'peter-party-uuid'
          peters: [{
            name: 'peter-1'
            uuid: 'peter-1-uuid'
          }]
        }}
        @sut.destroy peterName: 'peter-1', (error, @manifest) => done error

      it 'should unregister the peter', ->
        expect(@unregisterPeter.isDone).to.be.true

      it 'should unsubscribe the party from the peter', ->
        expect(@unsubscribePeter.isDone).to.be.true

      it 'should yield a manifest minus the peter', ->
        expect(@manifest).to.deep.equal peterParty: {uuid: 'peter-party-uuid'}, peters: []
