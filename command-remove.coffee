colors        = require 'colors'
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
  help: '''
    File path to read and write the manifest from.
    Will be updated to omit the removed peter. defaults to party.cson
  '''
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
    @manifest      = cson.parse fs.readFileSync options.file
    @peterNames    = options.peterNames

  parseOptions: (argv) =>
    parser = dashdash.createParser({options: OPTIONS})
    options = parser.parse(argv)

    file = options.file
    peterNames = _.without options._args, 'remove'

    if options.help
      console.log @usage parser
      process.exit 0

    if options.version
      console.log packageJSON.version
      process.exit 0

    if _.isEmpty peterNames
      console.error @usage parser
      console.error colors.red 'At least one PETER_NAME must be provided'
      process.exit 1

    return {file, peterNames}

  run: =>
    destroyer = new Destroyer {@manifest, @meshbluConfig}
    destroyer.destroy (error, manifest) =>
      return @die error if error?
      @output cson.stringify manifest
      @die()

  output: (output) =>
    return console.log output unless @filePath?
    fs.writeFileSync @filePath, output

  die: (error) =>
    return process.exit(0) unless error?
    console.error 'ERROR'
    console.error error.stack
    process.exit 1

  usage: (parser) =>
    return """
    usage: peter-party-planner destroy [OPTIONS] <PETER_NAME> [PETTER_NAME...]

    destroy an existing party and all associated peters.

    options:
    #{parser.help({includeEnv: true})}
    """

module.exports = CommandInit
