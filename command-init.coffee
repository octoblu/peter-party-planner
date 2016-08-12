colors        = require 'colors'
dashdash      = require 'dashdash'
_             = require 'lodash'
MeshbluConfig = require 'meshblu-config'

packageJSON       = require './package.json'
PeterPartyPlanner = require './src/peter-party-planner'

OPTIONS = [{
  names: ['help', 'h']
  type: 'bool'
  help: 'Print this help and exit.'
}, {
  names: ['owner', 'owner-uuid', 'o']
  type: 'string'
  helpArg: 'UUID'
  env: 'PPP_OWNER'
  help: 'Uuid of the owner of this party (and all associated petes)'
}, {
  names: ['peters', 'peters-count', 'p']
  type: 'integer'
  helpArg: '1'
  env: 'PPP_PETERS'
  default: 1
  help: 'Number of peters in this party'
}, {
  names: ['version', 'v']
  type: 'bool'
  help: 'Print the version and exit.'
}]

class CommandInit
  constructor: (argv) ->
    process.on 'uncaughtException', @die

    options = @parseOptions(argv)

    @meshbluConfig = new MeshbluConfig().toJSON()
    @ownerUUID     = options.owner
    @petersCount   = options.peters

  parseOptions: (argv) =>
    parser = dashdash.createParser({options: OPTIONS})
    options = parser.parse(argv)

    if options.help
      console.log @usage parser
      process.exit 0

    if options.version
      console.log packageJSON.version
      process.exit 0

    unless options.owner? && options.peters?
      console.error @usage parser
      console.error colors.red 'Missing required parameter --owner, -o, or env: PPP_OWNER' unless options.owner?
      console.error colors.red 'Missing required parameter --peters, -p, or env: PPP_PETERS' unless options.peters?
      process.exit 1

    return _.pick options, 'owner', 'peters'

  run: =>
    planner = new PeterPartyPlanner {@meshbluConfig, @ownerUUID, @petersCount}
    planner.plan @die

  die: (error) =>
    return process.exit(0) unless error?
    console.error 'ERROR'
    console.error error.stack
    process.exit 1

  usage: (parser) =>
    return """
    usage: peter-party-planner init [OPTIONS]

    options:
    #{parser.help({includeEnv: true})}
    """

module.exports = CommandInit
