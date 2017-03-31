


#		d=============================================================================


Template.nearby.helpers

  flexData: ->
    flexData =
      tabBar: Template.instance().tabBar
      data:
        rid: 'S8MfNAJDiybHeCGDx'
        userDetail: {}
        clearUserDetail: {}

    return flexData

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


Template.nearby.onCreated ->
  instance = @
  @limit = new ReactiveVar 1
  @filter = new ReactiveVar ''
  @types = new ReactiveVar ['Male', 'Female']
  @city = new ReactiveVar ''
  @ready = new ReactiveVar true


  @autorun ->
    filter = instance.filter.get()
    types =  instance.types?.get()
    city =  instance.city?.get()
    if types.length is 0
      types = ['Male', 'Female']

    query = {}

    if types.length
      query['sex'] = { $in: types }

    if city
      query['city'] = city

    if status
      query['status'] = { $in: status }

    limit = instance.limit.get()
    subscription = instance.subscribe 'usersSearch', filter, types, query, limit
#    subscription = instance.subscribe 'fullUserData', filter, 100
    instance.ready.set subscription.ready()


  @applications = ->
    filter = _.trim instance.filter?.get()
    types = Session.get("sex")
    city = Session.get("selected-city")

    unless _.isArray types
      types = []


    query = {}

    filter = _.trim filter
    if filter
      filterReg = new RegExp s.escapeRegExp(filter), "i"
      query = { $or: [ { name: filterReg }, { username: filterReg } ] }

    if types.length
      query['sex'] = { $in: types }

    if city
      query['city'] = city

    query['_id'] = { $ne: Meteor.userId() }

    query['location'] =
      $near:
        $geometry: Meteor.user().location
        $maxDistance: 20000

#
#    console.log query

    return Meteor.users.find(query, { limit: instance.limit?.get() })

#
#  @getSearchTypes = ->
#    return _.map $('[name=sex]:checked'), (input) -> return $(input).val()
#







#  instance = @
#  @limit = new ReactiveVar 50
#  @filter = new ReactiveVar ''
#  @ready = new ReactiveVar true
  this.tabBar = new RocketChatTabBar();
  this.tabBar.showGroup("nearby");


#  @autorun ->
#		filter = instance.filter.get()
#		limit = instance.limit.get()
#		subscription = instance.subscribe 'admin-orgs', filter, limit
#		instance.ready.set subscription.ready()

#  @applications = ->
##		filter = _.trim instance.filter?.get()
##
##		query = {_id: {$ne: Meteor.userId()}}
##
##		filter = _.trim filter
##		if filter
##			filterReg = new RegExp s.escapeRegExp(filter), "i"
##			query = { $or: [ { name: filterReg }, { t: 'd', usernames: filterReg } ] }
#
##		return RocketChat.models.Users.findAndSortByGeo(Meteor.user().location)
#

#
#    return Meteor.users.find(query).fetch()
#
#  @getSearchTypes = ->
#    return _.map $('[name=active]:checked'), (input) -> return $(input).val()


Template.nearby.events
#  'change [name=sex]': (e, t) ->
#    t.types.set t.getSearchTypes()
#
#  'change [name=active]': (e, t) ->
#    t.types.set t.getSearchTypes()

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
#		FlowRouter.go "admin-org", {id: e.currentTarget.id}



Template.nearbySettings.helpers
  citys: ->
    return Citys.find()

Template.nearbySettings.events
  'change [name=sex]': (e, t) ->
    Session.set 'sex', t.getSearchTypes()


  'change #city': (e, t) ->
    Session.set 'selected-city', e.currentTarget.value

Template.nearbySettings.onCreated ->
  @getSearchTypes = ->
    return _.map $('[name=sex]:checked'), (input) -> return $(input).val()
