{afterEach, beforeEach, describe, it} = global
{expect}      = require 'chai'
enableDestroy = require 'server-destroy'
shmock        = require 'shmock'

PeterPartyToPeterSubscriber = require '../src/peter-party-to-peter-subscriber'

describe 'PeterPartyToPeterSubscriber', ->
  beforeEach ->
    @meshblu = shmock()
    enableDestroy @meshblu

  afterEach (done) ->
    @meshblu.destroy done

  describe '->create', ->
    describe 'with an peterPartyUUID of peter-party-uuid and a peterUUID of peter-uuid', ->
      beforeEach (done) ->
        @createBroadcastSentSubscription = @meshblu
          .post '/v2/devices/peter-party-uuid/subscriptions/peter-uuid/broadcast.sent'
          .reply 201, {}

        @createConfigureSentSubscription = @meshblu
          .post '/v2/devices/peter-party-uuid/subscriptions/peter-uuid/configure.sent'
          .reply 201, {}

        @sut = new PeterPartyToPeterSubscriber
          peterPartyUUID: 'peter-party-uuid'
          meshbluConfig:
            protocol: 'http'
            hostname: 'localhost'
            port: @meshblu.address().port
        @sut.subscribe 'peter-uuid', done

      it 'should create a broadcast.sent subscription to the peter', ->
        expect(@createBroadcastSentSubscription.isDone).to.be.true

      it 'should create a configure.sent subscription to the peter', ->
        expect(@createConfigureSentSubscription.isDone).to.be.true
