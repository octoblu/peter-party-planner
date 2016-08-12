{afterEach, beforeEach, describe, it} = global
{expect}      = require 'chai'
enableDestroy = require 'server-destroy'
shmock        = require 'shmock'

Destroyer = require '../src/Destroyer'

describe 'Destroyer', ->
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
        auth = new Buffer('user-uuid:user-token').toString 'base64'

        @unregisterParty = @meshblu
          .delete '/devices/peter-party-uuid'
          .set 'Authorization', "Basic #{auth}"
          .reply 204

        @sut = new Destroyer {@meshbluConfig, manifest: {peterPartyUUID: 'peter-party-uuid'}}
        @sut.destroy done

      it 'should unregister the party', ->
        expect(@unregisterParty.isDone).to.be.true

    describe 'with a party device and a peter', ->
      beforeEach (done) ->
        auth = new Buffer('user-uuid:user-token').toString 'base64'

        @unregisterParty = @meshblu
          .delete '/devices/peter-party-uuid'
          .set 'Authorization', "Basic #{auth}"
          .reply 204

        @unregisterPeter = @meshblu
          .delete '/devices/peter-1-uuid'
          .set 'Authorization', "Basic #{auth}"
          .reply 204

        @sut = new Destroyer {@meshbluConfig, manifest: {
          peterPartyUUID: 'peter-party-uuid'
          peterUUIDs: ['peter-1-uuid']
          }}
        @sut.destroy done

      it 'should unregister the party', ->
        expect(@unregisterParty.isDone).to.be.true

      it 'should unregister the peter', ->
        expect(@unregisterPeter.isDone).to.be.true
