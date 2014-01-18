define ['jinn/util'], (util) ->
	ns = {}

	mixins = {}

	ns.defineOne = (name, mixin) ->
		throw new Error "Mixin #{name} already defined" if mixins[name]?
		mixins[name] = mixin

	ns.define = (specs) ->
		ns.defineOne(name, mixin) for name, mixin of specs

	ns.realizeOne = (name, arg) ->
		definition = mixins[name]
		throw new Error "Uknown mixin #{name}" unless definition?

		mixin	= definition.call null, arg
		oldInit	= mixin.init

		if mixin.defaults?
			mixin.init = ->
				for prop, val of mixin.defaults when not this[prop]?
					this[prop] = val
				oldInit() if oldInit?

		return mixin

	ns.realize = (specs) ->
		ns.realizeOne(name, arg) for name, arg of specs

	return ns
