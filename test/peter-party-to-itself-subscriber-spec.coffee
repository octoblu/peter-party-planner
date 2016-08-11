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
        @createSubscription = @meshblu
          .post '/v2/devices/peter-party-uuid/subscriptions/peter-party-uuid/configure.received'
          .reply 201, {}

        @sut = new PeterPartyToItselfSubscriber
          peterPartyUUID: 'peter-party-uuid'
          meshbluConfig:
            protocol: 'http'
            hostname: 'localhost'
            port: @meshblu.address().port
        @sut.subscribe done

      it 'should create a peter', ->
        expect(@createSubscription.isDone).to.be.true
