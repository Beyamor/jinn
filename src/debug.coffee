define ['jquery'],
	($) ->
		log: (args...) ->
			return unless @enabled
			console.log args.join ', '

		logFlag: (flag, args...) ->
			return unless @flags and @flags[flag]
			@log.apply this, args

		configure: (opts) ->
			for k, v of opts
				@[k] = v
				
		init: (app) ->
			@screen = $('<div class="debug-screen">')
			app.container.append @screen

			if @isEnabled 'fps'
				@fpsSamples = []
				@screen.append $('<div class="fps">')

		showFPS: (elapsed) ->
			return unless @isEnabled 'fps'

			@fpsSamples.push elapsed
			@fpsSamples.shift() if @fpsSamples.length > 3
			elapsedAvg = 0
			(elapsedAvg += sample) for sample in @fpsSamples
			elapsedAvg /= @fpsSamples.length

			$('.fps', @screen).text(Math.floor(1 / elapsedAvg))

		isEnabled: (flag) ->
			return @enabled and @flags[flag]

		toggle: (flag) ->
			@flags[flag] = not @flags[flag]
