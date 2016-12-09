{afterEach, beforeEach, describe, it} = global
{expect}      = require 'chai'
enableDestroy = require 'server-destroy'
shmock        = require 'shmock'

PeterPartyCreator = require '../src/peter-party-creator'

describe 'PeterPartyCreator', ->
  beforeEach ->
    @meshblu = shmock()
    enableDestroy @meshblu

  afterEach (done) ->
    @meshblu.destroy done

  describe '->create', ->
    describe 'with an ownerUUID of owner-uuid', ->
      beforeEach (done) ->
        @register = @meshblu
          .post '/devices'
          .send({
            owner: 'owner-uuid'
            type: 'octoblu:smartspaces:user-group'
            logo: 'https://s3-us-west-2.amazonaws.com/octoblu-cdn/fleet/peters.svg'
            online: true
            meshblu:
              version: '2.0.0'
              forwarders:
                configure:
                  received: [{
                    type: 'meshblu'
                    emitType: 'configure.sent'
                  }]
              whitelists:
                configure:
                  update: [{uuid: 'owner-uuid'}]
                discover:
                  view: [{uuid: 'owner-uuid'}]
          })
          .reply 201, {uuid: 'peter-party-uuid'}

        @sut = new PeterPartyCreator
          ownerUUID: 'owner-uuid'
          meshbluConfig:
            protocol: 'http'
            hostname: 'localhost'
            port: @meshblu.address().port
        @sut.create (error, @peterParty) => done error

      it 'should create a peter', ->
        expect(@register.isDone).to.be.true

      it 'should return the peter party uuid', ->
        expect(@peterParty.uuid).to.deep.equal 'peter-party-uuid'
