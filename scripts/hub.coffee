#!/usr/bin/env coffee
newProject	= require "./new-project.coffee"
{argv}		= require "optimist"

commands =
	"new": newProject

[command, args...] = argv._

unless command?
	console.log "jinn what?"
	process.exit 1

unless commands[command]?
	console.log "Unrecognized command #{command}"
	process.exit 1

commands[command].run args...
