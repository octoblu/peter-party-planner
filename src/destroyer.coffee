async       = require 'async'
MeshbluHttp = require 'meshblu-http'

class Destroyer
  constructor: ({meshbluConfig, @manifest}) ->
    @meshblu = new MeshbluHttp meshbluConfig

  destroy: (callback) =>
    async.series [@_destroyPeterParty, @_destroyPeters], callback

  _destroyPeterParty: (callback) =>
    @meshblu.unregister uuid: @manifest.peterParty.uuid, callback

  _destroyPeter: (peter, callback) =>
    @meshblu.unregister uuid: peter.uuid, callback

  _destroyPeters: (callback) =>
    async.each @manifest.peters, @_destroyPeter, callback

module.exports = Destroyer
