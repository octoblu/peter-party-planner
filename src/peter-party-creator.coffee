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
          update: [{uuid: @ownerUUID}]
        discover:
          view: [{uuid: @ownerUUID}]

module.exports = PeterPartyCreator
