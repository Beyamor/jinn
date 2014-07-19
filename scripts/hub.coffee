newProject	= require "./new-project.coffee"
{argv}		= require "yargs"

run =
	"new": ([projectName], namedArgs) ->
		newProject.run
			projectName: projectName
			namespace: namedArgs.ns

[command, argList...] = argv._

unless command?
	console.log "jinn what?"
	process.exit 1

unless run[command]?
	console.log "Unrecognized command #{command}"
	process.exit 1

run[command] argList, argv
