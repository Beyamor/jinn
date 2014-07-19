#!/usr/bin/env python
import sys
import os 
from os import path
import json
import subprocess
import mustache

def main(project_name):
	os.makedirs(project_name)
	os.chdir(project_name)

	os.makedirs("src");
	os.makedirs(path.join("src", project_name))
	os.makedirs("templates");

	def write_json(file_name, data):
		print("writing " + file_name + "...")
		with open(file_name, "w") as f:
			f.write(json.dumps(data, indent=4))

	def render_template(dest_name, template_name, data):
		print("writing " + dest_name + "...")
		with open(path.join(path.dirname(__file__), template_name), "r") as template_file:
			template = template_file.read()

		with open(dest_name, "w") as dest_file:
			dest_file.write(mustache.render(template, data))

	write_json("bower.json", {
	"name":	project_name,
	"version":	"0.0.0",
	"dependencies": {
		"jinn": "file:///home/beyamor/code/games/engines/jinn/.git"
		}
	})

	write_json(".bowerrc", {
	"directory": "js/lib",
	"scripts": {
		"postinstall": "coffee -c -o js/lib/jinn/dist js/lib/jinn/src"
		}
	})

	print("installing...")
	subprocess.call(["bower", "install"])

	render_template("index.html", "new-project-index.html", {
	"project_name": project_name
	})

	render_template(path.join("src", project_name, "main.coffee"), "new-project-main.coffee", {
	})

	print("setting up git...")
	ignored_files = [
	"/js"
	]
	with open(".gitignore", "w") as f:
		for ignored_file in ignored_files:
			f.write(ignored_file + "\n")

	subprocess.call(["git", "init"])

if __name__ == "__main__":
	if len(sys.argv) != 2:
		sys.exit("Wrong number of arguments")
	main(sys.argv[1])
