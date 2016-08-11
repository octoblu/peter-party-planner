async    = require 'async'
colors   = require 'colors'
dashdash = require 'dashdash'
_        = require 'lodash'

packageJSON       = require './package.json'
PeterCreator      = require './src/peter-creator'
PeterPartyCreator = require './src/peter-party-creator'
PeterPartyToPeterSubscriber = require './src/peter-party-to-peter-subscriber'

OPTIONS = [{
  names: ['help', 'h']
  type: 'bool'
  help: 'Print this help and exit.'
}, {
  names: ['owner', 'owner-uuid', 'o']
  type: 'string'
  env: 'PPP_OWNER'
  help: 'Uuid of the owner of this party (and all associated petes)'
}, {
  names: ['peters', 'peters-count', 'p']
  type: 'integer'
  env: 'PPP_PETERS'
  default: 1
  help: 'Number of peters in this party'
}, {
  names: ['version', 'v']
  type: 'bool'
  help: 'Print the version and exit.'
}]

class Command
  constructor: ->
    process.on 'uncaughtException', @die

    options = @parseOptions()
    @petersCount = options.peters
    @ownerUUID   = options.owner

  parseOptions: =>
    parser = dashdash.createParser({options: OPTIONS})
    options = parser.parse(process.argv)

    if options.help
      console.log "usage: meshblu-verifier-http [OPTIONS]\noptions:\n#{parser.help({includeEnv: true})}"
      process.exit 0

    if options.version
      console.log packageJSON.version
      process.exit 0

    unless options.owner? && options.peters?
      console.error "usage: meshblu-verifier-http [OPTIONS]\noptions:\n#{parser.help({includeEnv: true})}"
      console.error colors.red 'Missing required parameter --owner, -o, or env: PPP_OWNER' unless options.owner?
      console.error colors.red 'Missing required parameter --peters, -p, or env: PPP_PETERS' unless options.peters?
      process.exit 1

    return _.pick options, 'owner', 'peter'

  run: =>
    async.series [
      @_createPeterParty
      @_createPeters
      @_subscribePeterPartyToPeters
    ], @die

  die: (error) =>
    return process.exit(0) unless error?
    console.error 'ERROR'
    console.error error.stack
    process.exit 1

  _createPeter: (i, callback) =>
    creator = new PeterCreator {@ownerUUID, @peterPartyUUID}
    creator.create (error, peter) =>
      return callback error if error?
      @_pushPeter peter.uuid
      callback()

  _createPeters: (callback) =>
    return callback() unless @petersCount > 0
    async.times @petersCount, @_createPeter, callback

  _createPeterParty: (callback) =>
    creator = new PeterPartyCreator ownerUUID: @ownerUUID
    creator.create (error, peterParty) =>
      return callback error if error?
      @peterPartyUUID = peterParty.uuid
      callback()

  _pushPeter: (uuid) =>
    @peterUUIDs ?= []
    @peterUUIDs.push uuid

  _subscribePeterPartyToPeters: (callback) =>
    subscriber = new PeterPartyToPeterSubscriber {@peterPartyUUID}
    async.each @peterUUIDs, subscriber.subscribe, callback


module.exports = Command
