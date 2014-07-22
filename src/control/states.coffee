define [],
	() ->
		ns = {}

		class ns.StateMachine
			constructor: (@self, {initial, states}) ->
				@states = {}

				for name, state of states
					@registerState name, state

				@switchTo initial

			registerState: (name, state) ->
				@states[name] = state

			switchTo: (nextState) ->
				throw new Error "Uknown state #{nextState}" unless @states[nextState]?
				@nextState = @states[nextState]

			update: ->
				if @nextState?
					if @state?
						@state.end.call(@self) if @state.end?

					@state = @nextState
					
					@state.begin.call(@self) if @state.begin?
					@nextState = null

				@state.update.call(@self)

		return ns
