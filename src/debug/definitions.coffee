define ['jinn/app', 'jquery', 'jquery-ui'],
	(app, $, jqueryUI) ->
		ns = {}

		ID = "definitions-debug-tweaker"

		isHidden = true

		ns.show = ->
			return unless isHidden
			isHidden = false

			el =
				$("<div id=#{ID}>")
					.draggable()

			for name, value of app.definitions
				do (name, value) ->
					definitionEl =
						$("<div class=\"definition\">")
							.text("#{name}: ")

					valueEl = $ "<input type=\"text\" value=\"#{value}\">"
					valueEl.change ->
						value = app.definitions[name].constructor valueEl.val()
						console.log "defining #{name} as #{value}"
						app.definitions[name] = value

					definitionEl.append valueEl
					el.append definitionEl

			$('body').append el

		ns.hide = ->
			$("##{ID}").remove()
			isHidden = true

		ns.toggle = ->
			if isHidden
				console.log "showing"
				ns.show()
			else
				console.log "hiding"
				ns.hide()

		return ns
