MeshbluHTTP = require 'meshblu-http'

class PeterPartyCreator
  constructor: ({@ownerUUID, @meshbluConfig}={}) ->
    throw new Error 'Missing required parameter: meshbluConfig' unless @meshbluConfig?
    throw new Error 'Missing required parameter: ownerUUID' unless @ownerUUID?
    
    @meshblu = new MeshbluHTTP @meshbluConfig

  create: (done) =>
    @meshblu.register @_registerParams(), done

  _registerParams: =>
    owner: @ownerUUID
    type: 'device:peter-party'
    logo: 'https://s3-us-west-2.amazonaws.com/octoblu-cdn/fleet/peters.svg'
    meshblu:
      version: '2.0.0'
      whitelists:
        configure:
          update: [{uuid: @ownerUUID}]
        discover:
          view: [{uuid: @ownerUUID}]

module.exports = PeterPartyCreator
