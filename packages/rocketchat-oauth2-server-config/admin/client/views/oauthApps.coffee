import moment from 'moment'

Template.oauthApps.onCreated ->
	@subscribe 'oauthApps'

Template.oauthApps.helpers
	hasPermission: ->
		return RocketChat.authz.hasAllPermission 'manage-oauth-apps'

	applications: ->
		return ChatOAuthApps.find()

	dateFormated: (date) ->
		return moment(date).format('L LT')

#		d=============================================================================

Template.adminCatalogs.onCreated ->
	@subscribe 'catalogs'

Template.adminCatalogs.helpers
	hasPermission: ->
		return RocketChat.authz.hasAllPermission 'manage-oauth-apps'

	applications: ->
		return Catalogs.find()

	dateFormated: (date) ->
		return moment(date).format('L LT')

#		d=============================================================================


Template.adminOrgs.helpers
	hasPermission: ->
		return RocketChat.authz.hasAllPermission 'manage-oauth-apps'

	applications: ->
		return Template.instance().applications()

	isReady: ->
		return Template.instance().ready?.get()

	isLoading: ->
		return 'btn-loading' unless Template.instance().ready?.get()

	hasMore: ->
		return Template.instance().limit?.get() is Template.instance().applications?().count()

	roomCount: ->
		return Template.instance().applications?().count()


Template.adminOrgs.onCreated ->
#	@subscribe 'orgs'
	instance = @
	@limit = new ReactiveVar 50
	@filter = new ReactiveVar ''
	@ready = new ReactiveVar true


	@autorun ->
		filter = instance.filter.get()

		limit = instance.limit.get()
		subscription = instance.subscribe 'admin-orgs', filter, limit
		instance.ready.set subscription.ready()

	@applications = ->
		filter = _.trim instance.filter?.get()

		query = {}

		filter = _.trim filter
		if filter
			filterReg = new RegExp s.escapeRegExp(filter), "i"
			query = { $or: [ { name: filterReg }, { t: 'd', usernames: filterReg } ] }

		return Orgs.find(query, { limit: instance.limit?.get(), sort: { name: 1 } })

	@getSearchTypes = ->
		return _.map $('[name=active]:checked'), (input) -> return $(input).val()


Template.adminOrgs.events
	'change [name=active]': (e, t) ->
		t.types.set t.getSearchTypes()

	'click .load-more': (e, t) ->
		e.preventDefault()
		e.stopPropagation()
		t.limit.set t.limit.get() + 50

	'keydown #rooms-filter': (e) ->
		if e.which is 13
			e.stopPropagation()
			e.preventDefault()

	'keyup #rooms-filter': (e, t) ->
		e.stopPropagation()
		e.preventDefault()
		t.filter.set e.currentTarget.value


	'click .row-link': (e) ->
		FlowRouter.go "admin-org", {id: e.currentTarget.id}



#		d===================================CITY==========================================



Template.adminCitys.helpers

	applications: ->
		return Template.instance().applications()

	isReady: ->
		return Template.instance().ready?.get()

	isLoading: ->
		return 'btn-loading' unless Template.instance().ready?.get()

	hasMore: ->
		return Template.instance().limit?.get() is Template.instance().applications?().count()

	roomCount: ->
		return Template.instance().applications?().count()


Template.adminCitys.onCreated ->
	@subscribe 'admincitys'
	instance = @
	@limit = new ReactiveVar 50
	@filter = new ReactiveVar ''
	@ready = new ReactiveVar true


	@autorun ->
#		filter = instance.filter.get()
#		limit = instance.limit.get()
#		subscription = instance.subscribe 'admin-orgs', filter, limit
#		instance.ready.set subscription.ready()

	@applications = ->
		return Citys.find().fetch()


Template.adminCitys.events
	'change [name=active]': (e, t) ->
		t.types.set t.getSearchTypes()

	'click .load-more': (e, t) ->
		e.preventDefault()
		e.stopPropagation()
		t.limit.set t.limit.get() + 50

	'keydown #rooms-filter': (e) ->
		if e.which is 13
			e.stopPropagation()
			e.preventDefault()

	'keyup #rooms-filter': (e, t) ->
		e.stopPropagation()
		e.preventDefault()
		t.filter.set e.currentTarget.value


	'click .row-link': (e) ->
		FlowRouter.go "adminCity", {id: e.currentTarget.id}