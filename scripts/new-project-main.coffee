define ["jinn/app"],
	(app) ->
		app.assets = []

		app.templates = []

		app.launch
			id: "game"
			canvas:
				width: 800
				height: 600
			init: ->
				alert "hello world"
