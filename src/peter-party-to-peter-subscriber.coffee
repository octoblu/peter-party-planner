MeshbluHTTP = require 'meshblu-http'

class PeterPartyToPeterSubscriber
  constructor: ({@peterPartyUUID, @meshbluConfig}={}) ->
    throw new Error 'Missing required parameter: meshbluConfig' unless @meshbluConfig?
    throw new Error 'Missing required parameter: peterPartyUUID' unless @peterPartyUUID?
    @meshblu = new MeshbluHTTP @meshbluConfig

  subscribe: (peterUUID, done) =>
    @meshblu.createSubscription emitterUuid: peterUUID, subscriberUuid: @peterPartyUUID, type: 'configure.sent', done

module.exports = PeterPartyToPeterSubscriber
