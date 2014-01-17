define ['jinn/debug', 'jinn/app', 'jinn/cameras', 'jinn/util', 'jinn/entities', 'jinn/particles',
	"jinn/entities/spaces"],
	(debug, app, cameras, util, entities, particles,\
	{EntitySpace}) ->

		ns = {}

		class ns.Scene
			constructor: ->
				@spaces = []

				@windows		= []
				@windowsToAdd		= []
				@windowsToRemove	= []

			begin: ->

			end: ->
				window.$el.remove() for window in @windows

			addWindow: (window) ->
				@windowsToAdd.push window
				
			removeWindow: (window) ->
				@windowsToRemove.push window

			update: ->
				isBlocked = false
				for window in @windows when window.update?
					window.update()
					if window.blocks
						isBlocked = true
						break

				if @windowsToAdd.length isnt 0
					for window in @windowsToAdd
						app.container.append window.$el
						@windows.push window
						window.scene = this
					@windowsToAdd = []

				if @windowsToRemove.length isnt 0
					for window in @windowsToRemove
						window.$el.remove()
						@windows.remove window
					@windowsToRemove = []


				unless isBlocked
					space.update() for space in @spaces

			render: ->
				for window in @windows when window.render?
					window.render()

				space.render() for space in @spaces

			@properties
				space:
					get: ->
						unless @spaces?
							@spaces = []
						unless @spaces.length > 0
							@spaces[0] = new EntitySpace
						return @spaces[0]

					set: (space) ->
						unless @spaces?
							@spaces = []
						@spaces[0] = space


		return ns
