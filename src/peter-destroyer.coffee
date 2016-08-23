async       = require 'async'
_           = require 'lodash'
MeshbluHttp = require 'meshblu-http'

class PeterDestroyer
  constructor: ({meshbluConfig, @manifest}={}) ->
    throw new Error 'Missing required parameter: meshbluConfig'  unless meshbluConfig?
    throw new Error 'Missing required parameter: manifest'       unless @manifest?
    @meshblu = new MeshbluHttp meshbluConfig

  destroy: ({peterName}, callback) =>
    peter = _.find @manifest.peters, name: peterName
    return callback new Error("#{peterName} does not seem to be a member of this party") unless peter?

    async.parallel [
      async.apply @_unregister,  {peterUuid: peter.uuid}
      async.apply @_unsubscribe, {peterUuid: peter.uuid}
    ], (error) =>
      return callback error if error?
      manifest = _.cloneDeep @manifest
      _.remove manifest.peters, name: peterName
      return callback null, manifest

  _unregister: ({peterUuid}, callback) =>
    @meshblu.unregister uuid: peterUuid, callback

  _unsubscribe: ({peterUuid}, callback) =>
    @meshblu.deleteSubscription {
      emitterUuid:    peterUuid
      subscriberUuid: @manifest.peterParty.uuid
      type: 'configure.sent'
    }, callback

module.exports = PeterDestroyer
