define ["jinn/app", "jinn/debug"],
	(app, debug) ->
		debug.configure
			enabled: true
			flags:
				fps: true
				hitboxes: true

		app.assets = []

		app.templates = []

		app.launch
			id: "game"
			canvas:
				width: 800
				height: 600
			init: ->
				alert "hello world"
