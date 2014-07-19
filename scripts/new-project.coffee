#!/usr/bin/env coffee
fs		= require "fs"
path		= require "path"
mustache	= require "mustache"
subprocess	= require "child_process"
{EOL}		= require "os"

log = console.log

thenLog = (message) ->
	(err) ->
		if err?
			console.log "Whoa: #{err}"
		else
			log message

exec = (command, args...) ->
	process = subprocess.spawn command, args,
			stdio: "inherit"

[_, _, projectName] = process.argv


unless projectName?
	console.log "Yo, you need a file name."
	process.exit 1

fs.mkdirSync projectName
process.chdir projectName

fs.mkdir "src"
fs.mkdir path.join("src", projectName)
fs.mkdir "templates"

writeJSON = (fileName, data) ->
	text = JSON.stringify data, null, 4
	fs.writeFile fileName, text, thenLog "Wrote #{fileName}"

renderTemplate = (destName, templateName, data) ->
	fs.readFile path.join(__dirname, templateName), (_, template) ->
		text = mustache.render "#{template}", data
		fs.writeFile destName, text

writeJSON "bower.json",
	name: projectName,
	version: "0.0.0",
	dependencies:
		jinn: "file:///home/beyamor/code/games/engines/jinn/.git"

writeJSON ".bowerrc",
	directory: "js/lib",
	scripts:
		postinstall: "coffee -c -o js/lib/jinn/dist js/lib/jinn/src"

exec "bower", "install"

renderTemplate "index.html", "new-project-index.html",
	project_name: projectName

renderTemplate path.join("src", projectName, "main.coffee"), "new-project-main.coffee", {}

ignoredFiles = ["/js", ".sw[op]"]
fs.writeFile ".gitignore", ignoredFiles.join(EOL), thenLog "Wrote .gitignore"
exec "git", "init"
