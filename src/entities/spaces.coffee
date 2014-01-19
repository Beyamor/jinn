define ["jinn/entities/lists", "jinn/app", "jinn/entities/renderers",
	"jinn/cameras"],
	({SpatialEntityList}, app, {CanvasRenderer},\
	{CanvasCamera}) ->
		ns = {}

		class ns.EntitySpace
			constructor: (args) ->
				args or= {}
				{@entities, @renderer, canvas, @camera} = args

				@entities	or= new SpatialEntityList
				canvas		or= app.canvas
				@renderer	or= new CanvasRenderer canvas
				@camera		or= new CanvasCamera canvas

			update: ->
				@entities.update()
				@camera.update() if @camera.update?

			render: ->
				@renderer.render entities, @camera

			add: (e) ->
				return unless e?
				e.space = this
				@entities.add e
				e.added() if e.added?

			remove: (e) ->
				return unless e?
				e.removed() if e.removed?
				@entities.remove e
				e.space = null

		return ns
