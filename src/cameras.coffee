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
				get: -> throw new Error "No camera width"

			height:
				get: -> throw new Error "No camera height"

			left:
				get: -> @x

			right:
				get: -> @left + @width

			top:
				get: -> @y

			bottom:
				get: -> @top + @height

	class ns.CanvasCamera extends ns.Camera
		constructor: (@canvas) ->
			super()

		@properties
			width:
				get: -> @canvas.width

			height:
				get: -> @canvas.height


	class ns.CameraWrapper extends ns.Camera
		constructor: (@base) ->

		update: ->
			@base.update()

		@delegate
			base:	["x", "y", "width", "height"]

	class ns.EntityCamera extends ns.CameraWrapper
		constructor: (@ent, base) ->
			super base

		update: ->
			super()
			@x = @ent.x - app.canvas.width / 2
			@y = @ent.y - app.canvas.height / 2

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
