#!/usr/bin/env node

require('coffee-script/register');
var Command = require('./command-remove.coffee');
var command = new Command(process.argv);
command.run();