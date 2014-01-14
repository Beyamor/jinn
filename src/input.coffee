SPECIAL_BROWSER_KEYS = [
	32, # space
	37, # left
	38, # right
	39, # down
	40, # up
]

vkDefinitions = {
	"vk_backspace":		8
	"vk_tab":		9
	"vk_enter":		13
	"vk_shift":		16
	"vk_control":		17
	"vk_alt":		18
	"vk_pause":		19
	"vk_capslock":		20
	"vk_escape":		27
	"vk_pageup":		33
	"vk_pagedown":		34
	"vk_end":		35
	"vk_home":		36
	"vk_left":		37
	"vk_up":		38
	"vk_right":		39
	"vk_down":		40
	"vk_insert":		45
	"vk_delete":		46
	"vk_semicolon":		186
	"vk_equals":		187
	"vk_comma":		188
	"vk_dash":		189
	"vk_period":		190
	"vk_forwardslash":	191
	"vk_grave":		192
	"vk_openbracket":	219
	"vk_backslash":		220
	"vk_closebracket":	221
	"vk_singlequote":	222
}

# numbers
for number in [0..9]
	vkDefinitions["vk_#{number}"] = (48 + number)

# letters
for key in [65..90]
	name = "vk_#{String.fromCharCode(key - 65 + 97)}"
	vkDefinitions[name] = key

define ->
	input =
		currentState: {}
		prevState: {}
		events: []
		mappings: {}

		mouseX: 0
		mouseY: 0
		prevMouseX: 0
		prevMouseY: 0

		isDown: (key, state) ->
			state or= @currentState
			if @mappings[key]?
				return @isDown @mappings[key], state
			else
				state = state[key]
				return state is 'down'

		isUp: (key, state) ->
			state or= @currentState
			if @mappings[key]?
				return @isUp @mappings[key], state
			else
				state = state[key]
				return (not state) or state is 'up'

		pressed: (key) ->
			@isDown(key, @currentState) and @isUp(key, @prevState)

		released: (key) ->
			@isUp(key, @currentState) and @isDown(key, @prevState)

		define: (mappings) ->
			for from, to of mappings
				@mappings[from] = to

		update: ->
			# first, copy the state over
			@prevState = {}
			for k, v of @currentState
				@prevState[k] = v

			# then, update the current state
			for [k, v] in @events
				@currentState[k] = v

			# and finally, clear the events
			@events = []


		watch: ($el) ->
			eventToMouseButton = (e) ->
				switch e.which
					when 1 then 'mouse-left'
					when 2 then 'mouse-middle'
					when 3 then 'mouse-right'

			$el.keydown (e) =>
				e.preventDefault() if SPECIAL_BROWSER_KEYS.indexOf(e.which) isnt -1
				@events.push [e.which, 'down']

			.keyup (e) =>
				e.preventDefault() if SPECIAL_BROWSER_KEYS.indexOf(e.which) isnt -1
				@events.push [e.which, 'up']

			.mousemove (e) =>
				@prevMouseX	= @mouseX
				@prevMouseY	= @mouseY
				@mouseX		= e.pageX - $el.parent().offset().left
				@mouseY		= e.pageY - $el.parent().offset().top

			.mousedown (e) =>
				@events.push [eventToMouseButton(e), 'down']

			.mouseup (e) =>
				@events.push [eventToMouseButton(e), 'up']

			$el.attr 'oncontextmenu', 'return false;'

	input.define vkDefinitions

	Object.defineProperty input, "mouseMoved",
		get: -> @mouseX isnt @prevMouseX or @mouseY isnt @prevMouseY

	return input
