async = require 'async'

PeterCreator                = require './peter-creator'
PeterPartyCreator           = require './peter-party-creator'
PeterPartyToItself          = require './peter-party-to-itself-subscriber'
PeterPartyToPeterSubscriber = require './peter-party-to-peter-subscriber'

class PeterPartyPlanner
  constructor: ({@meshbluConfig, @ownerUUID, @petersCount}={}) ->
    throw new Error 'Missing required parameter: meshbluConfig'  unless @meshbluConfig?
    throw new Error 'Missing required parameter: ownerUUID'      unless @ownerUUID?
    throw new Error 'Missing required parameter: petersCount'    unless @petersCount?

  plan: (callback) =>
    async.series [
      @_createPeterParty
      @_createPeters
      @_subscribePeterPartyToPeters
      @_subscribePeterPartyToItself
    ], callback

  _createPeter: (i, callback) =>
    creator = new PeterCreator {@meshbluConfig, @ownerUUID, @peterPartyUUID}
    creator.create (error, peter) =>
      return callback error if error?
      @_pushPeter peter.uuid
      callback()

  _createPeters: (callback) =>
    return callback() unless @petersCount > 0
    async.times @petersCount, @_createPeter, callback

  _createPeterParty: (callback) =>
    creator = new PeterPartyCreator {@meshbluConfig, @ownerUUID}
    creator.create (error, peterParty) =>
      return callback error if error?
      @peterPartyUUID = peterParty.uuid
      callback()

  _pushPeter: (uuid) =>
    @peterUUIDs ?= []
    @peterUUIDs.push uuid

  _subscribePeterPartyToPeters: (callback) =>
    subscriber = new PeterPartyToPeterSubscriber {@meshbluConfig, @peterPartyUUID}
    async.each @peterUUIDs, subscriber.subscribe, callback

  _subscribePeterPartyToItself: (callback) =>
    subscriber = new PeterPartyToItself {@meshbluConfig, @peterPartyUUID}
    subscriber.subscribe callback

module.exports = PeterPartyPlanner
