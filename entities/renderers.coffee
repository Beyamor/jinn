define ["jinn/debug"],
	(debug) ->
		ns = {}

		class ns.CanvasRenderer
			constructor: (@canvas) ->
				throw new Error "Need a canvas (#{@canvas})" unless @canvas?

			render: (entities, camera) ->
				renderList = entities.inBounds camera
				renderList.sort (a, b) -> b.layer - a.layer

				for entity in renderList
					if entity.graphic?
						entity.graphic.render @canvas, entity.pos, camera

					if debug.isEnabled 'hitboxes'
						context = app.canvas.context
						context.beginPath()
						context.rect(
							entity.pos.x + entity.offset.x - camera.x,
							entity.pos.y + entity.offset.y - camera.y,
							entity.width,
							entity.height
						)
						context.strokeStyle = 'red'
						context.stroke()

		return ns
