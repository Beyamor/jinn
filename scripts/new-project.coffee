#!/usr/bin/env coffee
fs		= require "fs"
path		= require "path"
mustache	= require "mustache"
subprocess	= require "child_process"
{EOL}		= require "os"

log = (status) ->
	console.log status + "..."

exec = (command, args...) ->
	process = subprocess.spawn command, args, stdio: "inherit"

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
	log "writing " + fileName
	text = JSON.stringify data, null, 4
	fs.writeFile fileName, text

renderTemplate = (destName, templateName, data) ->
	log "writing " + destName
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

log "installing"
exec "bower", "install"

renderTemplate "index.html", "new-project-index.html",
	project_name: projectName

renderTemplate path.join("src", projectName, "main.coffee"), "new-project-main.coffee", {}

log "setting up git"
ignoredFiles = ["/js", ".sw[op]"]
fs.writeFile ".gitignore", ignoredFiles.join EOL
exec "git", "init"
