fs		= require "fs"
path		= require "path"
mustache	= require "mustache"
subprocess	= require "child_process"
{EOL}		= require "os"
{argv}		= require "optimist"

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

writeJSON = (fileName, data) ->
	text = JSON.stringify data, null, 4
	fs.writeFile fileName, text, thenLog "Wrote #{fileName}"

renderTemplate = (destName, templateName, data) ->
	fs.readFile path.join(__dirname, templateName), (err, template) ->
		if err?
			log err
		else
			text = mustache.render "#{template}", data
			fs.writeFile destName, text, thenLog "Wrote #{destName}"

copyFile = (destName, sourceName) ->
	fs.readFile path.join(__dirname, sourceName), (err, contents) ->
		if err?
			log err
		else
			fs.writeFile destName, contents, thenLog "Wrote #{destName}"

run = exports.run = ({projectName, namespace}) ->
	namespace or= projectName

	unless projectName?
		console.log "Need a name"
		process.exit 1

	fs.mkdirSync projectName
	process.chdir projectName

	fs.mkdir "src"
	fs.mkdir path.join("src", namespace)
	fs.mkdir "templates"
	fs.mkdir "scss"

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
		namespace: namespace

	copyFile path.join("src", namespace, "main.coffee"), "new-project-main.coffee"
	copyFile path.join("scss", "core.scss"), "new-project-core.scss"
	copyFile path.join("scss", "debug.scss"), "new-project-debug.scss"

	ignoredFiles = ["/js", ".sw[op]", "/css"]
	fs.writeFile ".gitignore", ignoredFiles.join(EOL), thenLog "Wrote .gitignore"
	exec "git", "init"
