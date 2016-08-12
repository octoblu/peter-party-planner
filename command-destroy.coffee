cson          = require 'cson'
dashdash      = require 'dashdash'
fs            = require 'fs'
_             = require 'lodash'
MeshbluConfig = require 'meshblu-config'

packageJSON = require './package.json'
Destroyer   = require './src/destroyer'

OPTIONS = [{
  names: ['file', 'f']
  type: 'string'
  help: 'File path to write the manifest from. defaults to party.cson'
  default: 'party.cson'
}, {
  names: ['help', 'h']
  type: 'bool'
  help: 'Print this help and exit.'
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
    @manifest = cson.parse fs.readFileSync options.file

  parseOptions: (argv) =>
    parser = dashdash.createParser({options: OPTIONS})
    options = parser.parse(argv)

    if options.help
      console.log @usage parser
      process.exit 0

    if options.version
      console.log packageJSON.version
      process.exit 0

    return _.pick options, 'file'

  run: =>
    destroyer = new Destroyer {@manifest, @meshbluConfig}
    destroyer.destroy @die


  die: (error) =>
    return process.exit(0) unless error?
    console.error 'ERROR'
    console.error error.stack
    process.exit 1

  usage: (parser) =>
    return """
    usage: peter-party-planner destroy [OPTIONS]

    destroy an existing party and all associated peters.

    options:
    #{parser.help({includeEnv: true})}
    """

module.exports = CommandInit
