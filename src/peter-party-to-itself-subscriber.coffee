MeshbluHTTP = require 'meshblu-http'

class PeterPartyToItselfSubscriber
  constructor: ({@meshbluConfig, @peterPartyUUID}={}) ->
    throw new Error 'Missing required parameter: meshbluConfig' unless @meshbluConfig?
    throw new Error 'Missing required parameter: peterPartyUUID' unless @peterPartyUUID?
    @meshblu = new MeshbluHTTP @meshbluConfig

  subscribe: (done) =>
    @meshblu.createSubscription {
      emitterUuid: @peterPartyUUID
      subscriberUuid: @peterPartyUUID
      type: 'configure.received'
    }, done

module.exports = PeterPartyToItselfSubscriber
