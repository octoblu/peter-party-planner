async = require 'async'
_     = require 'lodash'

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
    ], (error) =>
      return callback error if error?
      callback null, _.cloneDeep({peterParty: {uuid: @peterPartyUUID}, @peters})

  _createPeter: (i, callback) =>
    creator = new PeterCreator {@meshbluConfig, @ownerUUID, @peterPartyUUID}
    creator.create i, (error, peter) =>
      return callback error if error?
      @_pushPeter peter
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
    @peters ?= []
    @peters.push uuid

  _subscribePeterPartyToPeter: (peter, callback) =>
    subscriber = new PeterPartyToPeterSubscriber {@meshbluConfig, @peterPartyUUID}
    subscriber.subscribe peter.uuid, callback

  _subscribePeterPartyToPeters: (callback) =>
    async.each @peters, @_subscribePeterPartyToPeter, callback

  _subscribePeterPartyToItself: (callback) =>
    subscriber = new PeterPartyToItself {@meshbluConfig, @peterPartyUUID}
    subscriber.subscribe callback

module.exports = PeterPartyPlanner
