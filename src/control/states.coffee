define [],
	() ->
		ns = {}

		class ns.StateMachine
			constructor: ({initial, states}) ->
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
						@state.end() if @state.end?

					@state = @nextState
					
					@state.begin() if @state.begin?

				@state.update()

		return ns
