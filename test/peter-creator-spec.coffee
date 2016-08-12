{afterEach, beforeEach, describe, it} = global
{expect}      = require 'chai'
enableDestroy = require 'server-destroy'
shmock        = require 'shmock'

PeterCreator = require '../src/peter-creator'

describe 'PeterCreator', ->
  beforeEach ->
    @meshblu = shmock()
    enableDestroy @meshblu

  afterEach (done) ->
    @meshblu.destroy done

  describe '->create', ->
    describe 'with an ownerUUID of owner-uuid and peterPartyUUID of peter-party-uuid', ->
      beforeEach (done) ->
        @register = @meshblu
          .post '/devices'
          .send({
            owner: 'owner-uuid'
            type: 'device:peter'
            name: 'peter-1'
            logo: 'https://s3-us-west-2.amazonaws.com/octoblu-cdn/fleet/KijEejxiq.svg'
            online: true
            meshblu:
              version: '2.0.0'
              whitelists:
                configure:
                  update: [{uuid: 'owner-uuid'}]
                  sent: [{uuid: 'peter-party-uuid'}]
                discover:
                  view: [{uuid: 'owner-uuid'}]
            schemas:
              version: '2.0.0'
              configure:
                Default:
                  type: 'object'
                  properties:
                    data:
                      type: 'object'
                      properties:
                        roomId:
                          type: 'string'
          })
          .reply 201, {}

        @sut = new PeterCreator
          ownerUUID: 'owner-uuid'
          peterPartyUUID: 'peter-party-uuid'
          meshbluConfig:
            protocol: 'http'
            hostname: 'localhost'
            port: @meshblu.address().port
        @sut.create 1, done

      it 'should create a peter', ->
        expect(@register.isDone).to.be.true
