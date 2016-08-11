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
        @createSubscription = @meshblu
          .post '/v2/devices/peter-party-uuid/subscriptions/peter-uuid/configure.sent'
          .reply 201, {}

        @sut = new PeterPartyToPeterSubscriber
          peterPartyUUID: 'peter-party-uuid'
          meshbluConfig:
            protocol: 'http'
            hostname: 'localhost'
            port: @meshblu.address().port
        @sut.subscribe 'peter-uuid', done

      it 'should create a peter', ->
        expect(@createSubscription.isDone).to.be.true
