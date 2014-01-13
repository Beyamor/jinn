define ['jinn/util', 'jinn/app'], (util, app) ->
	ns = {}

	class ns.Camera
		constructor: ->
			@pos = {x: 0, y: 0}

		update: ->
			# nothing

		@properties
			x:
				get: -> @pos.x
				set: (x) -> @pos.x = x

			y:
				get: -> @pos.y
				set: (y) -> @pos.y = y

			width:
				get: -> app.width

			height:
				get: -> app.height

			left:
				get: -> @x

			right:
				get: -> @left + @width

			top:
				get: -> @y

			bottom:
				get: -> @top + @height

	class ns.CameraWrapper extends ns.Camera
		constructor: (@base) ->

		update: ->
			@base.update()

		@properties
			x:
				get: -> @base.x
				set: (x) -> @base.x = x

			y:
				get: -> @base.y
				set: (y) -> @base.y = y

			width:
				get: -> @base.width

			height:
				get: -> @base.height

	class ns.EntityCamera extends ns.CameraWrapper
		constructor: (@ent, base) ->
			super base

		update: ->
			super()
			@x = @ent.x - app.width / 2
			@y = @ent.y - app.height / 2

	class ns.BoundedCamera extends ns.CameraWrapper
		constructor: (@bounds, base) ->
			super base

		update: ->
			super()
			@base.x = @bounds.left if @base.left < @bounds.left
			@base.y = @bounds.top if @base.top < @bounds.top
			@base.x = @bounds.right - @width if @base.right > @bounds.right
			@base.y = @bounds.bottom - @height if @base.bottom > @bounds.bottom

	return ns
