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
						app.definitions[name] = value

					definitionEl.append valueEl
					el.append definitionEl

			$('body').append el

		ns.hide = ->
			$("##{ID}").remove()
			isHidden = true

		ns.toggle = ->
			if isHidden
				ns.show()
			else
				ns.hide()

		return ns
