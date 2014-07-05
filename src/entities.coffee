define ['jinn/app', 'jinn/util', 'jinn/mixins'], (app, util, mixins) ->
	ns = {}

	class Velocity
		constructor: (@x, @y) ->

		@properties
			speed:
				get: ->
					Math.sqrt(@x*@x + @y*@y)

				set: (speed) ->
					direction = @direction
					@x = Math.cos(direction) * speed
					@y = Math.sin(direction) * speed

			direction:
				get: ->
					Math.atan2(@y, @x)

				set: (direction) ->
					speed = @speed
					@x = Math.cos(direction) * speed
					@y = Math.sin(direction) * speed


	class ns.Entity
		constructor: (args) ->
			@pos			= {x: args.x, y: args.y}
			@graphic		= args.graphic
			@vel			= new Velocity 0, 0
			@layer			= args.layer or 0
			@width			= args.width or 0
			@height			= args.height or args.width or 0
			@offset			= {x: 0, y: 0}
			@collisionHandlers	= args.collisionHandlers or {}
			@type			= args.type
			@static			= args.static
			@mixins			= if args.mixins? then mixins.realize args.mixins else []

			@center() if args.centered?

			mixin.init.call(this) for mixin in @mixins when mixin.init?

			@updateables = new util.UpdateList

		center: ->
			@offset.x = -@width * 0.5
			@offset.y = -@height * 0.5

		collide: (type, x, y) ->
			return null unless @space
			prevX = @pos.x
			prevY = @pos.y
			@pos.x = x
			@pos.y = y

			result = @space.entities.collide this, type

			@pos.x = prevX
			@pos.y = prevY

			return result

		move: ->
			xSteps	= Math.floor(Math.abs(@vel.x * app.elapsed))
			xInc 	= util.sign(@vel.x)

			stop = false
			while xSteps > 0
				for type, handler of @collisionHandlers
					handler = handler.x if handler.x?
					collision = @collide type, @pos.x + xInc, @pos.y
					if collision
						stop = handler.call(this, collision)

					if stop
						@vel.x = 0
						break

				break if stop

				if @shouldStopMovingHorizontally? and @shouldStopMovingHorizontally()
					break

				@pos.x += xInc
				xSteps -= 1

			ySteps	= Math.floor(Math.abs(@vel.y * app.elapsed))
			yInc 	= util.sign(@vel.y)

			stop = false
			while ySteps > 0
				for type, handler of @collisionHandlers
					handler = handler.y if handler.y?
					collision = @collide type, @pos.x, @pos.y + yInc
					if collision
						stop = handler.call(this, collision)

					if stop
						@vel.y = 0
						break

				break if stop

				if @shouldStopMovingVertically? and @shouldStopMovingVertically()
					break

				@pos.y += yInc
				ySteps -= 1

		update: ->
			if @vel.x isnt 0 or @vel.y isnt 0
				@move()
			else
				for type, handler of @collisionHandlers
					collision = @collide type, @pos.x, @pos.y
					handler(collision) if collision

			mixin.update.call(this) for mixin in @mixins when mixin.update?
			@updateables.update()
			
		render: ->
			return unless @graphic and @space and @space.camera
			@graphic.render @renderTarget, @pos, @space.camera

		hasType: (type) ->
			@type? and @type is type

		remove: ->
			if @space?
				@space.remove this

		@properties
			left:
				get: -> @pos.x + @offset.x
				set: (left) -> @pos.x = left - @offset.x

			right:
				get: -> @left + @width - 0.0001 # uhhhh
				set: (right) -> @left = right - @width

			top:
				get: -> @pos.y + @offset.y
				set: (top) -> @pos.y = top - @offset.y

			bottom:
				get: -> @top + @height - 0.0001
				set: (bottom) -> @top = bottom - @height

			x:
				get: -> @pos.x
				set: (x) -> @pos.x = x

			y:
				get: -> @pos.y
				set: (y) -> @pos.y = y

			centerX:
				get: -> if @width? then (@left + @right) / 2 else @x
				set: (centerX) -> if @width? then @left = centerX - @width/2 else @x = centerX

			centerY:
				get: -> if @height? then (@top + @bottom) / 2 else @y
				set: (centerY) -> if @height? then @top = centerY - @height/2 else @y = centerY

			renderTarget:
				get: -> app.canvas

	return ns
