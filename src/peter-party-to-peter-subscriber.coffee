MeshbluHTTP = require 'meshblu-http'

class PeterPartyToPeterSubscriber
  constructor: ({@peterPartyUUID, @meshbluConfig}={}) ->
    throw new Error 'Missing required parameter: meshbluConfig' unless @meshbluConfig?
    throw new Error 'Missing required parameter: peterPartyUUID' unless @peterPartyUUID?
    @meshblu = new MeshbluHTTP @meshbluConfig

  subscribe: (peterUUID, callback) =>
    @_createBroadcastSentSubscription peterUUID, (error) =>
      return callback error if error?
      @_createConfigureSentSubscription peterUUID, (error) =>
        return callback error if error?
        @_updatePeterPartyDiscoverAs peterUUID, callback

  _createBroadcastSentSubscription: (peterUUID, callback) =>
    @meshblu.createSubscription {
      emitterUuid: peterUUID
      subscriberUuid: @peterPartyUUID
      type: 'broadcast.sent'
    }, callback

  _createConfigureSentSubscription: (peterUUID, callback) =>
    @meshblu.createSubscription {
      emitterUuid: peterUUID
      subscriberUuid: @peterPartyUUID
      type: 'configure.sent'
    }, callback

  _updatePeterPartyDiscoverAs: (peterUUID, callback) =>
    update =
      $addToSet:
        'meshblu.whitelists.discover.as': {uuid: peterUUID}
        
    @meshblu.updateDangerously @peterPartyUUID, update, callback

module.exports = PeterPartyToPeterSubscriber
