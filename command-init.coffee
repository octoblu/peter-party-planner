colors        = require 'colors'
cson          = require 'cson'
dashdash      = require 'dashdash'
fs            = require 'fs'
_             = require 'lodash'
MeshbluConfig = require 'meshblu-config'

packageJSON       = require './package.json'
PeterPartyPlanner = require './src/peter-party-planner'

OPTIONS = [{
  names: ['file', 'f']
  type: 'string'
  help: 'File path to write the manifest to. If omitted, the manifest will be written to std out instead'
}, {
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
    @filePath      = options.file
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

    return _.pick options, 'file', 'owner', 'peters'

  run: =>
    planner = new PeterPartyPlanner {@meshbluConfig, @ownerUUID, @petersCount}
    planner.plan (error, manifest) =>
      return @die error if error?
      @output cson.stringify manifest
      @die()


  die: (error) =>
    return process.exit(0) unless error?
    console.error 'ERROR'
    console.error error.stack
    process.exit 1

  output: (output) =>
    return console.log output unless @filePath?
    fs.writeFileSync @filePath, output

  usage: (parser) =>
    return """
    usage: peter-party-planner init [OPTIONS]

    init will create a new party, create new peters, add the peters to
    the party, and produce a party manifest.

    options:
    #{parser.help({includeEnv: true})}
    """

module.exports = CommandInit
