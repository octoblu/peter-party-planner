{afterEach, beforeEach, describe, it} = global
{expect}      = require 'chai'
enableDestroy = require 'server-destroy'
shmock        = require 'shmock'

PeterPartyToItselfSubscriber = require '../src/peter-party-to-itself-subscriber'

describe 'PeterPartyToItselfSubscriber', ->
  beforeEach ->
    @meshblu = shmock()
    enableDestroy @meshblu

  afterEach (done) ->
    @meshblu.destroy done

  describe '->create', ->
    describe 'with an peterPartyUUID of peter-party-uuid and a peterUUID of peter-uuid', ->
      beforeEach (done) ->
        @createConfigureReceivedSubscription = @meshblu
          .post '/v2/devices/peter-party-uuid/subscriptions/peter-party-uuid/configure.received'
          .reply 201, {}

        @createConfigureSentSubscription = @meshblu
          .post '/v2/devices/peter-party-uuid/subscriptions/peter-party-uuid/configure.sent'
          .reply 201, {}

        @sut = new PeterPartyToItselfSubscriber
          peterPartyUUID: 'peter-party-uuid'
          meshbluConfig:
            protocol: 'http'
            hostname: 'localhost'
            port: @meshblu.address().port
        @sut.subscribe done

      it 'should create a configure.received subscription', ->
        expect(@createConfigureReceivedSubscription.isDone).to.be.true

      it 'should create a configure.sent subscription', ->
        expect(@createConfigureSentSubscription.isDone).to.be.true
