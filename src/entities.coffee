define ['jinn/app', 'jinn/util', 'jinn/mixins'], (app, util, mixins) ->
	ns = {}

	CELL_WIDTH = CELL_HEIGHT = 200

	class Velocity
		constructor: (@x, @y) ->

		@accessors
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
			@collisionHandlers	= {}
			@type			= args.type
			@static			= args.static
			@mixins			= if args.mixins? then mixins.realizeAll args.mixins else []

			@center() if args.centered?

			mixin.initialize.call(this) for mixin in @mixins when mixin.initialize?

			@updateables = new util.UpdateList

		center: ->
			@offset.x = -@width * 0.5
			@offset.y = -@height * 0.5

		collide: (type, x, y) ->
			return null unless @scene
			prevX = @pos.x
			prevY = @pos.y
			@pos.x = x
			@pos.y = y

			result = @scene.entities.collide this, type

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
					break if stop

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
					break if stop

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
			return unless @graphic and @scene and @scene.camera
			@graphic.render @renderTarget, @pos, @scene.camera

		hasType: (type) ->
			@type? and @type is type

		removeFromScene: ->
			if @scene?
				@scene.remove this

		@accessors
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

			renderTarget:
				get: -> app.canvas

	class BaseEntityList
		constructor: ->
			@list		= []
			@toAdd	 	= []
			@toRemove	= []
			@entityCells	= {}

		add: (e) ->
			return unless e?
			@toAdd.push e

		remove: (e) ->
			return unless e?
			@toRemove.push e

		cellBounds: (e) ->
			return {
				minCellX: Math.floor(e.left / CELL_WIDTH)
				maxCellX: Math.ceil(e.right / CELL_WIDTH)
				minCellY: Math.floor(e.top / CELL_HEIGHT)
				maxCellY: Math.ceil(e.bottom / CELL_HEIGHT)
			}

		addToCells: (e) ->
			bounds = @cellBounds e

			for x in [bounds.minCellX..bounds.maxCellX]
				@entityCells[x] or= {}
				for y in [bounds.minCellY..bounds.maxCellY]
					@entityCells[x][y] or= []
					@entityCells[x][y].push e

		removeFromCells: (e) ->
			bounds = @cellBounds e

			for x in [bounds.minCellX..bounds.maxCellX]
				for y in [bounds.minCellY..bounds.maxCellY]
					@entityCells[x][y].remove e

		update: ->
			if @toAdd.length isnt 0
				for entity in @toAdd
					@list.push entity
				@toAdd = []

			if @toRemove.length isnt 0
				for entity in @toRemove
					index = @list.indexOf entity
					if index != -1
						@list.splice index, 1
				@toRemove = []

		render: ->
			entity.render() for entity in @list

		inBounds: (rect) ->
			bounds = @cellBounds rect

			es = []

			if @entityCells
				for x in [bounds.minCellX..bounds.maxCellX]
					for y in [bounds.minCellY..bounds.maxCellY]
						if @entityCells[x] and @entityCells[x][y]
							es = es.concat @entityCells[x][y]

			return es

		nearPoint: (point) ->
			x = Math.floor point.x / CELL_WIDTH
			y = Math.floor point.y / CELL_HEIGHT

			if @entityCells? and @entityCells[x]? and @entityCells[x][y]?
				return @entityCells[x][y]
			else
				return []


		first: (type) ->
			(return e) for e in @list when e.hasType type
			return null

		rebuildCells: ->
			@entityCells = {}
			@addToCells(entity) for entity in @list

	class StaticEntityList extends BaseEntityList
		add: (e) ->
			@addToCells e
			super e

		remove: (e) ->
			@removeFromCells e
			super e

		update: ->
			entity.update() for entity in @list
			super()

	class DynamicEntityList extends BaseEntityList
		update: ->
			@rebuildCells()
			for entity in @list
				# so, this isn't perfect
				# cause, like, what if this entity moves some other one?
				# but whatever, probably good enough to just handle this case
				prevX = entity.x
				prevY = entity.y

				entity.update()

				if entity.x isnt prevX or entity.y isnt prevY
					newX = entity.x
					newY = entity.y

					entity.x = prevX
					entity.y = prevY
					@removeFromCells(entity)

					entity.x = newX
					entity.y = newY
					@addToCells(entity)

			super()

	class ns.EntityList
		constructor: ->
			@statics	= new StaticEntityList
			@dynamics	= new DynamicEntityList

		add: (e) ->
			return unless e
			if e.static then @statics.add e else @dynamics.add e

		remove: (e) ->
			return unless e
			if e.static then @statics.remove e else @dynamics.remove e

		update: ->
			@statics.update()
			@dynamics.update()

		inBounds: (rect) ->
			@statics.inBounds(rect).concat @dynamics.inBounds(rect)

		nearPoint: (point) ->
			@statics.nearPoint(point).concat @dynamics.nearPoint(point)

		collide: (e1, type) ->
			for e2 in @inBounds(e1) when (e2 isnt e1) and e2.hasType type
				return e2 if util.aabbsIntersect e1, e2
			return null

		collidePoint: (point, type) ->
			for e in @nearPoint(point) when e.hasType type
				return e if util.pointInRect point, e
			return null

		first: (type) ->
			@statics.first(type) or @dynamics.first(type)

	return ns
