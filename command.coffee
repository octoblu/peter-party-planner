colors        = require 'colors'
dashdash      = require 'dashdash'
_             = require 'lodash'

packageJSON       = require './package.json'
CommandInit       = require './command-init.coffee'

SUB_COMMANDS = [{
  name: 'init'
  command: CommandInit
}]

OPTIONS = [{
  names: ['help', 'h']
  type: 'bool'
  help: 'Print this help and exit.'
}, {
  names: ['version', 'v']
  type: 'bool'
  help: 'Print the version and exit.'
}]

class Command
  constructor: (argv) ->
    process.on 'uncaughtException', @die
    {SubCommand} = @parseOptions(argv)
    @subCommand = new SubCommand argv

  parseOptions: (argv) =>
    parser = dashdash.createParser({options: OPTIONS, allowUnknown: true, interspersed: false})
    options = parser.parse(argv)

    SubCommand = _.find SUB_COMMANDS, {name: _.first(options._args)}

    if options.help
      console.log @usage parser
      process.exit 0

    if options.version
      console.log packageJSON.version
      process.exit 0

    unless SubCommand?
      console.error @usage parser
      console.error colors.red 'Invalid <COMMAND>'
      process.exit 1

    return {SubCommand: SubCommand.command}


  run: =>
    @subCommand.run()

  die: (error) =>
    return process.exit(0) unless error?
    console.error 'ERROR'
    console.error error.stack
    process.exit 1

  usage: (parser) =>
    return """
    usage: peter-party-planner [OPTIONS] <COMMAND>

    commands:
        init    initialize a new party (with new peters)

    options:
    #{parser.help({includeEnv: true})}
    """

module.exports = Command
