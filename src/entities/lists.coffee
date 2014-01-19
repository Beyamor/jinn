define ["jinn/util"],
	(util) ->
		ns = {}

		CELL_WIDTH = CELL_HEIGHT = 200

		class ns.SimpleEntityList
			constructor: ->
				@list		= []
				@toAdd	 	= []
				@toRemove	= []

			remove: (e) ->
				return unless e?
				@toRemove.push e

			add: (e) ->
				return unless e?
				@toAdd.push e

			updateLists: ->
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
			update: ->
				entity.update() for entity in @list
				@updateLists()

			first: (type) ->
				(return e) for e in @list when e.hasType type
				return null

			inBounds: (rect) ->
				e for e in @list when util.aabbsIntersect e, rect

			each: (f) ->
				f(e) for e in @list

		class BaseSpatialEntityList extends ns.SimpleEntityList
			constructor: ->
				super()
				@entityCells	= {}

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


			rebuildCells: ->
				@entityCells = {}
				@addToCells(entity) for entity in @list

		class StaticSpatialEntityList extends BaseSpatialEntityList
			add: (e) ->
				@addToCells e
				super e

			remove: (e) ->
				@removeFromCells e
				super e

		class DynamicSpatialEntityList extends BaseSpatialEntityList
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
				@updateLists()

		class ns.SpatialEntityList
			constructor: ->
				@statics	= new StaticSpatialEntityList
				@dynamics	= new DynamicSpatialEntityList

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

			each: (f) ->
				@statics.each f
				@dynamics.each f

		return ns
