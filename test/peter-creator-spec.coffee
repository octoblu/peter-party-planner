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
      beforeEach ->
        @register = @meshblu
          .post '/devices'
          .send({
            owner: 'owner-uuid'
            type: 'octoblu:smartspaces:user'
            userGroup: 'peter-party-uuid'
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
              selected:
                configure: 'Default'
              configure:
                Default:
                  type: 'object'
                  properties:
                    options:
                      type: 'object'
                      properties:
                        roomId:
                          type: 'string'
                        actions:
                          type: 'array'
                          items:
                            type: 'string'
          })
          .reply 201, {uuid: 'peter-uuid'}

      beforeEach ->
        @updatePeterParty = @meshblu
          .put('/v2/devices/peter-party-uuid')
          .send(
             $addToSet:
               'meshblu.whitelists.discover.as': {uuid:'peter-uuid'}
          )
          .reply 204

      beforeEach (done) ->
        @sut = new PeterCreator
          ownerUUID: 'owner-uuid'
          peterPartyUUID: 'peter-party-uuid'
          meshbluConfig:
            protocol: 'http'
            hostname: 'localhost'
            port: @meshblu.address().port

        @sut.create name: "peter-1", done

      it 'should create a peter', ->
        expect(@register.isDone).to.be.true

      it 'should allow a peter to discover.as the peter-party', ->
        expect(@updatePeterParty.isDone).to.be.true
