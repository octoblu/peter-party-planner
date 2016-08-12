MeshbluHTTP = require 'meshblu-http'

class PeterCreator
  constructor: ({@meshbluConfig, @ownerUUID, @peterPartyUUID}={}) ->
    throw new Error 'Missing required parameter: meshbluConfig' unless @meshbluConfig?
    throw new Error 'Missing required parameter: ownerUUID' unless @ownerUUID?
    throw new Error 'Missing required parameter: peterPartyUUID' unless @peterPartyUUID?

    @meshblu = new MeshbluHTTP @meshbluConfig

  create: (i, done) =>
    @meshblu.register @_registerParams(i), done

  _registerParams: (i) =>
    owner: @ownerUUID
    type: 'device:peter'
    name: "peter-#{i}"
    logo: 'https://s3-us-west-2.amazonaws.com/octoblu-cdn/fleet/KijEejxiq.svg'
    online: true
    meshblu:
      version: '2.0.0'
      whitelists:
        configure:
          update: [{uuid: @ownerUUID}]
          sent: [{uuid: @peterPartyUUID}]
        discover:
          view: [{uuid: @ownerUUID}]
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

module.exports = PeterCreator
