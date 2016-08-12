async       = require 'async'
MeshbluHttp = require 'meshblu-http'

class Destroyer
  constructor: ({meshbluConfig, @manifest}) ->
    @meshblu = new MeshbluHttp meshbluConfig

  destroy: (callback) =>
    async.series [@_destroyPeterParty, @_destroyPeters], callback

  _destroyPeterParty: (callback) =>
    @meshblu.unregister uuid: @manifest.peterPartyUUID, callback

  _destroyPeter: (peterUUID, callback) =>
    @meshblu.unregister uuid: peterUUID, callback

  _destroyPeters: (callback) =>
    async.each @manifest.peterUUIDs, @_destroyPeter, callback

module.exports = Destroyer
