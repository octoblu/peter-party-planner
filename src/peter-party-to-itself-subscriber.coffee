MeshbluHTTP = require 'meshblu-http'

class PeterPartyToItselfSubscriber
  constructor: ({@meshbluConfig, @peterPartyUUID}={}) ->
    throw new Error 'Missing required parameter: meshbluConfig' unless @meshbluConfig?
    throw new Error 'Missing required parameter: peterPartyUUID' unless @peterPartyUUID?
    @meshblu = new MeshbluHTTP @meshbluConfig

  subscribe: (callback) =>
    @_subscribeToConfigureReceived (error) =>
      return callback error if error?
      @_subscribeToConfigureSent callback

  _subscribeToConfigureReceived: (callback) =>
    @meshblu.createSubscription {
      emitterUuid: @peterPartyUUID
      subscriberUuid: @peterPartyUUID
      type: 'configure.received'
    }, callback

  _subscribeToConfigureSent: (callback) =>
    @meshblu.createSubscription {
      emitterUuid: @peterPartyUUID
      subscriberUuid: @peterPartyUUID
      type: 'configure.sent'
    }, callback

module.exports = PeterPartyToItselfSubscriber
