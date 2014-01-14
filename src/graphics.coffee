define ['jinn/app', 'jinn/canvas', 'underscore',
	'jinn/util'],
	(app, {Canvas}, _, util) ->
		ns = {}

		class ns.StandardGraphic
			constructor: (args) ->
				@canvas		= new Canvas width: args.width, height: args.height
				@origin		= x: 0, y: 0
				@rotation	= 0
				@dirty		= true
				@width		= @canvas.width
				@height		= @canvas.height
				@alpha		= null
				@_mirrorH	= false
				@_mirrorV	= false

				@centerOrigin() if args? and args.centered?

			centerOrigin: ->
				@origin.x = @width / 2
				@origin.y = @height / 2
				@diry = true
				return this

			rotate: (rotation) ->
				if rotation != @rotation
					@rotation = rotation
					@dirty = true
				return this

			draw: ->
				# implement in subclasses

			prerender: ->
				# I kinda feeel like this is wrong,
				# but who cares whatever
				@canvas.clear()
				context = @canvas.context
				context.save()

				context.translate @origin.x , @origin.y

				if @_mirrorH or @_mirrorV
					context.scale(
						if @_mirrorH then -1 else 1,
						if @_mirrorV then -1 else 1
					)

				if @rotation isnt 0
					context.rotate @rotation

				@draw context
				context.restore()
				@dirty = false

			render: (target, point, camera) ->
				@prerender() if @dirty
				x = point.x - @origin.x - camera.x
				y = point.y - @origin.y - camera.y

				# Uh, looks like this doesn't even matter at all
				#return unless util.aabbsIntersect camera,
				#	left: x
				#	right: x + @width
				#	top: y
				#	bottom: y + @height

				if @alpha?
					previousAlpha			= target.context.globalAlpha
					target.context.globalAlpha	= @alpha

				target.context.drawImage @canvas.el, x, y

				if @alpha?
					target.context.globalAlpha	= previousAlpha

			@properties
				mirrorH:
					set: (mirror) ->
						if mirror isnt @_mirrorH
							@_mirrorH = mirror
							@dirty = true

				mirrorV:
					set: (mirror) ->
						if mirror isnt @_mirrorV
							@_mirrorV = mirror
							@dirty = true

		class ns.Rect extends ns.StandardGraphic
			constructor: (args) ->
				@color = args.color

				super args

			draw: (context) ->
				context.fillStyle = @color
				context.fillRect -@origin.x, -@origin.y, @width, @height


		class ns.Image extends ns.StandardGraphic
			constructor: (src, args) ->
				@img = app.assets.get src

				super _.extend {
					width: @img.width
					height: @img.height
				}, args
						
			draw: (context) ->
				context.drawImage @img, -@origin.x, -@origin.y

		class ns.SpriteSheet extends ns.StandardGraphic
			constructor: (src, args) ->
				@img = app.assets.get src

				super args

				@animations	= args.animations
				@frameWidth	= args.width
				@frameHeight	= args.height
				@framesPerRow	= Math.ceil(@img.width / @frameWidth)

				@play args.play if args.play?

			play: (animation) ->
				throw new Error "Unknown animation #{animation}" unless @animations[animation]?

				@currentAnimation	= animation
				@currentFrame		= 0
				@dirty			= true

			draw: (context) ->
				return unless @currentAnimation?

				frame	= @animations[@currentAnimation][@currentFrame]
				frameX	= frame % @framesPerRow
				frameY	= Math.floor(frame / @framesPerRow)

				context.drawImage(
					@img,
					frameX * @frameWidth,
					frameY * @frameHeight,
					@frameWidth,
					@frameHeight,
					-@origin.x,
					-@origin.y,
					@frameWidth,
					@frameHeight)


		return ns
