define ['jinn/graphics', 'jinn/app', 'jinn/util'], (gfx, app, util) ->
	ns = {}

	realizeArg = util.realizeArg

	class ns.Particle
		constructor: (args, @target, @camera) ->

			@pos = {x: args.x, y: args.y}

			@image = new gfx.Image args.image, centered: true

			@elapsed	= 0
			@lifespan	= realizeArg args.lifespan
			@layer		= args.layer or 0
			@fade		= args.fade

			if args.speed? and args.direction?
				direction = realizeArg args.direction
				if args.directionWiggle?
					direction += -args.directionWiggle + Math.random() * args.directionWiggle * 2

				speed = realizeArg args.speed

				@vel = {x: speed * Math.cos(direction), y: speed * Math.sin(direction)}

		update: ->
			@elapsed += app.elapsed

			if @vel
				@pos.x += @vel.x * app.elapsed
				@pos.y += @vel.y * app.elapsed

			if @fade
				@image.alpha = util.lerp 1, 0, (@elapsed / @lifespan)

		render: ->
			@image.render @target, @pos, @camera

		@properties
			isDead:
				get: -> @elapsed >= @lifespan

	class Emitter
		createParticle: (description) ->
			@system.addParticle description

	class ns.ContinuousEmitter extends Emitter
		constructor: ({particle}) ->
			@constructor = util.thunkWrap particle

		kill: ->
			@isFinished = true

		update: ->
			@createParticle @constructor()

	class ns.ParticleSystem
		constructor: (@scene) ->
			@emitters	= []
			@particles	= []

		add: (emitter) ->
			return unless emitter?

			emitter.system = this
			@emitters.push emitter

		addParticle: (description) ->
			@particles.push new ns.Particle description, app.canvas, @scene.camera

		update: ->
			emittersToRemove = []
			for emitter in @emitters
				emitter.update()
				emittersToRemove.push(emitter) if emitter.isFinished
			@emitters.remove(emitter) for emitter in emittersToRemove

			particlesToRemove = []
			for particle in @particles
				particle.update()
				particlesToRemove.push(particle) if particle.isDead
			@particles.remove(particle) for particle in particlesToRemove

		render: ->
			particle.render() for particle in @particles

	return ns
