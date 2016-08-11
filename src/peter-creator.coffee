MeshbluHTTP = require 'meshblu-http'

class PeterCreator
  constructor: ({@meshbluConfig, @ownerUUID, @peterPartyUUID}={}) ->
    throw new Error 'Missing required parameter: meshbluConfig' unless @meshbluConfig?
    throw new Error 'Missing required parameter: ownerUUID' unless @ownerUUID?
    throw new Error 'Missing required parameter: peterPartyUUID' unless @peterPartyUUID?

    @meshblu = new MeshbluHTTP @meshbluConfig

  create: (done) =>
    @meshblu.register @_registerParams(), done

  _registerParams: =>
    owner: @ownerUUID
    type: 'device:peter'
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

module.exports = PeterCreator
